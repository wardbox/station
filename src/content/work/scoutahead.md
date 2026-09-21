---
title: Scout Ahead
summary: A real time League of Legends draft tool. Two captains, one link, fearless mode, spectators, and a timer the server owns.
stack: [wasp, react, node, prisma, postgres, redis, socket.io, stripe, fly.io]
domain: scoutahead.pro
url: https://scoutahead.pro
status: live
image: /work/scoutahead.png
started: 2024-08
order: 2
---

## What it is

Amateur leagues and scrim teams run pick and ban over Discord and a spreadsheet. Scout Ahead gives them the real draft screen. Create a series, share one link, and whoever opens it picks a side and drafts. Spectators watch live. No account is required for any of it. Live since January 2025.

## Features

- Best of 1, 3, 5 or 7. Sides swap between games. The series winner is computed from game results and never stored.
- Fearless draft per game. Champions picked in any earlier game of the series are locked, whether or not the earlier game was fearless. Ironman extends the lock to bans.
- The full 20 action sequence with phase timers. When a timer expires the previewed champion locks, or an empty slot if there was no preview.
- Corrections. A captain proposes a champion for a missed slot and the opposing captain accepts or declines. Nothing rewinds.
- Fearless flip proposals, ready checks, a scrim block to keep a set of champions out of the whole series, and replay of any pending proposal on reconnect.
- A series page with results. Anyone in the room reports a winner, each team confirms for its own record, and a result from a higher trust source replaces a self reported one visibly.
- Teams with invites and rosters. Sharing match data is a per member choice with two flags. Team owners cannot override it.
- A champion tier list and a broadcast layout built for OBS at 1080p, with a link builder for casters.
- A public API for league organizers. Drafts are the billing unit, 2000 a month on the plan, with overage metered through Stripe.
- Discord sign in for people who want their series kept. Reports and moderation for people who misbehave.

## How it works

The timer was the hard part. The source of truth is an absolute expiry timestamp in Postgres. Remaining time is computed from it and never decremented in memory, so it survives restarts and reads the same on every client. Redis holds a best effort lock so one server instance owns the countdown, plus shared preview and ready state. The socket.io Redis adapter fans events across instances. Exactly once auto action comes from a unique constraint on game and position: if two instances fire, one write wins.

On startup the server queries in progress games with a live timer and resumes or auto acts. The Redis lock stays out of the recovery path on purpose.

Champion data and splash art sync from Data Dragon into S3 on a schedule. The product is registered and approved with Riot. A production key with Riot sign on is in review.

## Design

The design language is called Cinema. Graded splash art carries the identity, one glacier accent colour handles every highlight, and nothing static glows. The draft screen puts function first because it is the screen people put in OBS.
