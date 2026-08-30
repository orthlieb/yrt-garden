#!/usr/bin/env bash
# Fan the vault into the Quartz garden's content/.
#
# The chain is one-directional:
#
#   ironledger  --(vault: npm run ref)-->  yrt-vault  --(this script)-->  yrt-garden
#
# Content authoring:
#   - the home page           → edit in Obsidian (yrt-vault/home.md); this script
#                               appends index-footer.md, which the garden owns
#   - lore, regions & places  → edit in Obsidian (yrt-vault/Backstory, /Atlas)
#   - foes, moves, assets,    → edit the JSON in ironledger (extensions/yrt),
#     oracles, rarities         then `npm run ref` in the vault
#
# Everything under yrt-vault/Ironsworn Extensions is generated from ironledger and is
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
      find "$dest" -name "$e" -exec rm -rf {} + 2>/dev/null || true
    done
  fi
}

VAULT="${YRT_VAULT:-$HOME/dev/yrt-vault}"
IRON="${IRONLEDGER:-$HOME/dev/ironledger}"

echo "→ refreshing the vault's generated game material from ironledger"
( cd "$VAULT" && IRONLEDGER="$IRON" npm run --silent ref )

echo "→ lore  ← $VAULT/Backstory  (excluding Characters/, private)"
mirror "$VAULT/Backstory/" content/backstory/ '.obsidian' '.DS_Store' 'Characters'

echo "→ atlas  ← $VAULT/Atlas  (regions & places)"
mirror "$VAULT/Atlas/" content/atlas/ '.obsidian' '.DS_Store'

echo "→ extensions  ← $VAULT/Ironsworn Extensions  (foes + images, oracles, assets, moves, rarities)"
mirror "$VAULT/Ironsworn Extensions/" content/ironsworn-extensions/ '.obsidian' '.DS_Store'

echo "→ home page  ← $VAULT/Home.md + index-footer.md"
cat "$VAULT/Home.md" index-footer.md > content/index.md

echo "→ titles  (kebab-case filenames -> readable page titles)"
node prepare-content.mjs

echo "✓ synced. Review with 'git status', commit content/, then: npx quartz build"
