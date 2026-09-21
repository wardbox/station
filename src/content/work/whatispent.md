---
title: what i spent
date: 2025-04-11
summary: Personal finance with one question. What did I spend today, this week and this month. Bank sync through Plaid, billing through Stripe.
stack: [wasp, react, node, prisma, postgres, plaid, stripe, fly.io]
domain: whatispent.com
repo: https://github.com/wardbox/whatispent
status: archived
image: /work/whatispent.png
---

## What it is

Budgeting apps want you to categorize, plan and set goals. I wanted three numbers: what I spent today, this week and this month, pulled from my bank so I never type anything. Sign in with Google, link a bank, pay $4.99 a month. It ran from April 2025 to July 2026.

## Features

- A dashboard with today, this week and this month, and a chart comparing the last few months.
- Spending by category, using Plaid's personal finance categories.
- A full transaction list with merchant, account and pending state.
- Multiple banks per user. Each account under an institution has a tracked toggle, so a mortgage account does not count as spending.
- Unlinking an institution removes its data.
- A free trial, then Stripe Checkout and the customer portal for everything after.
- An admin panel.

## How it works

Plaid Link runs in the browser and returns a public token. The server exchanges it for an access token and encrypts it before writing to the database. The plaintext token is never stored.

Transactions come through Plaid's sync endpoint with a cursor per institution, so every pull is a diff of added, modified and removed rows. Plaid webhooks fire when an institution has updates and the sync runs on its own. Stripe webhooks keep the subscription status on the user current and the pages gate on it.

Everything hangs off the user with cascading deletes. Removing an account removes its institutions, accounts and transactions in one statement.

## What happened

I shut it down in July 2026. The code is public.
