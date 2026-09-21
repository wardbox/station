import { existsSync, readdirSync } from 'node:fs';
import { getCollection, type CollectionEntry } from 'astro:content';

// The blog's sections, in display order.
export const POST_TYPES = ['writing', 'builds', 'notes'] as const;
export type PostType = (typeof POST_TYPES)[number];

export type AnyEntry =
  | CollectionEntry<'writing'>
  | CollectionEntry<'builds'>
  | CollectionEntry<'notes'>;

// A post is an entry plus the section it came from.
export interface Post {
  type: PostType;
  entry: AnyEntry;
}

// A section with no Markdown yet is skipped before getCollection, which warns
// on an empty collection at every page.
const sectionHasEntries = (type: PostType) => {
  try {
    return readdirSync(`src/content/${type}`).some((f) => f.endsWith('.md'));
  } catch {
    return false;
  }
};

const entryExists = (type: PostType, entry: AnyEntry) =>
  existsSync(`src/content/${type}/${entry.id}`) ||
  existsSync(`src/content/${type}/${entry.id}.md`);

// Every post across all sections, newest first, drafts dropped in prod. The
// file existence check keeps deleted Markdown from leaking out of a stale
// content-layer cache.
export async function getAllPosts(): Promise<Post[]> {
  const all: Post[] = [];
  for (const type of POST_TYPES) {
    if (!sectionHasEntries(type)) continue;
    const entries = await getCollection(type);
    for (const entry of entries) {
      if (!entryExists(type, entry)) continue;
      if (import.meta.env.PROD && entry.data.draft) continue;
      all.push({ type, entry });
    }
  }
  all.sort((a, b) => b.entry.data.date.getTime() - a.entry.data.date.getTime());
  return all;
}

export const postSlug = (p: Post) => p.entry.id.replace(/\.md$/, '');
export const postPath = (p: Post) => `/blog/${postSlug(p)}/`;

export const getWork = async () =>
  (await getCollection('work')).sort((a, b) => a.data.order - b.data.order);

// Frontmatter dates parse as UTC midnight, so they are read back in UTC too;
// a Pacific build was printing every post a day early.
export const formatDate = (d: Date) => d.toISOString().slice(0, 10);
