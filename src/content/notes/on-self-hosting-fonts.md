---
title: On self-hosting the fonts
date: 2026-05-28
summary: Why the type ships with the build instead of phoning home.
readtime: 2 min
filed:
  - notes
---

The fonts here are bundled with the site, not loaded from a third party at
runtime. Two reasons.

First, the build stays hermetic. It produces the same bytes whether or not some
font CDN is reachable, which matters when the whole point is a featherweight
static image that deploys the same way every time.

Second, it fits the feel. A confidential-feeling field that quietly fetches your
type from someone else's server is a small contradiction. Keep it local.
