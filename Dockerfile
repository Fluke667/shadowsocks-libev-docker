FROM debian:stretch-slim   
MAINTAINER Fluke667 <Fluke667@gmail.com>
ARG TIMEZONE=Europe/Berlin
ENV LINUX_HEADERS_VERSION 4.9.0-9

ENV SS_VERSION=3.3.0  \
KCP_VERSION=20190515 \
GOPATH=/usr/local/goprojects \
GOROOT=/usr/local/go \
PATH=$GOPATH/bin:$GOROOT/bin:$PATH


RUN set -x \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y curl wget ca-certificates libssl-dev git sudo nano software-properties-common apt-transport-https dirmngr build-essential tar kmod apt-utils gcc g++ make cmake  \
    && apt-get install --no-install-recommends --no-install-suggests -y apg libcap2-bin lsb-base init-system-helpers libc6 libcork16 libcorkipset1 libev4 libev-dev libmbedcrypto0 libmbedtls-dev libpcre3 libpcre3-dev libsodium18 libsodium-dev libudns0 autoconf automake libtool gettext pkg-config libmbedtls10 libmbedx509-0 libc-ares2 libc-ares-dev asciidoc golint xmlto
    

RUN set -x \
# install golang
    && cd /tmp  \
    && wget https://dl.google.com/go/go1.12.6.linux-amd64.tar.gz \
    && tar -xvf go1.12.6.linux-amd64.tar.gz \
    && mv /tmp/go /usr/local \
    && go version \
    && go env \
    && chmod -R 777 /usr/local/go \
    #&& go version; \
    #&& curl http://raw.githubusercontent.com/golang/dep/master/install.sh \
    #  --output /tmp/install-dep.sh \
    #  --silent \
    #&& chmod a+x /tmp/install-dep.sh \
    #&& /tmp/install-dep.sh \
    #&& apt-get clean \
    #&& go get -u golang.org/x/lint/golint \
    && sleep 30 \
# Build shadowsocks-libev
    && cd /tmp  \
    && wget https://github.com/shadowsocks/shadowsocks-libev/releases/download/v3.2.5/shadowsocks-libev-3.2.5.tar.gz \
    && tar zxf shadowsocks-libev-3.2.5.tar.gz \
    && cd shadowsocks-libev-3.2.5 \
    && ./configure --disable-documentation \
    && make \
    && make install \
    && sleep 30 \
# Build v2ray plugin
    && mkdir -p /go/src/github.com/shadowsocks \
    && cd /go/src/github.com/shadowsocks \
    && git clone https://github.com/shadowsocks/v2ray-plugin.git \
    && cd v2ray-plugin \
    && go get -d \
    && go build \
    && sleep 30 \
# Build kcptun plugin
    && cd /tmp  \
    && wget https://github.com/xtaci/kcptun/releases/download/v20190515/kcptun-linux-amd64-20190515.tar.gz \
    && tar zxf kcptun-linux-amd64-20190515.tar.gz \
    && cd kcptun-linux-amd64-20190515 \
    && mv server_linux_amd64 /usr/local/bin/kcpserver \
    && mv client_linux_amd64 /usr/local/bin/kcpclient \
    && sleep 30 \
# simple-obfs plugin
    && cd /tmp  \
    && git clone https://github.com/shadowsocks/simple-obfs.git \
    && cd simple-obfs \
    && ./configure \
    && make \
    && make install \
    && sleep 30 \
# Cloak plugin
    && cd /tmp  \
    && wget https://github.com/cbeuw/Cloak/releases/download/v1.1.1/ck-server-linux-amd64-1.1.1 \
    && go get github.com/boltdb/bolt \
    && go get github.com/juju/ratelimit \
    && go get golang.org/x/crypto/curve25519 \
    && sleep 30


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
#ENV V2_GIT_PATH="http://github.com/v2ray/v2ray-core" \
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
