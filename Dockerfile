# --- Build stage -------------------------------------------------------------
# Full Node toolchain to compile the static site. None of this ships; only the
# built /dist crosses into the runtime stage (build-spec Principle 8: the blog
# stays featherweight).
FROM node:22-slim AS build
WORKDIR /app

# pnpm via corepack, pinned for reproducible installs.
RUN corepack enable && corepack prepare pnpm@10.34.2 --activate

# Install deps first so this layer caches until the lockfile actually changes.
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN pnpm install --frozen-lockfile

# Build telemetry is honest (design-spec Principle 1): the real commit is passed
# in from CI as a build-arg, since the runtime image carries no .git.
ARG REV=dev
ENV PUBLIC_REV=$REV

COPY . .
RUN pnpm build

# --- Runtime stage -----------------------------------------------------------
# A tiny static file server and nothing else. Content is baked in at build time;
# there is no Node, no app server, no state.
FROM caddy:2-alpine

# The upstream Caddy binary carries cap_net_bind_service for low ports. We serve
# on 8080 and drop all capabilities in Kubernetes, so remove the file capability
# or the kernel refuses to exec it under no-new-privileges/cap-drop ALL.
RUN apk add --no-cache libcap && setcap -r /usr/bin/caddy && apk del libcap

COPY Caddyfile /etc/caddy/Caddyfile
COPY --from=build /app/dist /srv

# Serve on an unprivileged port so the pod can run as non-root.
EXPOSE 8080
USER 1000:1000
