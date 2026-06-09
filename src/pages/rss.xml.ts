// The feed - "drop a post, push" only matters if people can follow it.
import rss from '@astrojs/rss';
import type { APIContext } from 'astro';
import { getAllPosts, postPath, TYPE_LABEL } from '../lib/content';
import { site } from '../lib/site';

export async function GET(context: APIContext) {
  const posts = await getAllPosts();
  return rss({
    title: site.name,
    description: site.tagline,
    site: context.site!,
    items: posts.map((p) => ({
      title: p.entry.data.title,
      pubDate: p.entry.data.date,
      description: p.entry.data.summary,
      link: postPath(p),
      categories: [TYPE_LABEL[p.type], ...(p.entry.data.filed ?? [])],
    })),
    customData: `<language>en-us</language>`,
  });
}
