// The feed carries the blog. Work entries are pages about the sites, not posts.
import rss from '@astrojs/rss';
import type { APIContext } from 'astro';
import { getAllPosts, postPath } from '../lib/content';
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
      categories: [p.type, ...(p.entry.data.filed ?? [])],
    })),
    customData: `<language>en-us</language>`,
  });
}
