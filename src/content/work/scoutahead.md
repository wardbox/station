---
title: Scout Ahead
summary: A real time League of Legends draft tool. Two captains draft from one shared link, spectators watch, and the server keeps the timer.
stack: [wasp, react, node, prisma, postgres, redis, socket.io, stripe, fly.io]
domain: scoutahead.pro
url: https://scoutahead.pro
status: live
image: /work/scoutahead.png
started: 2025-01
order: 2
---

## What it is

Scout Ahead is a draft screen for amateur leagues and scrim teams. You create a series and share one link. Whoever opens it picks a side and drafts, and anyone else can watch live. You don't need an account to create, draft or spectate. It's been live since January 2025.

## Features

- Best of 1, 3, 5 or 7, with sides picked each game. The series winner is worked out from the game results and never stored on its own.
- Fearless draft per game. Any champion picked in an earlier game of the series is locked, even if that earlier game wasn't fearless. Ironman locks bans too.
- The full 20 action pick and ban sequence with phase timers. If a timer runs out, whatever champion the captain was hovering locks in. If they weren't hovering anything, the slot stays empty.
- Corrections for empty slots. A captain proposes a champion for the slot and the other captain accepts or declines. Nothing gets rewound.
- Proposals to flip fearless on or off, ready checks, and a list of disabled champions the series creator picks up front. If you disconnect with a proposal pending, it comes back when you reconnect.
- Scrim block, which plays every game of the series even after one team has clinched it.
- A series page with results. Anyone in the room can report a winner, each team confirms for its own record, and a result from a more trusted source replaces a self reported one where you can see it.
- Teams with invites and rosters. Each member decides whether their match data gets shared with the team and whether it's public, and the team owner can't override that.
- A champion tier list, plus a broadcast layout built for OBS at 1080p with a link builder for casters.
- A public API for league organizers. Billing is per draft, 2000 a month on the plan, and anything over that gets metered through Stripe.
- Discord sign in if you want your series saved, and reports and moderation for when people misbehave.

## How it works

The timer was the hardest part. Postgres stores the moment each timer expires, and the remaining time gets calculated from that instead of counted down in memory. That way it survives a restart and every client sees the same number. Redis holds a best effort lock so one server instance owns the countdown, and it also keeps the shared hover and ready state. The socket.io Redis adapter sends events across instances. To make sure an auto pick only happens once, there's a unique constraint on game and position, so if two instances fire at the same time only one write goes through.

On startup the server looks for games in progress with a live timer and either resumes the countdown or makes the auto pick. It never waits on the Redis lock to do this, it takes the lock over.

Champion data syncs from Data Dragon into Postgres every hour, and splash art gets copied to S3 once a day. The product is registered and approved with Riot, and I've applied for a production key with Riot sign on.

## Design

I call the design language Cinema. Graded splash art does most of the work, one glacier accent colour covers every highlight, and nothing glows unless it's changing. The draft screen is plain on purpose because it's the screen people put in OBS.
