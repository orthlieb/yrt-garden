#!/usr/bin/env bash
# Rebuild the garden and deploy it to GitHub Pages.
#
# The content is generated locally from the private vault (yrt-vault) + ironledger,
# so the build AND the deploy run here — GitHub CI can't see the private vault.
# This fans in content, builds the static site, and force-pushes public/ to the
# gh-pages branch (which GitHub Pages serves). Run it after editing lore/regions
# (or after `npm run sync` in the vault for foe changes).
#
#   ./deploy.sh
#
# Live at: https://orthlieb.github.io/yrt-garden/
set -euo pipefail
cd "$(dirname "$0")"

echo "→ sync content (vault lore + regions, ironledger reference, foe images)"
./sync.sh >/dev/null

echo "→ build"
npx quartz build

# Project page (no custom domain): strip the CNAME Quartz derives from baseUrl,
# and add .nojekyll so Pages doesn't run Jekyll over Quartz's _-prefixed output.
rm -f public/CNAME
touch public/.nojekyll

echo "→ deploy public/ → gh-pages (force; the branch is built output, not history)"
REMOTE="$(git remote get-url origin)"
TMP="$(mktemp -d)"
cp -a public/. "$TMP"/
git -C "$TMP" init -q -b gh-pages
git -C "$TMP" add -A
git -C "$TMP" commit -q -m "Deploy $(date -u +%Y-%m-%dT%H:%MZ)"
git -C "$TMP" push -q --force "$REMOTE" gh-pages:gh-pages
rm -rf "$TMP"

echo "✓ deployed → https://orthlieb.github.io/yrt-garden/  (Pages rebuild takes ~1 min)"
