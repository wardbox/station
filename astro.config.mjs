// @ts-check
import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';
import tailwindcss from '@tailwindcss/vite';

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
    // Code blocks stay on the same dim field as everything else.
    shikiConfig: { theme: 'github-dark-default', wrap: true },
  },
});
