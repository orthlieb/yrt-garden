#!/usr/bin/env bash
# Rebuild the garden and deploy it to GitHub Pages.
#
# content/ is committed, so a plain `npx quartz build` needs nothing else. This
# script goes further: EVERY deploy begins by refreshing content from the private
# vault (yrt-vault) and ironledger, which is why it runs here rather than in CI —
# GitHub can't see the vault. So what goes live is always the vault as it stands
# at that moment; there is no way to publish a stale site by forgetting to sync.
# The refresh is committed and pushed before anything is published, then public/
# is force-pushed to the gh-pages branch that Pages serves.
#
#   ./deploy.sh
#
# Live at: https://orthlieb.github.io/yrt-garden/
set -euo pipefail
cd "$(dirname "$0")"

echo "→ sync content (vault lore + regions, ironledger reference, foe images)"
./sync.sh

# content/ is generated and never hand-authored, so a change here is not
# something a person needs to approve — it is just the vault having moved. Record
# it and carry on; committing before publishing is what keeps the live site and
# main saying the same thing.
if [ -n "$(git status --porcelain -- content)" ]; then
  echo "→ commit the refreshed content"
  git add content
  git commit -q -m "Refresh content from the vault"
  git --no-pager log -1 --stat --format='    %h %s' -- content | head -12
fi

# Push main before publishing, not after: if this fails, nothing has gone live,
# so the site and the repository cannot drift apart.
if [ -n "$(git log --oneline '@{u}..HEAD' 2>/dev/null)" ]; then
  echo "→ push main"
  git push -q
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
