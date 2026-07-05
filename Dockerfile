FROM rust:1 AS build

WORKDIR /app

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get -y install --no-install-recommends ca-certificates tzdata musl-tools && \
    rm -rf /var/lib/apt/lists/*

RUN rustup target add x86_64-unknown-linux-musl

COPY . .

ENV RUSTFLAGS="-C target-feature=+crt-static"
RUN CARGO_NET_GIT_FETCH_WITH_CLI=true cargo build --release --target x86_64-unknown-linux-musl && \
    mkdir -p /app/microbin_data

FROM alpine:latest

WORKDIR /app

RUN apk add --no-cache ca-certificates

COPY --from=build /app/target/x86_64-unknown-linux-musl/release/microbin /usr/bin/microbin

RUN adduser -D -h /app microbin && \
    mkdir -p /app/microbin_data && \
    chown microbin:microbin /app/microbin_data

USER microbin:microbin

VOLUME ["/app/microbin_data"]
EXPOSE 8080
ENTRYPOINT ["/usr/bin/microbin"]
