#!/usr/bin/env bash
# Fan the vault into the Quartz garden's content/.
#
# The chain is one-directional:
#
#   ironledger  --(vault: npm run ref)-->  yrt-vault  --(this script)-->  yrt-garden
#
# Content authoring:
#   - the home page           → edit in Obsidian (yrt-vault/YRT/Home.md), colophon
#                               and licence note included
#   - lore, regions & places  → edit in Obsidian (yrt-vault/YRT/Backstory, /Atlas)
#
# The manuscript (yrt-vault/YRT/Silk and Slaughter, which now holds the character
# references too) is not fanned in at all, so none of it is published.
#   - foes, moves, assets,    → edit the JSON in ironledger (extensions/yrt),
#     oracles, rarities         then `npm run ref` in the vault
#
# Everything under yrt-vault/YRT/Ironsworn Extensions is generated from ironledger and is
# read-only; this script refreshes it before copying so the garden never
# publishes a stale bestiary.
#
# The vault uses kebab-case filenames, so after copying, prepare-content.mjs writes a
# readable `title:` into each note's frontmatter and gives every folder an index.
# Those edits land in content/, which is tracked here — the vault is untouched.
#
# content/ is committed, so the garden is self-contained: a clone can be built
# without the vault or ironledger present. After running this script, commit
# whatever it changed.
#
#   ./sync.sh                       # refresh content/
#   npx quartz build --serve        # preview at http://localhost:8080
#   (a running --serve auto-rebuilds when content/ changes)
set -euo pipefail
cd "$(dirname "$0")"

# Mirror a directory into content/, deleting whatever is no longer in the source.
# Uses rsync when it is available and falls back to cp, so the script runs on a
# bare container as well as on a workstation.
mirror() {
  local src="$1" dest="$2"; shift 2
  local ex=("$@")
  if command -v rsync >/dev/null 2>&1; then
    local args=(-a --delete)
    for e in "${ex[@]}"; do args+=("--exclude=$e"); done
    rsync "${args[@]}" "$src" "$dest"
  else
    rm -rf "$dest"
    mkdir -p "$dest"
    cp -R "${src%/}/." "$dest"
    for e in "${ex[@]}"; do
      # -prune so find does not try to descend into a directory it just removed.
      find "$dest" -name "$e" -prune -exec rm -rf {} +
    done
  fi
}

VAULT="${YRT_VAULT:-$HOME/dev/yrt-vault}"
IRON="${IRONLEDGER:-$HOME/dev/ironledger}"

# The vault keeps everything it publishes under YRT/. Check for that rather than
# for the checkout, so pointing at the wrong directory fails here with something
# readable instead of deep inside a copy.
if [ ! -d "$VAULT/YRT" ]; then
  echo "✗ no YRT/ in $VAULT — set YRT_VAULT to the yrt-vault checkout." >&2
  exit 1
fi

echo "→ refreshing the vault's generated game material from ironledger"
( cd "$VAULT" && IRONLEDGER="$IRON" npm run --silent ref )

# That rewrites the vault's generated notes wholesale, which is the point — but
# it also silently discards any hand-edit someone made to one of them. Say what
# moved, so the loss is visible in the vault before it is committed there.
if git -C "$VAULT" rev-parse --git-dir >/dev/null 2>&1; then
  touched="$(git -C "$VAULT" status --porcelain -- 'YRT/Ironsworn Extensions')"
  if [ -n "$touched" ]; then
    echo "  ! the refresh changed the vault's working tree:"
    echo "$touched" | sed 's/^/    /'
    echo "  ! hand-edits to generated notes do not survive this — check the vault before committing there"
  fi
fi

# Nothing here is authored by hand: content/ is output, and the next few lines
# overwrite it wholesale. If it is already dirty, that is either an unfinished
# sync or an edit made in the wrong repository — either way it is about to go.
if [ -n "$(git status --porcelain -- content 2>/dev/null)" ]; then
  echo "  ! content/ has uncommitted changes; this sync overwrites them:"
  git status --short -- content | head -10 | sed 's/^/    /'
  echo "  ! edits belong in the vault, not here"
fi

echo "→ lore  ← $VAULT/YRT/Backstory"
mirror "$VAULT/YRT/Backstory/" content/backstory/ '.obsidian' '.DS_Store'

echo "→ atlas  ← $VAULT/YRT/Atlas  (regions & places)"
mirror "$VAULT/YRT/Atlas/" content/atlas/ '.obsidian' '.DS_Store'

echo "→ extensions  ← $VAULT/YRT/Ironsworn Extensions  (foes + images, oracles, assets, moves, rarities)"
mirror "$VAULT/YRT/Ironsworn Extensions/" content/ironsworn-extensions/ '.obsidian' '.DS_Store'

echo "→ home page  ← $VAULT/YRT/Home.md"
cp "$VAULT/YRT/Home.md" content/index.md

echo "→ titles  (kebab-case filenames -> readable page titles)"
node prepare-content.mjs

echo "✓ synced. Review with 'git status', commit content/, then: npx quartz build"
