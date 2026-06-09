# station

A personal place for writing, builds, and notes. Calm, restrained, precise -
the interface gets out of the way of the text.

See [`site-design-spec.md`](./site-design-spec.md) and
[`site-build-spec.md`](./site-build-spec.md) for intent. This repo is the blog
workload: a featherweight static site built from text files.

## Stack

- **[Astro](https://astro.build)** - static output, full control of the markup.
- **Content Collections** - `src/content/{writing,builds,notes}/*.md`.
- **Self-hosted fonts** (Fontsource) - Barlow Semi Condensed, Barlow, IBM Plex
  Mono. No runtime font calls; the build stays hermetic.

## Develop

```bash
pnpm install
pnpm dev      # local dev server
pnpm build    # static build → dist/
pnpm preview  # serve the build
```

## Posting

Drop a Markdown file in the right section folder and push:

```
src/content/writing/my-post.md
src/content/builds/my-project.md
src/content/notes/a-quick-note.md
```

Frontmatter:

```yaml
---
title: Title in plain case
date: 2026-06-08
summary: One honest line under the title.
readtime: 6 min        # optional
stack: [k3s, Traefik]  # optional - builds
filed: [design]        # optional - filed-under
live: false            # optional - true earns the single green status
draft: false           # optional - hidden in production builds
---
```

The newest post across all sections is the one the red featured bar spotlights.

## Design system

- `src/styles/tokens.css` - the calibrated opening position. Tune here.
- `src/styles/base.css` - shared atoms (labels, leaders, stats, hairlines).
- `src/lib/site.ts` - name, location, tagline, the `now -` line, keybinds.

Dark is the home. A light cut is a deliberate port, not an inversion - left for
later.
