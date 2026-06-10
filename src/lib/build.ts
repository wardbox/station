import { execSync } from 'node:child_process';

// Honest build telemetry - real values, resolved once at build time.
// REV is the actual short commit; BUILT is when this image was produced.
// Nothing here is invented (design-spec Principle 1).
const run = (cmd: string, fallback: string) => {
  try {
    return execSync(cmd, { stdio: ['ignore', 'pipe', 'ignore'] })
      .toString()
      .trim();
  } catch {
    return fallback;
  }
};

// In CI the real commit arrives as PUBLIC_REV (the runtime image has no .git);
// locally we read it straight from git. Either way it's the honest commit.
const envRev = process.env.PUBLIC_REV?.trim();
export const rev = envRev
  ? envRev.slice(0, 7)
  : run('git rev-parse --short HEAD', 'dev');

const d = new Date();
const pad = (n: number) => String(n).padStart(2, '0');
const mon = d.toLocaleString('en-GB', { month: 'short' });
// e.g. "08 JUN 02:14"
export const builtLabel =
  `${pad(d.getDate())} ${mon} ${pad(d.getHours())}:${pad(d.getMinutes())}`.toUpperCase();
