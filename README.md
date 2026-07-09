# AzuraCast on Railway

[AzuraCast](https://www.azuracast.com/) is a self-hosted, all-in-one web radio management suite: stream with Icecast, automate playlists with Liquidsoap, broadcast live from your browser with WebDJ, and track listener analytics — all from one dashboard.

This template runs the official all-in-one AzuraCast image as a single Railway service, adapted for Railway's platform:

- **Single volume**: AzuraCast normally expects ~10 Docker volumes. A small init script relocates all persistent data (database, station media, uploads, backups) onto one Railway volume mounted at `/data`.
- **Web-based streaming**: Railway exposes one HTTPS domain per service. After setup, enable **"Use Web Proxy for Radio"** (Administration → System Settings → Services) so listener streams and station management work through your Railway domain without extra ports.
- **No sidecar updater**: the in-app updater is disabled; update by redeploying the service (the build pulls the latest AzuraCast release).

## First-time setup

1. Deploy the template and wait for the service to become healthy (first boot initializes the database, ~1–2 minutes).
2. Open your Railway domain — you'll land on the AzuraCast setup wizard to create your admin account and first station.
3. In **Administration → System Settings → Services**, enable **Use Web Proxy for Radio**.

## Configuration

| Variable | Purpose |
|---|---|
| `MYSQL_ROOT_PASSWORD` | Root password for the embedded MariaDB (generated automatically). |

The embedded MariaDB and Redis live inside the container and are not exposed publicly.

## Notes & limits

- **Live DJ connections**: browser-based WebDJ works out of the box. Connecting external encoder software (BUTT, Mixxx) over raw Icecast ports requires adding a Railway TCP proxy to the station's port.
- **SFTP uploads** (port 2022) also need a TCP proxy; the web uploader works without one.
- **Transcoding is CPU-only** (Railway has no GPU) — fine for typical radio bitrates.
- Volume size is plan-dependent on Railway; a music library needs space, so check your plan's volume cap.

## How it works

`Dockerfile` extends `ghcr.io/azuracast/azuracast:latest` with two init scripts:

- `00_railway_volumes.sh` — runs before any service starts; symlinks every persistent path (e.g. `/var/lib/mysql`, `/var/azuracast/stations`) into `/data/...`, preserving first-boot contents.
- `99_railway_fixups.sh` — re-applies ownership that stock scripts miss because of the symlinks.
