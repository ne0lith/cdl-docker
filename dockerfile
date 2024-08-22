FROM python:3.11-alpine
WORKDIR /cyberdrop-dl

ARG CYBERDROP_DL_VERSION

RUN apk add --no-cache gcc musl-dev && \
    pip install --upgrade pip && \
    pip install --no-cache-dir --upgrade cyberdrop-dl-patched==${CYBERDROP_DL_VERSION} && \
    apk del gcc musl-dev

COPY . .

CMD ["cyberdrop-dl", "--config", "Default", "--download"]
