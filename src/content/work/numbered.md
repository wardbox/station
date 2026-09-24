---
title: numbered
summary: A League of Legends trading card site built on real games. Every player gets a card from their match history, and beating your lane opponent gets you a print of theirs.
stack: [bun, hono, react, drizzle, postgres, xgboost, k3s, argo cd]
domain: numbered.gg
url: https://numbered.gg
status: offline
image: /work/numbered-cards.png
started: 2026-09
order: 1
---

## What it is

numbered turns your League games into a trading card. Every player gets one card built from their match history, and it updates as you play. Once you claim your account, every game you win against your lane opponent prints a copy of their card for you. Prints come sealed in packs, and each one carries a short verdict on what decided the game it came from.

I built it in about three weeks in September 2026. Riot rejected the production API key, so the site is offline for now. More on that at the bottom.

![The landing: the wordmark drawn in digits and a ring of cards turning](/work/numbered-landing.jpg)

## The card

The banner has your rank, region and queue, and the champion splash is the art. Under that are five skill scores from 0 to 100: laning, deaths, objectives, vision and damage. Each one is your percentile against players in the same role and tier.

You also get a playstyle label. I clustered players on the crawled ladder into six groups by how they play and the card names the one you land in.

The last piece is the verdict from your most recent game, priced off the timeline. Something like "Lost from ahead. 87% to win at 14:00. Biggest swing: the cloud dragon at 30:43, about a fifth of the game."

What you won't see is a model guessing your rank. Riot's policy doesn't allow it and I agree with them on that one.

![A player's card page: the live card, drag to spin, downloads for the front and back](/work/numbered-card.jpg)

![The profile behind the card: record, the latest ruling, every game with its verdict and win chance curve](/work/numbered-profile.jpg)

## Prints and packs

A print happens when you've claimed your account and win a game against your lane opponent. Ranked counts, and so do normals where everyone has a position. Your opponent doesn't need to have claimed anything, their card prints for you either way. Three prints make a pack.

Each print rolls a tier at fixed odds, borrowed from real Pokémon pack rates: Common, Uncommon, Reverse Holo, Holo, Illustration Rare, Special Illustration Rare and Hyper Rare. Inside each tier there's a second roll for the foil pattern, so a Hyper Rare can come out rainbow or as a gold framed secret. The foil is a gradient stack over the art and it tilts with the card.

The top two tiers sometimes pull vintage art instead of a skin. That's an old base splash, the 2009 to 2013 classics where a champion has them and older patch splashes where they don't. A vintage is as likely as any single skin.

Claiming your account also gets you a welcome pack of three prints from ranked solo wins that are already on file. Prints have no price and you can't trade them.

Every print gets its own page, and if you paste the link into a chat it shows a rendered picture of the card.

![A print's own page: an illustration rare of a Chinese-client player, the game it was printed from underneath](/work/numbered-print.jpg)

## Collection, shelf, wall

Your collection shows one card per player you hold, with your best print face up and a count of the rest. You can search it or filter by tier, language, rank and whether the player has claimed.

The shelf is three graded cases on a concrete mantel with light coming in from a window. You drag cases to swap them around, and if you take one down the slot stays empty.

The wall lists every claimed player, sorted by how many people hold their card. Players who haven't claimed never show up in any list.

There are also sets, one per season, and a legend page that names every part of a card. And the card maker at /make lets you build a card from any splash and share it as a link without an account.

![The wall: claimed players ranked by how many hold their card](/work/numbered-wall.jpg)

![The card maker: a card from any splash, any foil, any words](/work/numbered-make.jpg)

## How it works

Every Riot API call goes through whisper, my own wrapper, which rate limits per region and per method. Matches never change once they're played, so each one gets fetched once and kept. A single Bun worker polls a jobs table in Postgres, and a crawl fills every rank bucket so the percentiles have real players behind them.

Each game timeline turns into a row of features stamped with the extractor version, so I can always rebuild them from the raw data. The win probability model is XGBoost. I train it in Python inside a Docker container, export the trees, and walk them in TypeScript at request time. To price an event it compares the win chance with and without that event's gold. The verdicts are templates with only the numbers filled in by the model, so there's no LLM anywhere in the request path.

Player IDs stay on the server. Riot forwards GDPR requests, so deleting a player cascades through every table. Raw match data lives in a Tigris bucket. While it was up the site ran on one k3s node, with Argo CD deploying digest pinned images from CI.

![A match page: the verdict, the win chance curve with every priced event on it, the two costliest deaths with the damage that killed you](/work/numbered-match.jpg)

## Design

Warm concrete grays, no border radius, Geist at weight 300 for display type and monospace uppercase labels. Red means a loss or a cost and green means a gain, and gold only shows up on the rarity symbols of the top tiers. It's dark by default with a light theme if you want it, and the cards stay on dark stock in both.

![The legend: every part of a print named, and the odds of each tier](/work/numbered-legend.jpg)

## What happened

Riot rejected the production API key on 2026-09-18 with one line: "not a use case we can support at this time." Running a public site on a development key is against their terms, so I took it offline three days later and opened a ticket asking which part of the product is the problem. The data is all still there. If the key comes through, the prints come back with it.
