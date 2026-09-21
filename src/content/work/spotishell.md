---
title: Spotishell
date: 2018-12-12
summary: The Spotify Web API as a PowerShell module. About 80 cmdlets, OAuth handled, playback from a terminal.
stack: [powershell, spotify web api, pester]
domain: PowerShell Gallery
url: https://www.powershellgallery.com/packages/Spotishell
repo: https://github.com/wardbox/spotishell
status: archived
image: /work/spotishell.png
---

## What it is

A PowerShell module covering the Spotify Web API. Search, playlists, your library and playback on any device, all as cmdlets with proper parameters and help. Install it from the gallery, register a Spotify app, and go.

## Features

- Every endpoint in the Spotify Web API reference, about 80 public cmdlets.
- OAuth handled for you. A local redirect on 127.0.0.1 catches the code and tokens refresh on their own.
- Start, pause, skip, seek and queue on whichever device is active.
- Back up your library and playlists to files and restore them.
- Help for every cmdlet, Pester tests, PSScriptAnalyzer clean.

## How it works

Private functions own the credential store and token refresh. Public cmdlets build a request and hand it to one HTTP wrapper, so adding an endpoint is a few lines. It is published on the PowerShell Gallery and people still install it.
