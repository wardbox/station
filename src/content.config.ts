import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

// One schema across every section. A post is a post; the section it sits in
// (writing / builds / notes) is the only difference. Drop a .md file in the
// right folder and it shows up - "posting is a git push" (build-spec).
const post = z.object({
  title: z.string(),
  date: z.coerce.date(),
  // One-line summary. Sits under the title; never a paragraph.
  summary: z.string(),
  // Faint readouts on the post header / index. All optional.
  readtime: z.string().optional(), // e.g. "6 min"
  stack: z.array(z.string()).optional(), // builds: what it's made of
  filed: z.array(z.string()).optional(), // filed-under tags
  // Genuine live/now status only - earns the single green (design Principle 2).
  live: z.boolean().default(false),
  draft: z.boolean().default(false),
});

const section = (dir: string) =>
  defineCollection({
    loader: glob({ pattern: '**/*.md', base: `./src/content/${dir}` }),
    schema: post,
  });

export const collections = {
  writing: section('writing'),
  builds: section('builds'),
  notes: section('notes'),
};
