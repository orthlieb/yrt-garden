// =============================================================================
// prepare-content.mjs — adapt the synced vault notes to Quartz's conventions.
//
// Two passes, both confined to content/ so the vault itself stays untouched.
//
// 1. TITLES — give every note a readable `title:` in its frontmatter.
//
// The vault uses kebab-case filenames (ostrea.md, amber-schemer.md). Quartz
// falls back to the slug when a note has no title, so pages and folder listings
// would read "ostrea" and "amber-schemer". This walks content/ after the sync
// and writes a proper title, preferring what the note already says about itself:
//
//   1. an existing `title:`            — left alone
//   2. the note's first `# H1`         — "Location: Region", "Ostrea"
//   3. frontmatter `name:`             — foe notes, which have no H1
//   4. Title Case of the filename      — last resort
//
// 2. NUMERIC HASHTAGS — escape things like "Mana Refinement Site #1". Obsidian
//    does not treat an all-digit #1 as a tag, so the vault prose is correct as
//    written, but Quartz does, which spawns stray /tags/1 pages and puts tag
//    pills on the page. Escaping to \\#1 renders identically and tags nothing.
//
// Run from sync.sh; safe to run repeatedly.
// =============================================================================

import { readdir, readFile, writeFile } from 'fs/promises';
import path from 'path';

const CONTENT = path.join(path.dirname(new URL(import.meta.url).pathname), 'content');
const ACRONYMS = new Map([['yrt', 'YRT']]);
const MINOR = new Set(['a', 'an', 'the', 'of', 'and', 'or', 'in', 'on', 'to', 'for']);

const titleCase = (slug) =>
  slug
    .split('-')
    .map((w, i, all) => {
      if (ACRONYMS.has(w)) return ACRONYMS.get(w);
      if (i > 0 && i < all.length - 1 && MINOR.has(w)) return w;
      return w.charAt(0).toUpperCase() + w.slice(1);
    })
    .join(' ');

async function walk(dir, out = []) {
  for (const e of await readdir(dir, { withFileTypes: true })) {
    const abs = path.join(dir, e.name);
    if (e.isDirectory()) await walk(abs, out);
    else if (e.name.endsWith('.md')) out.push(abs);
  }
  return out;
}

/** Split a note into [frontmatterLines, bodyString]; frontmatter may be empty. */
function split(text) {
  if (!text.startsWith('---\n')) return [[], text];
  const end = text.indexOf('\n---\n', 4);
  if (end === -1) return [[], text];
  return [text.slice(4, end).split('\n'), text.slice(end + 5)];
}

const yamlValue = (lines, key) => {
  const hit = lines.find((l) => l.startsWith(`${key}:`));
  return hit ? hit.slice(key.length + 1).trim().replace(/^["']|["']$/g, '') : null;
};

// Quartz titles a folder listing from an index.md, or from a note sharing the
// folder's name (atlas/atlas.md). Folders with neither fall back to the slug, so
// give any folder that actually holds notes a minimal index.
async function ensureFolderIndex(dir) {
  const entries = await readdir(dir, { withFileTypes: true });
  const names = new Set(entries.map((e) => e.name));
  const hasNotes = entries.some((e) => e.isFile() && e.name.endsWith('.md'));
  const folder = path.basename(dir);
  if (hasNotes && dir !== CONTENT && !names.has('index.md') && !names.has(`${folder}.md`)) {
    await writeFile(path.join(dir, 'index.md'), `---\ntitle: ${titleCase(folder)}\n---\n`, 'utf8');
  }
  for (const e of entries.filter((e) => e.isDirectory())) await ensureFolderIndex(path.join(dir, e.name));
}
await ensureFolderIndex(CONTENT);

let changed = 0;
for (const file of await walk(CONTENT)) {
  const text = await readFile(file, 'utf8');
  const [fm, body] = split(text);
  if (yamlValue(fm, 'title')) continue;

  const h1 = body.match(/^#\s+(.+)$/m)?.[1]?.trim();
  const title = h1 || yamlValue(fm, 'name') || titleCase(path.basename(file, '.md'));
  const quoted = `title: ${/[:#[\]{}|>*&!%@`]/.test(title) ? JSON.stringify(title) : title}`;

  await writeFile(file, fm.length ? `---\n${quoted}\n${fm.join('\n')}\n---\n${body}` : `---\n${quoted}\n---\n\n${text}`, 'utf8');
  changed++;
}
// Pass 2 — escape all-digit hashtags, which only Quartz reads as tags.
let escaped = 0;
for (const file of await walk(CONTENT)) {
  const text = await readFile(file, 'utf8');
  const next = text.replace(/(^|[^\\`\w])#(\d+)\b/g, '$1\\#$2');
  if (next !== text) { await writeFile(file, next, 'utf8'); escaped++; }
}
console.log(`✓ titled ${changed} notes, escaped numeric hashtags in ${escaped}`);
