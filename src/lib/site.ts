// Site identity - honest words only (design-spec Principle 1).
// Edit these in one place; the chrome reads from here.
export const site = {
  name: 'station systems',
  // Person + a plain location label. No seal, no theatre.
  owner: 'Dylan',
  location: 'Kingston, WA',
  // Real coordinates for the telemetry bar - true, but deliberately coarse
  // (~1 km). Honest without pointing strangers at the doorstep.
  coords: '47.79°N 122.49°W',
  // One honest line. What this place is, said plainly.
  tagline: 'field notes',
  // The person behind it, for the landing intro.
  fullName: 'Dylan Kappler',
  role: 'Senior platform engineer at BetterComp. I build web apps on the side and care about how they look.',
  links: [
    { label: 'GitHub', href: 'https://github.com/wardbox' },
    { label: 'LinkedIn', href: 'https://linkedin.com/in/dylankappler' },
    { label: 'X', href: 'https://x.com/ward_box' },
  ],
  // The muted "now -" readout: what you are actually working on.
  now: 'touching grass',
  // Keyboard hints shown in the status line. These are really wired on the index.
  keys: [
    { kc: 'J / K', label: 'move' },
    { kc: '↵', label: 'open' },
  ],
} as const;
