// Site identity - honest words only (design-spec Principle 1).
// Edit these in one place; the chrome reads from here.
export const site = {
  name: 'station',
  // Person + a plain location label. No seal, no theatre.
  owner: 'Dylan',
  location: 'Kingston, WA',
  // Real coordinates for the telemetry bar - true, but deliberately coarse
  // (~1 km). Honest without pointing strangers at the doorstep.
  coords: '47.79°N 122.49°W',
  // One honest line. What this place is, said plainly.
  tagline: 'things i build and break',
  // The muted "now -" readout: what you are actually working on.
  now: 'touching grass',
  // Keyboard hints shown in the status line. These are really wired on the index.
  keys: [
    { kc: 'J / K', label: 'move' },
    { kc: '↵', label: 'open' },
  ],
} as const;
