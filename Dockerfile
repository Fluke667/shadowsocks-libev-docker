FROM debian:stretch-slim
      
MAINTAINER Fluke667 <Fluke667@gmail.com>        
ENV LINUX_HEADERS_VERSION 4.9.0-9


RUN set -x \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y curl wget ca-certificates git sudo pico build-essential tar kmod apt-utils gcc g++ make cmake  \
    && apt-get install --no-install-recommends --no-install-suggests -y apg libcap2-bin lsb-base init-system-helpers libc6 libcork16 libcorkipset1 libev4 libmbedcrypto0 libpcre3 libsodium18 libudns0 \
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
    
      
      
     
