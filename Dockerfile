FROM python:3.13-slim AS builder

ARG CYBERDROP_DL_VERSION

WORKDIR /cyberdrop-dl

ENV PYTHONUNBUFFERED=1
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir cyberdrop-dl-patched${CYBERDROP_DL_VERSION:+\=\=${CYBERDROP_DL_VERSION}}

COPY . .

FROM python:3.13-slim

ENV TERM=xterm-256color
ENV PYTHONUNBUFFERED=1
ENV PYTHONIOENCODING=UTF-8

WORKDIR /cyberdrop-dl

COPY --from=builder /cyberdrop-dl /cyberdrop-dl
COPY --from=builder /usr/local/lib/python3.13/site-packages /usr/local/lib/python3.13/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

CMD ["cyberdrop-dl"]
