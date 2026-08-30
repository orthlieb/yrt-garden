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

One direction only. Nothing is authored in this repository except the home
page footer and the Quartz configuration.

| To change… | Edit… |
|---|---|
| lore, regions, places | `yrt-vault/Backstory`, `yrt-vault/Atlas` (in Obsidian) |
| the home page | `yrt-vault/Home.md` — `sync.sh` appends `index-footer.md`, which this repo owns |
| foes, moves, assets, oracles, rarities | the JSON in `ironledger/extensions/yrt`, then `npm run ref` in the vault |
| site title, theme, plugins | `quartz.config.yaml`, `quartz.ts` |

`yrt-vault/Backstory/Characters` is deliberately **not** published.

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

Syncs, builds, and force-pushes `public/` to the `gh-pages` branch that GitHub
Pages serves. `gh-pages` is build output, not history — it is overwritten every
time, and nothing should ever be committed to it by hand. Pages takes about a
minute to go live.

Because `deploy.sh` runs `sync.sh` first, deploying **does** need the vault and
ironledger checked out. A build alone does not.

## Images

Source images live in the vault and are WebP. Keep them there — anything
dropped straight into `content/` is overwritten by the next sync.

The exception is the foe imagery under `content/ironsworn-extensions/foes/images`,
which is generated from ironledger; optimise those at their source, not here.

---

Quartz is by [Jacky Zhao](https://github.com/jackyzha0/quartz) and is MIT
licensed; see `LICENSE.txt`. The setting text and images are not.
