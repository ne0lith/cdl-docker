ARG PYTHON_VERSION
FROM python:${PYTHON_VERSION}-alpine

WORKDIR /cyberdrop-dl

ARG CYBERDROP_DL_VERSION

RUN apk add --no-cache gcc musl-dev curl \
    && pip install --upgrade pip \
    && pip install --no-cache-dir --upgrade cyberdrop-dl-patched==${CYBERDROP_DL_VERSION} \
    && apk del gcc musl-dev

COPY . .

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["cyberdrop-dl", "--config", "Default", "--download"]
