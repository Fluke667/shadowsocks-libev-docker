FROM golang:alpine AS golang

ENV V2RAY_PLUGIN_VERSION v1.1.0
ENV GO111MODULE on
ARG KCP_VERSION=20190611
ARG KCP_URL=https://github.com/xtaci/kcptun/releases/download/v${KCP_VERSION}/kcptun-linux-amd64-${KCP_VERSION}.tar.gz
ENV OBFS_URL https://github.com/shadowsocks/simple-obfs.git

# Build v2ray-plugin
RUN apk add --no-cache git build-base \
    && mkdir -p /go/src/github.com/shadowsocks \
    && cd /go/src/github.com/shadowsocks \
    && git clone https://github.com/shadowsocks/v2ray-plugin.git \
    && cd v2ray-plugin \
    && git checkout "$V2RAY_PLUGIN_VERSION" \
    && go get -d \
    && go build

FROM alpine

MAINTAINER Fluke667 <Fluke667@gmail.com>
# Define TimeZone
ARG TIMEZONE=Europe/Berlin

ENV SHADOWSOCKS_LIBEV_VERSION v3.3.0

# Install dependencies
RUN set -ex \
    && apk add --no-cache --virtual .build-deps \
               autoconf \
               curl \
               automake \
               build-base \
               libev-dev \
               libtool \
               linux-headers \
               udns-dev \
               libsodium-dev \
               mbedtls-dev \
               pcre-dev \
               tar \
               tzdata \
               udns-dev \
               c-ares-dev \
               nano \
               git \
    && cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    # Build shadowsocks-libev
    && mkdir -p /tmp/build-shadowsocks-libev \
    && cd /tmp/build-shadowsocks-libev \
    && git clone https://github.com/shadowsocks/shadowsocks-libev.git \
    && cd shadowsocks-libev \
    && git checkout "$SHADOWSOCKS_LIBEV_VERSION" \
    && git submodule update --init --recursive \
    && ./autogen.sh \
    && ./configure --disable-documentation \
    && make install \
    && ssRunDeps="$( \
        scanelf --needed --nobanner /usr/local/bin/ss-server \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    && apk add --no-cache --virtual .ss-rundeps $ssRunDeps \
    && cd / \
    && rm -rf /tmp/build-shadowsocks-libev \
    # Delete dependencies
    && apk del .build-deps \


# Build kcptun
     && curl -sSL ${KCP_URL} \
     && tar xz server_linux_amd64 \
     && mv server_linux_amd64 /usr/bin/ \
               
# Build simple-obfs
    && cd /tmp \
    && git clone ${OBFS_URL} \
    && (cd simple-obfs \
    && git submodule update --init --recursive \
    && ./autogen.sh \
    && ./configure --disable-documentation \
    && make install) 


# Copy v2ray-plugin
COPY --from=golang /go/src/github.com/shadowsocks/v2ray-plugin/v2ray-plugin /usr/local/bin


# Shadowsocks environment variables
ENV SERVER_ADDR 0.0.0.0 \
SS_SERVER_PORT 8388 \
SS_PASSWORD ChangeMe \
SS_METHOD chacha20-ietf-poly1305 \
SS_TIMEOUT 600 \
SS_DNS_ADDRS 1.1.1.1,1.0.0.1 \
SS_ARGS -u \
KCP_PORT=${KCP_PORT:-5021} \
KCP_KEY=${KCP_KEY:-kcptun} \
KCP_MODE=${KCP_MODE:-fast} \
KCP_CRYPT=${KCP_CRYPT:-salsa20} \
KCP_MTU=${KCP_MTU:-1350} \
KCP_DSCP=${KCP_DSCP:-46}

EXPOSE $SS_SERVER_PORT/tcp $SS_SERVER_PORT/udp
EXPOSE ${KCP_PORT}/udp

# Start shadowsocks-libev server
CMD exec ss-server \
    -s $SS_SERVER_ADDR \
    -p $SS_SERVER_PORT \
    -k $SS_PASSWORD \
    -m $SS_METHOD \
    -t $SS_TIMEOUT \
    -d $SS_DNS_ADDRS \
    --reuse-port \
    --fast-open \
    --no-delay \
    $SS_ARGS
