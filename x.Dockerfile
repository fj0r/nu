FROM fj0rd/scratch:dropbear as dropbear
FROM fj0rd/scratch:nu as nu
FROM ubuntu:jammy

EXPOSE 22
VOLUME /world

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TIMEZONE=Asia/Shanghai

COPY --from=dropbear / /
COPY --from=nu / /

RUN set -eux \
  ; apt-get update -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends tzdata \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/local/bin/nu"]
