FROM debian:stretch-slim
      
MAINTAINER Fluke667 <Fluke667@gmail.com>
ARG TIMEZONE=Europe/Berlin
ENV LINUX_HEADERS_VERSION 4.9.0-9
ENV SS_VERSION=3.2.0
ENV KCP_VERSION=20190515
ENV SS_URL=https://github.com/shadowsocks/shadowsocks-libev/releases/download/v${SS_VERSION}/shadowsocks-libev-${SS_VERSION}.tar.gz \
KCP_URL=https://github.com/xtaci/kcptun/releases/download/v${KCP_VERSION}/kcptun-linux-amd64-${KCP_VERSION}.tar.gz \
OBFS_URL=https://github.com/shadowsocks/simple-obfs.git \
V2RAY_URL=https://github.com/shadowsocks/v2ray-plugin.git

RUN set -x \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y curl wget ca-certificates libssl-dev git sudo nano software-properties-common apt-transport-https dirmngr build-essential tar kmod apt-utils gcc g++ make cmake  \
    && apt-get install --no-install-recommends --no-install-suggests -y apg libcap2-bin lsb-base init-system-helpers libc6 libcork16 libcorkipset1 libev4 libev-dev libmbedcrypto0 libmbedtls-dev libpcre3 libpcre3-dev libsodium18 libsodium-dev libudns0 autoconf automake libtool gettext pkg-config libmbedtls10 libmbedx509-0 libc-ares2 libc-ares-dev asciidoc xmlto golang-1.8-src golang-1.8-go
    
RUN set -x \
# Build shadowsocks-libev
    && cd /tmp  \
    && wget --no-check-certificate -O shadowsocks-libev-${SS_VERSION}.tar.gz ${SS_URL} \
    && tar zxf shadowsocks-libev-${SS_VERSION}.tar.gz \
    && cd shadowsocks-libev-${SS_VERSION} \
    && ./configure --disable-documentation \
    && make \
    && make install \
# Build v2ray plugin    
    && mkdir -p /go/src/github.com/shadowsocks \
    && cd /go/src/github.com/shadowsocks \
    && git clone ${V2RAY_URL} \
    && cd v2ray-plugin \
    && go get -d \
    && go build \
# Build kcptun plugin
    && cd /tmp  \
    && wget --no-check-certificate -O kcptun-linux-amd64-${KCP_VERSION}.tar.gz ${KCP_URL} \
    && tar zxf kcptun-linux-amd64-${KCP_VERSION}.tar.gz \
    && cd kcptun-linux-amd64-${KCP_VERSION} \
    && mv server_linux_amd64 /usr/local/bin/kcpserver \
    && mv client_linux_amd64 /usr/local/bin/kcpclient \
# simple-obfs plugin
    && cd /tmp  \
    && git clone ${OBFS_URL} \
    && git submodule update --init --recursive \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install

# Define Shadowsocks Settings
ENV SS_SERVER_ADDR=${SS_SERVER_ADDR:-0.0.0.0} \
SS_SERVER_PORT=${SS_SERVER_PORT:-8388} \
SS_PASSWORD=${SS_PASSWORD:-secret} \
SS_METHOD=$(SS_METHOD:-chacha20-ietf-poly1305} \
SS_TIMEOUT=${SS_TIMEOUT:-300} \
SS_DNS_ADDR1=$(SS_DNS_ADDR1:-1.1.1.1} \
SS_DNS_ADDR2=$(SS_DNS_ADDR1:-1.0.0.1}

# Define kcptun Settings
ENV KCP_PORT=${KCP_PORT:-8399} \
KCP_KEY=${KCP_KEY:-kcptun} \
KCP_MODE=${KCP_MODE:-fast} \
KCP_CRYPT=${KCP_CRYPT:-salsa20} \
KCP_MTU=${KCP_MTU:-1350} \
KCP_DSCP=${KCP_DSCP:-46}


# Define v2ray Settings
#ENV V2_GIT_PATH="https://github.com/v2ray/v2ray-core" \
#V2_VERSION="latest" \
#V2_PORT="8880" \
#HTTP_PORT="8080" \
#HTTPS_PORT="8443" \
#CADDY_PLUGINS="http.forwardproxy" \
#CADDYPATH="/tmp/" \
#V2RAY_LOCATION_ASSET="/usr/local/bin/" \
#V2RAY_LOCATION_CONFIG="/tmp/" \
#V2RAY_RAY_BUFFER_SIZE="2" \
#V2RAY_BUF_READV="auto"

USER nobody

# Expose Shadowsocks & KCP port
EXPOSE ${SS_SERVER_PORT}/tcp ${SS_SERVER_PORT}/udp
EXPOSE ${KCP_PORT}/udp

# Start Services
CMD ss-server -s $SS_SERVER_ADDR \
              -p $SS_SERVER_PORT \
              -k $SS_PASSWORD \
              -m $SS_METHOD \
              -t $SS_TIMEOUT \
              --fast-open \
              -d $SS_DNS_ADDR1 \
              -d $SS_DNS_ADDR2 \
              -u \
               && server_linux_amd64 -t 127.0.0.1:$SS_SERVER_PORT \
               -l :$KCP_PORT \
               --key $KCP_KEY \
               --mode $KCP_MODE \
               --crypt $KCP_CRYPT \
               --mtu $KCP_MTU \
               --dscp $KCP_DSCP \
--nocomp
