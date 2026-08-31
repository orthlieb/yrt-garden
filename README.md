# The World of Yrt — garden

The published site for the **Yrt** setting: lore, the regional Atlas, and the
Ironsworn extension reference. Built with [Quartz v5](https://quartz.jzhao.xyz/).

**Live at <https://orthlieb.github.io/yrt-garden/>**

---

## Build it

```bash
npm install            # once
npx quartz build       # → public/
```

Then open `public/index.html`, or preview with a live server that rebuilds as
files change:

```bash
npx quartz build --serve      # → http://localhost:8080
```

**That is all you need for a plain build.** `content/` is committed, so a fresh
clone builds on its own — you do not need the vault or ironledger present
unless you want to *refresh* the content.

## Where the content comes from

```
ironledger  ──(vault: npm run ref)──▶  yrt-vault  ──(./sync.sh)──▶  yrt-garden
```

One direction only, and nothing is hand-authored in this repository at all.
Every word on the site comes from the vault; what lives here is the Quartz
configuration and the scripts that fan the content in. If you find yourself
editing a file under `content/`, you are in the wrong repository — the next
`./sync.sh` overwrites it.

| To change… | Edit… |
|---|---|
| lore, regions, places | `yrt-vault/YRT/Backstory`, `yrt-vault/YRT/Atlas` (in Obsidian) |
| the home page, incl. its colophon and licence note | `yrt-vault/YRT/Home.md` (in Obsidian) |
| foes, moves, assets, oracles, rarities | the JSON in `ironledger/extensions/yrt`, then `npm run ref` in the vault |
| site title, theme, plugins | `quartz.config.yaml`, `quartz.ts` |

The manuscript — `yrt-vault/YRT/Silk and Slaughter`, which holds the character
references too — is never synced, so none of it is published.

## Refresh the content

```bash
./sync.sh
git status            # review what moved
git add content && git commit
```

`sync.sh` fans the vault into `content/`, refreshing the generated game
material from ironledger first, then writes readable `title:` frontmatter and
gives every folder an index. It expects:

| Variable | Default |
|---|---|
| `YRT_VAULT` | `$HOME/dev/yrt-vault` |
| `IRONLEDGER` | `$HOME/dev/ironledger` |

Override them if your checkouts live elsewhere:

```bash
YRT_VAULT=~/src/yrt-vault IRONLEDGER=~/src/ironledger ./sync.sh
```

## Deploy

```bash
./deploy.sh
```

Every deploy starts by copying from the vault, so what goes live is always the
vault as it stands at that moment — there is no way to publish a stale site by
forgetting to sync first. In order, it:

1. runs `sync.sh` — vault lore and Atlas, ironledger's game material, foe images;
2. commits `content/` if the sync moved anything, and pushes `main`;
3. builds, and force-pushes `public/` to `gh-pages`.

The push happens before the publish, so a failure there leaves nothing live and
the site cannot drift away from `main`. `gh-pages` is build output, not history —
it is overwritten every time, and nothing should ever be committed to it by hand.
Pages takes about a minute to go live.

Deploying therefore needs the vault and ironledger checked out. A plain build
does not.

## Images

Source images live in the vault and are WebP. Keep them there — anything
dropped straight into `content/` is overwritten by the next sync.

The exception is the foe imagery under `content/ironsworn-extensions/foes/images`,
which is generated from ironledger (`yrt-vault/YRT/Ironsworn Extensions`);
optimise those at their source, not here.

---

Quartz is by [Jacky Zhao](https://github.com/jackyzha0/quartz) and is MIT
licensed; see `LICENSE.txt`. The setting text and images are not.
