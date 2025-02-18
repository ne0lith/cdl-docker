FROM python:3.13 AS builder

ARG CYBERDROP_DL_VERSION
ARG TARGETARCH
ARG FIXUID_VERSION="0.6.0"
ARG GOTTY_VERSION="1.5.0"

WORKDIR /cyberdrop-dl

ENV PYTHONUNBUFFERED=1
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir cyberdrop-dl-patched${CYBERDROP_DL_VERSION:+\=\=${CYBERDROP_DL_VERSION}}

# Install and configure fixuid and switch to APP_USER
RUN set -ex && \
    curl -SsL https://github.com/boxboat/fixuid/releases/download/v${FIXUID_VERSION}/fixuid-${FIXUID_VERSION}-linux-${TARGETARCH:-amd64}.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid

RUN set -ex && \
    curl -SsL https://github.com/sorenisanerd/gotty/releases/download/v${GOTTY_VERSION}/gotty_v${GOTTY_VERSION}_linux_${TARGETARCH:-amd64}.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/gotty && \
    chmod 755 /usr/local/bin/gotty

FROM python:3.13-slim

ARG APP_USER="abc"

ENV TERM=xterm-256color
ENV PYTHONUNBUFFERED=1
ENV PYTHONIOENCODING=UTF-8
ENV DEBIAN_FRONTEND=noninteractive

COPY --from=builder /usr/local/lib/python3.13/site-packages /usr/local/lib/python3.13/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

RUN apt-get update && \
    apt-get -y install --no-install-recommends tmux && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN adduser --shell /bin/bash $APP_USER && \
    mkdir -p /etc/fixuid && \
    printf "user: ${APP_USER}\ngroup: ${APP_USER}\n" > /etc/fixuid/config.yml
USER "${APP_USER}:${APP_USER}"

WORKDIR /cyberdrop-dl
COPY --from=builder /cyberdrop-dl /cyberdrop-dl

ADD --chmod=755 entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

CMD ["cyberdrop-dl"]
