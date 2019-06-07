FROM debian:stretch-slim
      
MAINTAINER Fluke667 <Fluke667@gmail.com>        
ENV LINUX_HEADERS_VERSION 4.9.0-9


RUN set -x \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y curl wget ca-certificates git sudo nano software-properties-common apt-transport-https dirmngr build-essential tar kmod apt-utils gcc g++ make cmake  \
    && add-apt-repository deb http://deb.debian.org/debian stretch-backports main \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y apg libcap2-bin lsb-base init-system-helpers libc6 libcork16 libcorkipset1 libev4 libmbedcrypto0 libpcre3 libsodium18 libudns0 autoconf automake libtool gettext pkg-config libmbedtls10 libc-ares2 asciidoc xmlto \
    && apt-get install --no-install-recommends --no-install-suggests -y shadowsocks-libev kcptun simple-obfs
    
    
RUN set -x \
    && curl -L -o /tmp/go.sh https://install.direct/go.sh \
    && chmod +x /tmp/go.sh \
    && /tmp/go.sh \
    && mkdir /var/log/v2ray/ \
    && chmod +x /usr/bin/v2ray/v2ctl \
    && chmod +x /usr/bin/v2ray/v2ray
    
COPY /usr/bin/v2ray/v2ray /usr/bin/v2ray/
COPY /usr/bin/v2ray/v2ctl /usr/bin/v2ray/
COPY /usr/bin/v2ray/geoip.dat /usr/bin/v2ray/
COPY /usr/bin/v2ray/geosite.dat /usr/bin/v2ray/
COPY config.json /etc/v2ray/config.json
      
CMD ["v2ray", "-config=/etc/v2ray/config.json"]

# Define Shadowsocks Settings
ENV SS_SERVER_ADDR=${SS_SERVER_ADDR:-0.0.0.0} \
SS_SERVER_PORT=${SS_SERVER_PORT:-8388} \
SS_PASSWORD=${SS_PASSWORD:-secret} \
SS_METHOD=$(SS_METHOD:-aes-256-cfb} \
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
