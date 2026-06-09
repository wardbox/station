import { getCollection, type CollectionEntry } from 'astro:content';

// The three sections, in display order.
export const POST_TYPES = ['writing', 'builds', 'notes'] as const;
export type PostType = (typeof POST_TYPES)[number];

// Tracked-caps labels live in the chrome; the proper-case names live here.
export const TYPE_LABEL: Record<PostType, string> = {
  writing: 'Writing',
  builds: 'Builds',
  notes: 'Notes',
};

export type AnyEntry =
  | CollectionEntry<'writing'>
  | CollectionEntry<'builds'>
  | CollectionEntry<'notes'>;

// A post is an entry plus the section it came from.
export interface Post {
  type: PostType;
  entry: AnyEntry;
}

// Every post across all sections, newest first, drafts dropped in prod.
export async function getAllPosts(): Promise<Post[]> {
  const all: Post[] = [];
  for (const type of POST_TYPES) {
    const entries = await getCollection(type);
    for (const entry of entries) {
      if (import.meta.env.PROD && entry.data.draft) continue;
      all.push({ type, entry });
    }
  }
  all.sort((a, b) => b.entry.data.date.getTime() - a.entry.data.date.getTime());
  return all;
}

// The single latest post - the one the red featured bar spotlights.
export async function getLatest(): Promise<Post | undefined> {
  return (await getAllPosts())[0];
}

// Posts grouped by section, each list newest first.
export async function getSections(): Promise<
  { type: PostType; label: string; posts: Post[] }[]
> {
  const all = await getAllPosts();
  return POST_TYPES.map((type) => ({
    type,
    label: TYPE_LABEL[type],
    posts: all.filter((p) => p.type === type),
  }));
}

export const postPath = (p: Post) => `/${p.type}/${p.entry.id.replace(/\.md$/, '')}`;

// "08 Jun 2026" - post eyebrow; terse, unambiguous, no comma.
const fmt = new Intl.DateTimeFormat('en-GB', {
  day: '2-digit',
  month: 'short',
  year: 'numeric',
});
export const formatDate = (d: Date) => fmt.format(d);

// "06·08" (MM·DD) - the tight mono readout used in the index + latest band.
const p2 = (n: number) => String(n).padStart(2, '0');
export const formatShort = (d: Date) => `${p2(d.getMonth() + 1)}·${p2(d.getDate())}`;
