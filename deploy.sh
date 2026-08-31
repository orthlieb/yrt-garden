#!/usr/bin/env bash
# Rebuild the garden and deploy it to GitHub Pages.
#
# content/ is committed, so a plain `npx quartz build` needs nothing else. This
# script goes further: it REFRESHES content from the private vault (yrt-vault)
# and ironledger first, which is why it runs here rather than in CI — GitHub
# can't see the vault. It then builds and force-pushes public/ to the gh-pages
# branch that Pages serves. Run it after editing lore/regions (or after
# `npm run ref` in the vault for foe changes).
#
#   ./deploy.sh
#
# Live at: https://orthlieb.github.io/yrt-garden/
set -euo pipefail
cd "$(dirname "$0")"

echo "→ sync content (vault lore + regions, ironledger reference, foe images)"
./sync.sh

# content/ is committed, so what is live and what is on main should say the same
# thing. If the sync moved anything, stop here: deploying now would publish
# content that no commit in this repo accounts for, and the next person to clone
# and build would get the older site back.
if [ -n "$(git status --porcelain -- content)" ]; then
  echo >&2
  echo "✗ the sync changed content/ — review and commit it, then deploy:" >&2
  git status --short -- content | head -20 >&2
  echo >&2
  echo "    git add content && git commit -m 'Refresh content from the vault'" >&2
  exit 1
fi

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
