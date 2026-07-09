# Deploy and Host AzuraCast on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/azuracast?utm_medium=integration&utm_source=button&utm_campaign=azuracast)

[AzuraCast](https://www.azuracast.com/) is a self-hosted, all-in-one web radio management suite: stream with Icecast, automate playlists with Liquidsoap, broadcast live from your browser with WebDJ, and track listener analytics — all from one dashboard.

## About Hosting AzuraCast

AzuraCast normally expects a full Docker Compose stack with ~10 named volumes. This template adapts the official all-in-one image to Railway as a single service: a small init script relocates all persistent data (database, station media, uploads, backups) onto one Railway volume mounted at `/data`, the embedded MariaDB root password is auto-generated, and TLS is terminated by Railway's edge. First boot initializes the database and takes about a minute; after that you land on AzuraCast's setup wizard to create your admin account and first station.

## Common Use Cases

- Run an internet radio station with automated playlists, scheduling, and jingles
- Broadcast live shows from the browser with WebDJ or hand off between rotating DJs
- Host a podcast/community station with listener analytics and stream history

## Dependencies for AzuraCast Hosting

- None — MariaDB, Redis, Icecast, and Liquidsoap are all embedded in the single service

### Deployment Dependencies

- [AzuraCast documentation](https://docs.azuracast.com/)
- [Template source on GitHub](https://github.com/nomideusz/azuracast-railway)

### Implementation Details

After deploying, complete these two steps:

1. Open your Railway domain and finish the setup wizard.
2. In **Administration → System Settings → Services**, enable **Use Web Proxy for Radio** so listener streams work through your Railway HTTPS domain without extra ports.

How the single-volume adaptation works: `Dockerfile` extends `ghcr.io/azuracast/azuracast:latest` with two init scripts — `00_railway_volumes.sh` symlinks every persistent path (e.g. `/var/lib/mysql`, `/var/azuracast/stations`) into `/data/...` before any service starts, and `99_railway_fixups.sh` re-applies file ownership that stock scripts miss because of the symlinks. The in-app updater is disabled; update by redeploying (each build pulls the latest AzuraCast release).

Notes and limits:

- **Live DJ via external encoders** (BUTT, Mixxx) needs a Railway TCP proxy to the station's Icecast port; browser WebDJ works out of the box.
- **SFTP uploads** (port 2022) also need a TCP proxy; the web uploader works without one.
- **Transcoding is CPU-only** (no GPU on Railway) — fine for typical radio bitrates.
- Volume size is plan-dependent; a large music library needs a plan with a bigger volume cap.

## Why Deploy AzuraCast on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying AzuraCast on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
