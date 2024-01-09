ARG DEBIAN_CODENAME=bullseye
ARG NODE_VERSION=14

FROM node:${NODE_VERSION}-${DEBIAN_CODENAME}-slim

COPY setup-jellyfin-repository.sh /tmp/setup-jellyfin-repository.sh

ARG JELLYFIN_VERSION=4.4.1-4

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        gnupg \
        ca-certificates \
        procps \
    && /tmp/setup-jellyfin-repository.sh \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        "jellyfin-ffmpeg=${JELLYFIN_VERSION}-$(awk -F'=' '/^VERSION_CODENAME=/{print $NF}' /etc/os-release)" \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV PATH="${PATH}:/usr/lib/jellyfin-ffmpeg" 

ENV APP_PATH=/app

WORKDIR ${APP_PATH}

ARG STREMIO_VERSION=

RUN if [ -n "${STREMIO_VERSION}" ]; then \
        curl -fsSL -O "https://dl.strem.io/server/v${STREMIO_VERSION}/desktop/server.js"; \
    else \
        curl -fsSL -O "$(curl -fsSL https://raw.githubusercontent.com/Stremio/stremio-shell/master/server-url.txt)"; \
    fi

EXPOSE 11470 12470

ENV CASTING_DISABLED=1

ENTRYPOINT [ "node", "server.js" ]