#!/usr/bin/env bash
# Fan the two content sources into the Quartz garden's content/.
#
#   - worldbuilding lore  ← yrt-vault/Backstory   (private bits excluded)
#   - game reference      ← ironledger's generated extensions/yrt/reference
#
# Content authoring:
#   - lore              → edit in Obsidian (yrt-vault/Backstory)
#   - regions & places  → edit in Obsidian (yrt-vault/Atlas)
#   - foes (bestiary)   → edit in Obsidian (yrt-vault/Game/foes), then
#                         `npm run sync` in the vault to push into ironledger
#   - moves/assets/oracles → edit the JSON in ironledger
# This script regenerates ironledger's readable reference and fans everything
# into content/. Flow: edit → (vault `npm run sync` for foes) → ./sync.sh → build.
#
#   ./sync.sh                       # refresh content/
#   npx quartz build --serve        # preview at http://localhost:8080
#   (a running --serve auto-rebuilds when content/ changes)
set -euo pipefail
cd "$(dirname "$0")"

VAULT="${YRT_VAULT:-$HOME/dev/yrt-vault}"
IRON="${IRONLEDGER:-$HOME/dev/ironledger}"

echo "→ lore  ← $VAULT/Backstory  (excluding Characters/, private)"
rsync -a --delete \
  --exclude='.obsidian' --exclude='.DS_Store' --exclude='Characters' \
  "$VAULT/Backstory/" content/backstory/

echo "→ atlas  ← $VAULT/Atlas  (regions & places)"
rsync -a --delete \
  --exclude='.obsidian' --exclude='.DS_Store' \
  "$VAULT/Atlas/" content/atlas/

echo "→ reference  ← $IRON (regenerating first)"
( cd "$IRON" && npm run --silent gen:yrt-ref >/dev/null )
mkdir -p content/reference content/foes/images
cp "$IRON/extensions/yrt/reference/"*.md content/reference/
cp "$IRON/extensions/yrt/foes/images/"*.webp content/foes/images/

echo "✓ synced. Build: npx quartz build  (or it auto-rebuilds if --serve is running)"
