# Use Orbstack on Mac

Date: 2025-05-22

Status: accepted

## Context

On Orbstack, there are some issues with binding to a direct IP address.
(ie: `192.168.42.55:80:80` rather than just `80:80`)

Docker Desktop doesn't have those issues.

However, Docker Desktop is so much less efficient that it causes my mac to have its fans on 24/7.

### Why not run linux?

This laptop that I am using is occasionally used to play games when friends come over, or as a workstation.

So while I would love to run linux and avoid these issues, I do need to keep it as a mac for now.

## Decision

Use orbstack and don't bind on any specific IP Addresses.

## Consequences

This doesn't let us expose things "just" to tailscale or just to my local network, but the tradeoff in performance is worth it.
