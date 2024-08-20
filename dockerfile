FROM python:3.11-alpine
WORKDIR /cyberdrop-dl

RUN apk add --no-cache \
    gcc \
    musl-dev

ARG CYBERDROP_DL_VERSION

RUN pip install --upgrade pip
RUN pip install --upgrade cyberdrop-dl-patched==${CYBERDROP_DL_VERSION}

COPY . .

CMD ["cyberdrop-dl", "--config", "Default", "--download"]
