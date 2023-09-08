FROM alpine:3.18
RUN apk add --no-cache wireguard-tools envsubst

# Tunnel Mode is either node or external
# This will choose which template file is used when constructing the tunnel endpoint.

ENV TUNNEL_MODE="node"

ENV NODE_TUNNEL_DEVICE="wgD"
ENV NODE_TUNNEL_ADDRESS="10.10.9.3/31"
ENV NODE_LISTEN_PORT="51001"
ENV NODE_LISTEN_ADDRESS="192.168.1.28"
ENV NODE_ALLOWED_IPS="10.10.9.2/31,10.244.0.0/16,10.96.0.0/16 "

ENV EXTERNAL_TUNNEL_DEVICE="wgC"
ENV EXTERNAL_TUNNEL_ADDRESS="10.10.9.2/31"
ENV EXTERNAL_LISTEN_PORT="51001"
ENV EXTERNAL_LISTEN_ADDRESS="192.168.1.10"
ENV EXTERNAL_ALLOWED_IPS="10.100.2.0/24,10.10.9.2/31"


# Important Note: These keys are pre-seeded for instructive purposes only
# You should use populate keys securely in a production environment

ENV NODE_PRIVATE_KEY="0PX4OEHtEMUdAnb3hzbpm1sWRiEJVqx4iIn+ooJ6WUw="
ENV NODE_PUBLIC_KEY="qGHrspNQWsGscJ51b9dutPH0H5gHi2ENj709Ho4Fj0k="
ENV EXTERNAL_PRIVATE_KEY="QF6L1LNmlkd9o+gysOEfH50xWFS0FzY/pyxuGC7VaEI="
ENV EXTERNAL_PUBLIC_KEY="8SBx7i/Uj14eKf5Jy0BkcJfaG2c+KNoH4p7m0PtLKAc="

COPY ./templates/wg-node.conf.template /root/
COPY ./templates/wg-external.conf.template /root/
COPY ./scripts/setup-tunnel-endpoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/setup-tunnel-endpoint.sh"]
