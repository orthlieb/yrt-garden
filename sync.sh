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
# Those edits land in content/, which is not tracked — the vault is untouched.
#
#   ./sync.sh                       # refresh content/
#   npx quartz build --serve        # preview at http://localhost:8080
#   (a running --serve auto-rebuilds when content/ changes)
set -euo pipefail
cd "$(dirname "$0")"

VAULT="${YRT_VAULT:-$HOME/dev/yrt-vault}"
IRON="${IRONLEDGER:-$HOME/dev/ironledger}"

echo "→ refreshing the vault's generated game material from ironledger"
( cd "$VAULT" && IRONLEDGER="$IRON" npm run --silent ref )

echo "→ lore  ← $VAULT/Backstory  (excluding Characters/, private)"
rsync -a --delete \
  --exclude='.obsidian' --exclude='.DS_Store' --exclude='Characters' \
  "$VAULT/Backstory/" content/backstory/

echo "→ atlas  ← $VAULT/Atlas  (regions & places)"
rsync -a --delete \
  --exclude='.obsidian' --exclude='.DS_Store' \
  "$VAULT/Atlas/" content/atlas/

echo "→ extensions  ← $VAULT/Ironsworn Extensions  (foes + images, oracles, assets, moves, rarities)"
rsync -a --delete \
  --exclude='.obsidian' --exclude='.DS_Store' \
  "$VAULT/Ironsworn Extensions/" content/ironsworn-extensions/

echo "→ home page  ← $VAULT/home.md + index-footer.md"
cat "$VAULT/home.md" index-footer.md > content/index.md

echo "→ titles  (kebab-case filenames -> readable page titles)"
node prepare-content.mjs

echo "✓ synced. Build: npx quartz build  (or it auto-rebuilds if --serve is running)"
