#!/bin/bash
# AzuraCast expects ~10 named volumes; Railway allows one volume per service.
# This runs before any service starts (my_init.d, lexically first) and
# relocates every persistent path onto the single volume mounted at /data.

set -u

# No volume mounted (e.g. local run without -v): leave the image untouched.
[ -d /data ] || exit 0

link_dir() {
  local src="$1" name="$2" owner="$3"
  local tgt="/data/$name"
  mkdir -p "$tgt"
  if [ ! -L "$src" ]; then
    # First boot: preserve anything the image baked into the original path.
    if [ -d "$src" ] && [ -z "$(ls -A "$tgt")" ]; then
      cp -a "$src"/. "$tgt"/ 2>/dev/null || true
    fi
    rm -rf "$src" 2>/dev/null
    if [ -e "$src" ]; then
      # Path is a mountpoint (e.g. a runtime that honors VOLUME declarations
      # and mounted something here) — it's already persistent, leave it.
      echo "00_railway_volumes: $src is mounted, skipping relocation"
      return 0
    fi
    mkdir -p "$(dirname "$src")"
    ln -sfn "$tgt" "$src"
  fi
  # ponytail: chown -R only when top-level owner is wrong; a full recursive
  # chown over a large media library on every boot would stall startup.
  if [ "$(stat -c %U "$tgt")" != "${owner%%:*}" ]; then
    chown -R "$owner" "$tgt" 2>/dev/null || true
  fi
}

link_dir /var/lib/mysql                       mysql       mysql:mysql
link_dir /var/azuracast/stations              stations    azuracast:azuracast
link_dir /var/azuracast/backups               backups     azuracast:azuracast
link_dir /var/azuracast/storage/uploads       uploads     azuracast:azuracast
link_dir /var/azuracast/storage/shoutcast2    shoutcast2  azuracast:azuracast
link_dir /var/azuracast/storage/stereo_tool   stereo_tool azuracast:azuracast
link_dir /var/azuracast/storage/rsas          rsas        azuracast:azuracast
link_dir /var/azuracast/storage/geoip         geoip       azuracast:azuracast
link_dir /var/azuracast/storage/sftpgo        sftpgo      azuracast:azuracast
link_dir /var/azuracast/storage/acme          acme        azuracast:azuracast

exit 0
