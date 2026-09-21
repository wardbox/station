import { execSync } from 'node:child_process';

// Honest build telemetry: the real commit and the day the image was built.
// In CI the commit arrives as PUBLIC_REV (the runtime image has no .git);
// locally it comes straight from git.
const run = (cmd: string, fallback: string) => {
  try {
    return execSync(cmd, { stdio: ['ignore', 'pipe', 'ignore'] }).toString().trim();
  } catch {
    return fallback;
  }
};

const envRev = process.env.PUBLIC_REV?.trim();
export const rev = envRev ? envRev.slice(0, 7) : run('git rev-parse --short HEAD', 'dev');
export const builtDate = new Date().toISOString().slice(0, 10);
