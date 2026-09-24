---
title: Spotishell
summary: The Spotify Web API as a PowerShell module. About 80 cmdlets, OAuth handled for you, and playback control from a terminal.
stack: [powershell, spotify web api, pester]
domain: PowerShell Gallery
url: https://www.powershellgallery.com/packages/Spotishell
repo: https://github.com/wardbox/spotishell
status: repo
image: /work/spotishell.png
started: 2018-12
order: 4
---

## What it is

A PowerShell module for the Spotify Web API. You can search, manage playlists and your library, and control playback on any of your devices, all through cmdlets with proper parameters and help. Install it from the PowerShell Gallery, register a Spotify app, and you're set.

## Features

- About 80 public cmdlets covering most of the Web API: search, albums, artists, tracks, playlists, shows, your library and the player.
- OAuth is handled for you. A local redirect on 127.0.0.1 catches the code, and tokens refresh on their own.
- Start, pause, skip, seek and add to the queue on whichever device is active.
- Back up your library and playlists to files and restore them later.
- Help for every cmdlet, Pester tests, and PSScriptAnalyzer running in CI.

## How it works

You register your Spotify app once with a few setup cmdlets, and the module stores those credentials locally. Token refresh happens in private functions you never call yourself. Almost every public cmdlet builds a request and passes it to one private function that makes the HTTP call, so adding an endpoint only takes a few lines. It's published on the PowerShell Gallery.
