ARG BASE_IMAGE=alpine
FROM ${BASE_IMAGE}

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TIMEZONE=Asia/Shanghai

RUN set -eux \
  ; apk update && apk upgrade \
  ; apk add --no-cache tzdata curl jq \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  \
  ; nu_url=$(curl -sSL https://api.github.com/repos/nushell/nushell/releases -H 'Accept: application/vnd.github.v3+json' \
          | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep linux)  \
  ; curl -sSL ${nu_url} | tar zxvf - --strip-components=2 -C /usr/local/bin \
  ; rm -rf /var/cache/apk/*
