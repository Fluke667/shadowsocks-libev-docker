#!/bin/bash

# Shadowsocks environment variables
ENV SS_SERVER_ADDR=0.0.0.0 \
SS_SERVER_PORT=8388 \
SS_LOCAL_PORT=1080 \
SS_PASSWORD=ChangeMe \
SS_METHOD=chacha20-ietf-poly1305 \
SS_TIMEOUT=300 \
SS_USER=nobody \
SS_DNS_ADDRS 1.1.1.1,1.0.0.1 \
SS_MODE=tcp_and_udp \
SS_PID=/var/run/shadowsocks-libev.pid \
SS_PLUGIN=obfs-server \
SS_PLUGIN_OPTS=obfs=http \
SS_ARGS='' \
KCP_ADDR=7667 \
KCP_PASS=ChangeMe \
KCP_ENCRYPT=aes \
KCP_MODE=fast2 \
KCP_MTU=1350 \
KCP_SNDWND=2048 \
KCP_RCVWND=2048 \
KCP_DSCP=46 \
KCP_NOCOMP=false \
KCP_ARGS=''


CMD ss-server -s ${SS_SERVER_ADDR} \
              -p ${SS_SERVER_PORT} \
              -l ${SS_LOCAL_PORT} \
              -k ${SS_PASSWORD} \
              -m ${SS_METHOD} \
              -t ${SS_TIMEOUT} \
              -a ${SS_USER} \
              -d ${SS_DNS_ADDR} \
              -u ${SS_MODE} \
              -f ${SS_PID} \
              --plugin ${SS_PLUGIN} \
              --plugin-opts ${SS_PLUGIN_OPTS} \
              ${SS_ARGS} \
 && kcpserver -l ":${KCP_ADDR}" \
              -t "127.0.0.1:${KCP_PORT}" \
              --key ${KCP_PASS} \
              --crypt ${KCP_ENCRYPT} \
              --mode ${KCP_MODE} \
              --mtu ${KCP_MTU} \
              --sndwnd ${KCP_SNDWND} \
              --rcvwnd ${KCP_RCVWND} \
              --dscp ${KCP_DSCP} \
              ${KCP_NOCOMP} \
              ${KCP_ARGS}

exec runsvdir -P /etc/service
