// @ts-check
import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';
import tailwindcss from '@tailwindcss/vite';

// A paragraph holding one image becomes a figure with the alt text as its caption,
// so a Markdown picture carries its own line under it.
const figures = () => (tree) => {
  const walk = (node) => {
    if (!node.children) return;
    node.children = node.children.map((child) => {
      if (child.type === 'element' && child.tagName === 'p' && child.children.length === 1) {
        const img = child.children[0];
        if (img.type === 'element' && img.tagName === 'img' && img.properties.alt) {
          return {
            type: 'element',
            tagName: 'figure',
            properties: {},
            children: [
              img,
              { type: 'element', tagName: 'figcaption', properties: {}, children: [{ type: 'text', value: img.properties.alt }] },
            ],
          };
        }
      }
      walk(child);
      return child;
    });
  };
  walk(tree);
};

// https://astro.build/config
export default defineConfig({
  // Feed + sitemap + canonical URLs are emitted as absolute URLs from this.
  site: 'https://stationsystems.dev',
  integrations: [sitemap()],
  // Posts moved from /<section>/<slug> to /blog/<slug>; old links keep working.
  redirects: {
    '/writing/': '/blog/',
    '/builds/': '/blog/',
    '/notes/': '/blog/',
    '/writing/[...slug]': '/blog/[...slug]',
    '/builds/[...slug]': '/blog/[...slug]',
    '/notes/[...slug]': '/blog/[...slug]',
  },
  vite: {
    plugins: [tailwindcss()],
  },
  markdown: {
    rehypePlugins: [figures],
    // Code blocks stay on the same dim field as everything else.
    shikiConfig: { theme: 'github-dark-default', wrap: true },
  },
});
