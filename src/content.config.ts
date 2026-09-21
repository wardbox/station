import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

// One schema across every section. A post is a post; the section it sits in
// (work / writing / builds / notes) is the only difference. Drop a .md file in the
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
  // Genuine live/now status only - earns the distinct status color.
  live: z.boolean().default(false),
  draft: z.boolean().default(false),
  // Work entries only (the portfolio): where it runs, where the code is, what
  // state it is in, one picture. A post without these is an ordinary post.
  domain: z.string().optional(),
  url: z.string().url().optional(),
  repo: z.string().url().optional(),
  status: z.enum(['live', 'offline', 'archived']).optional(),
  image: z.string().optional(),
});

const section = (dir: string) =>
  defineCollection({
    loader: glob({ pattern: '**/*.md', base: `./src/content/${dir}` }),
    schema: post,
  });

export const collections = {
  work: section('work'),
  writing: section('writing'),
  builds: section('builds'),
  notes: section('notes'),
};
