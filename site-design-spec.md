# Site — design spec

A spec of *intent*, not orders. Each rule states the reasoning so new decisions
can be derived from principle instead of looked up. If a choice isn't covered
here, ask: "what would keep the interface honest, restrained, and precise?" and
follow that.

---

## North star

A personal place to drop writing, builds, and notes. The interface reads like a
piece of precision software — calm, confidential-feeling, engineered — and gets
out of the way of the text. It should feel hand-made by a person, not generated.

Reference DNA: IO Interactive (Hitman) menus, Valorant, Marathon. Scandinavian
restraint + intelligence-agency precision.

**What we're borrowing is the *grammar*, not the costume.** See anti-goals.

---

## Principles

1. **Honest words only.** No `CLASSIFIED`, fake file numbers, redaction bars, or
   clearance levels. It isn't classified. The intelligence-agency *feel* comes
   from precision and restraint, not from cosplay labels. Real ones don't stamp
   EYES ONLY on the homepage.

2. **One accent, used once per region.** The accent marks the single most
   important thing in a given area (the latest post, the active tab) — never
   decoration. The moment it appears twice in one view, it stops meaning
   anything. Live/now status gets its own separate status color.

3. **Weights stay restrained.** Medium, not black. The look reads refined
   because it resists shouting. If something needs emphasis, reach for scale,
   space, or the accent before reaching for weight.

4. **Labels track out, content stays plain.** System labels are small, uppercase,
   letter-spaced, muted gray. The actual content (titles, prose) is normal case
   and higher-contrast. The contrast between the two *is* the hierarchy.

5. **Structure from lines, not boxes.** Hairline rules, dotted leaders, and
   whitespace do the dividing. Avoid cards-within-cards, shadows, gradients.
   Depth comes from a single desaturated photo behind flat panels, nothing more.

6. **Numbers carry a faint unit.** `6 min`, `045 entries` — value in display
   weight, unit small and muted. Lifted from the score-screen XP treatment.

7. **Text is the design.** No markdown soup, no widgets competing with the
   writing. A post is words in a good face on a calm field. Chrome lives at the
   edges (header, status line, keys), never in the reading column.

8. **Dark is the home, but not mandatory.** The look is built for a dim
   photographic field. A light cut is allowed but is a *port*, not the default —
   it must re-earn the same restraint, not just invert colors.

---

## Tokens — starting points, tune in the browser

Treat these as a calibrated *opening position*, not law. Adjust against real
content and a real backdrop photo.

### Color
```text
bg / field        #1b1f20   (cool desaturated near-black; photo sits behind at ~8%)
panel border      #2e3334
hairline          #3a3f40
text / primary    #eceae5
text / label      #868c8a
text / faint      #9aa09e   (dates, secondary readouts)
accent            #1faa68   (featured + active only; current emerald cut)
live / now         #34c0d4   (genuine status only; distinct from accent)
```

### Type
```text
display / titles  Barlow Semi Condensed, 500   — section + post titles, header
body / labels     Barlow, 400–500              — prose, tracked-caps labels
mono / readouts   IBM Plex Mono, 400           — dates, counts, status, keycaps
```
Fonts are a strong default, not sacred. The brief is "a clean, slightly
condensed humanist grotesk + a mono for readouts." Anything that holds that
brief is fair game.

### Rhythm
- Tracked label letter-spacing ≈ `.16em`; mono readouts ≈ `.05–.1em`.
- Hairlines are 1px. Dotted leaders fill the gap between a title and its date.
- Generous vertical breathing room; the layout should feel unhurried.

---

## Components (described by intent)

- **Header.** Name, a plain location label, a one-line honest tagline. No seal.
- **Featured bar.** The single accent strip = the latest post. Functional spotlight.
- **Section index.** Columns by type (Writing / Builds / Notes). Each row: title
  left, date or live-status leader between. Counts in the tab.
- **Status line.** A muted mono "now —" line (what you're actually working on)
  plus keyboard hints. Honest, low-key, human.
- **Post header.** Tracked eyebrow (`Writing · 08 Jun 2026`), large title, a
  one-line summary, a thin stat row (read time / stack / filed-under).
- **Project subdomains.** Each lives at `project.<domain>`; the index links out
  to them. They may share these tokens or diverge — they're their own surface.

---

## Anti-goals

- Spy/agency cosplay text of any kind. (Principle 1.)
- Heavy bold everywhere; "loud" poster energy. We tried it — too shouty.
- Cream-paper / editorial-serif warmth. Read as soft; not this.
- Gradients, drop shadows, glow, stacked cards.
- Markdown-rendered clutter inside the reading column.
- Dark mode treated as a color inversion afterthought.

---

## Left open (decide later, against real content)

- Whether to ship the light cut at launch or only dark.
- The backdrop photo(s): one per section? one sitewide? rotating subject —
  the Sound, a circuit board, fog?
- Final type pick (Barlow vs alternatives that hold the same brief).
- How much the project subdomains inherit vs. depart from this system.
- Post format on disk (the thing that makes "drop a note" feel frictionless) —
  belongs in a *build* spec, not this design one.
