FROM alpine:3.18
RUN apk add --no-cache curl iputils bash netcat-openbsd

COPY ./scripts/keep-alive-loop.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/keep-alive-loop.sh"]
