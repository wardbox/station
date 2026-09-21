import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

// A blog post. The section it sits in (writing / builds / notes) is the only
// difference. Drop a .md file in the right folder and it shows up.
const post = z.object({
  title: z.string(),
  date: z.coerce.date(),
  summary: z.string(),
  readtime: z.string().optional(),
  stack: z.array(z.string()).optional(),
  filed: z.array(z.string()).optional(),
  draft: z.boolean().default(false),
});

const section = (dir: string) =>
  defineCollection({
    loader: glob({ pattern: '**/*.md', base: `./src/content/${dir}` }),
    schema: post,
  });

// A project on the portfolio. One page each under /work.
const work = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/work' }),
  schema: z.object({
    title: z.string(),
    domain: z.string(),
    url: z.string().url().optional(),
    repo: z.string().url().optional(),
    // live: a running site. offline: taken down, data kept. archived: shut down.
    // repo: code that is used as code, nothing to run.
    status: z.enum(['live', 'offline', 'archived', 'repo']),
    started: z.string(), // YYYY-MM
    summary: z.string(),
    stack: z.array(z.string()),
    image: z.string().optional(),
    order: z.number(),
  }),
});

export const collections = {
  work,
  writing: section('writing'),
  builds: section('builds'),
  notes: section('notes'),
};
