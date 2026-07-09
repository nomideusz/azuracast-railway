#!/bin/bash
# Stock init scripts do `chown -R` on paths we replaced with symlinks;
# GNU chown -R doesn't traverse a symlink argument, so redo it on the target.

[ -d /data ] || exit 0

chown -R azuracast:azuracast /data/sftpgo 2>/dev/null || true

exit 0
