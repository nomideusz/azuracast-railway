FROM ghcr.io/azuracast/azuracast:latest

# The in-app updater needs the sidecar updater container + docker.sock,
# neither of which exists on Railway. Updates happen by redeploying instead.
ENV ENABLE_WEB_UPDATER=false

COPY 00_railway_volumes.sh /etc/my_init.d/00_railway_volumes.sh
COPY 99_railway_fixups.sh /etc/my_init.d/99_railway_fixups.sh
RUN chmod +x /etc/my_init.d/00_railway_volumes.sh /etc/my_init.d/99_railway_fixups.sh
