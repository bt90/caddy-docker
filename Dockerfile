FROM golang:1.13.3-alpine3.10 as build

WORKDIR /src

# hadolint ignore=DL3018
RUN apk add --no-cache --no-progress \
        git \
        musl-dev \
        gcc \
        libc-dev \
        ca-certificates

ENV CADDY_VERSION=v2.0.0-beta6

RUN git clone -b $CADDY_VERSION https://github.com/caddyserver/caddy.git --depth 1

WORKDIR /src/caddy/cmd/caddy

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -tags netgo -ldflags '-extldflags "-static" -s -w' -o /caddy

FROM scratch

COPY --from=build /caddy /caddy
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs
COPY --from=build /etc/passwd /etc/passwd

ENTRYPOINT ["/caddy"]
CMD ["help"]
