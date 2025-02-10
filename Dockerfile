FROM python:3.13 AS builder

ARG CYBERDROP_DL_VERSION
ARG TARGETARCH
ARG FIXUID_VERSION="0.6.0"

WORKDIR /cyberdrop-dl

ENV PYTHONUNBUFFERED=1
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir cyberdrop-dl-patched${CYBERDROP_DL_VERSION:+\=\=${CYBERDROP_DL_VERSION}}

# Install and configure fixuid and switch to APP_USER
RUN set -ex && case ${TARGETARCH:-amd64} in \
        "arm64") curl -SsL https://github.com/boxboat/fixuid/releases/download/v${FIXUID_VERSION}/fixuid-${FIXUID_VERSION}-linux-arm64.tar.gz | tar -C /usr/local/bin -xzf - ;; \
        "amd64") curl -SsL https://github.com/boxboat/fixuid/releases/download/v${FIXUID_VERSION}/fixuid-${FIXUID_VERSION}-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - ;; \
        *) echo "Dockerfile does not support this platform"; exit 1 ;; \
    esac && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid


FROM python:3.13-slim

ARG APP_USER="abc"

ENV TERM=xterm-256color
ENV PYTHONUNBUFFERED=1
ENV PYTHONIOENCODING=UTF-8

COPY --from=builder /usr/local/lib/python3.13/site-packages /usr/local/lib/python3.13/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

RUN adduser --shell /bin/bash $APP_USER && \
    mkdir -p /etc/fixuid && \
    printf "user: ${APP_USER}\ngroup: ${APP_USER}\n" > /etc/fixuid/config.yml
USER "${APP_USER}:${APP_USER}"

WORKDIR /cyberdrop-dl
COPY --from=builder /cyberdrop-dl /cyberdrop-dl

ADD --chmod=755 entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

CMD ["cyberdrop-dl"]
