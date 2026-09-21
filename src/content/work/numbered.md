---
title: numbered
summary: A League of Legends trading card site backed by real ranked games. One card per player, a print of the opponent when you win, a verdict on every print.
stack: [bun, hono, react, drizzle, postgres, xgboost, k3s, argo cd]
domain: numbered.gg
url: https://numbered.gg
repo: https://github.com/wardbox/loltrack
status: offline
image: /work/numbered-cards.png
started: 2026-09
order: 1
---

## What it is

Stats sites show you the numbers from a game and stop there. numbered turns the game into a card. You get one card, built from your ranked history, and it updates as you play. When you beat a player who has claimed their account, their card prints for you. The print comes sealed in a pack with a one line verdict on what decided the game.

I built it in three weeks in September 2026. Riot rejected the production API key, so the site is offline for now. Details at the bottom.

## The card

- Rank, region and queue on the banner. The champion splash is the art.
- Five skill scores from 0 to 100. Each is your percentile against players in your role and tier: laning, deaths, objectives, vision, damage.
- A playstyle label from six behaviour clusters fit over the crawled ladder.
- The verdict from your last game, priced from the timeline. "Lost from ahead. 87% to win at 14:00. Biggest swing: the cloud dragon at 30:43, about a fifth of the game."
- No rank estimates from a model. Riot policy prohibits them and I think the rule is right.

## Prints and packs

- Win a ranked game against a claimed player and their card prints for you in a sealed pack.
- Rarity rolls at fixed odds. Foil tiers run from reverse holo up to illustration rare and a gold framed rare secret. The foil is a gradient stack over the art and tilts with the card.
- Vintage prints use the 2009 to 2013 base splashes and are as rare as a single skin.
- Claiming your account grants a welcome pack of three prints from games you already won. Prints have no price and cannot be traded.
- Every print has its own page. Pasting the link into a chat shows a rendered picture of the card.

## Collection, shelf, wall

- Your collection lists every print you hold, filterable by champion and rarity.
- The shelf holds three prints in graded cases on a concrete mantel, lit by a window. Drag to reorder. Take one down and the slot stays open.
- The wall is a directory of every claimed player, sorted by how many of their prints are held. Unclaimed players never appear in any index.
- Sets group prints by season. The legend page names every part of a card.
- The card maker at /make builds a card from any splash and shares it as a link. No account needed.

## How it works

Every Riot API call goes through whisper, my own wrapper, with a rate limiter keyed on region and method. Matches are immutable, so each one is fetched once and stored forever. One Bun worker polls a jobs table in Postgres. A crawl fills every rank bucket so the percentiles have a real cohort behind them.

Each game timeline becomes a feature row with a version stamp, and re-extraction from the raw data is always possible. An XGBoost win probability model, trained in Python inside a Docker service, runs in TypeScript by walking the exported trees. It prices each event as a swing in win probability, with the event's gold removed for the counterfactual. Verdicts are templates. The words are fixed and only the numbers come from the model. There is no LLM in the request path.

Player IDs never leave the server. Deleting a player cascades through every table, since Riot forwards GDPR requests. Raw match data lives in a Tigris bucket. The site runs on one k3s node with Argo CD deploying digest pinned images from CI.

## Design

Warm concrete grays, no border radius, Geist 300 for display type, monospace uppercase labels, red as the only signal colour. Dark by default with a light theme on request. Cards keep their dark stock in both.

## What happened

Riot rejected the production API key on 2026-09-18 with one line: "not a use case we can support at this time." A public site on a development key is outside their terms, so I took it offline three days later and opened a ticket asking which part of the product is the problem. The data is intact. If it comes back, the prints come back with it.
