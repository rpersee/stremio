ARG NODE_VERSION=16

FROM node:${NODE_VERSION}-alpine as builder

RUN apk add --no-cache curl git jq

WORKDIR /stremio-web

ARG STREMIO_VERSION=

RUN if [ -z "${STREMIO_VERSION}" ]; then \
        STREMIO_VERSION=$(curl -fsSL "https://api.github.com/repos/Stremio/stremio-web/tags" | jq -r 'first.name'); \
    fi && \
    git clone --branch "${STREMIO_VERSION}" --depth 1 https://github.com/Stremio/stremio-web.git .

RUN yarn install

RUN yarn build

FROM node:${NODE_VERSION}-alpine

WORKDIR /app

COPY --from=builder /stremio-web/build /app/dist

RUN yarn global add http-server

EXPOSE 8080

ENTRYPOINT [ "http-server", "dist" ]

CMD [ "-p", "8080" ]
