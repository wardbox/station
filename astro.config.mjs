// @ts-check
import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

// https://astro.build/config
export default defineConfig({
  // Feed + sitemap + canonical URLs are emitted as absolute URLs from this.
  site: 'https://stationsystems.dev',
  integrations: [sitemap()],
  markdown: {
    // Code blocks stay on the same dim field as everything else.
    shikiConfig: { theme: 'github-dark-default', wrap: true },
  },
});
