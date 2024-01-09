ARG DEBIAN_CODENAME=bullseye
ARG NODE_VERSION=14

FROM node:${NODE_VERSION}-${DEBIAN_CODENAME} as builder

RUN apt-get update && apt-get install -y jq

WORKDIR /stremio-web

ARG STREMIO_VERSION=

RUN if [ -z "${STREMIO_VERSION}" ]; then \
        STREMIO_VERSION=$(curl -fsSL "https://api.github.com/repos/Stremio/stremio-web/tags" | jq -r 'first.name'); \
    fi && \
    git clone --branch "${STREMIO_VERSION}" --depth 1 https://github.com/Stremio/stremio-web.git .

RUN npm install --production

RUN npm run build

FROM node:${NODE_VERSION}-${DEBIAN_CODENAME}-slim

WORKDIR /app

COPY --from=builder /stremio-web/build /app/dist

RUN npm install -g http-server

EXPOSE 8080

ENTRYPOINT [ "http-server", "dist" ]

CMD [ "-p", "8080" ]
