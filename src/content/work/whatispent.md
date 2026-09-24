---
title: what i spent
summary: A personal finance app for one question, what did I spend today, this week and this month. Bank sync through Plaid, billing through Stripe.
stack: [wasp, react, node, prisma, postgres, plaid, stripe, fly.io]
domain: whatispent.com
repo: https://github.com/wardbox/whatispent
status: archived
image: /work/whatispent.png
started: 2025-04
order: 3
---

## What it is

I wanted to know what I spent today, this week and this month without typing anything in. So this app pulls transactions straight from your bank and shows you those three numbers. You signed in with Google, linked a bank and paid $4.99 a month after a free trial. It ran from April 2025 to July 2026.

![The landing page](/work/whatispent-landing.jpg)

## Features

- A dashboard with today, this week and this month, and a chart comparing up to the last twelve months.
- Spending by category, using Plaid's personal finance categories.
- A full transaction list with merchant, account and category. Pending transactions stay out of the totals until they post.
- More than one bank per user. Every account has a toggle for whether it counts, so a mortgage payment doesn't show up as spending.
- Unlinking a bank deletes its accounts and transactions.
- A 7 day free trial, then Stripe Checkout, with Stripe's customer portal for managing the subscription.
- An admin panel.

![The transaction list: merchant, category, account, amount, grouped by month](/work/whatispent-transactions.jpg)

## How it works

Plaid Link runs in the browser and hands back a public token. The server trades it for an access token and encrypts it before it goes in the database, so the plaintext token is never stored.

Transactions come in through Plaid's sync endpoint with a cursor for each bank, so the first pull backfills history and every pull after that is only what was added, changed or removed since the last one. Plaid sends a webhook when a bank has updates and the sync kicks off on its own. Stripe webhooks keep the subscription status on the user up to date, and the pages check it before showing anything.

All the data hangs off the user with cascading deletes, so removing a bank takes its accounts and transactions with it.

![The subscription page: one plan, Stripe's customer portal behind the button](/work/whatispent-subscription.jpg)

## What happened

I shut it down in July 2026. The code is public.
