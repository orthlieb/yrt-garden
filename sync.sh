#!/usr/bin/env bash
# Fan the vault into the Quartz garden's content/.
#
# The chain is one-directional:
#
#   ironledger  --(vault: npm run ref)-->  yrt-vault  --(this script)-->  yrt-garden
#
# Content authoring:
#   - lore, regions & places  → edit in Obsidian (yrt-vault/Backstory, /Atlas)
#   - foes, moves, assets,    → edit the JSON in ironledger (extensions/yrt),
#     oracles, rarities         then `npm run ref` in the vault
#
# Everything under yrt-vault/YRT Extensions is generated from ironledger and is
# read-only; this script refreshes it before copying so the garden never
# publishes a stale bestiary.
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

echo "→ extensions  ← $VAULT/YRT Extensions  (foes + images, oracles, assets, moves, rarities)"
rsync -a --delete \
  --exclude='.obsidian' --exclude='.DS_Store' \
  "$VAULT/YRT Extensions/" content/yrt-extensions/

echo "✓ synced. Build: npx quartz build  (or it auto-rebuilds if --serve is running)"
