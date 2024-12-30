ARG PYTHON_VERSION
FROM python:${PYTHON_VERSION}-alpine

WORKDIR /cyberdrop-dl

ARG CYBERDROP_DL_VERSION

RUN apk add --no-cache gcc musl-dev curl \
    && pip install --upgrade pip \
    && pip install --no-cache-dir --upgrade cyberdrop-dl-patched==${CYBERDROP_DL_VERSION} \
    && apk del gcc musl-dev

COPY . .

CMD ["cyberdrop-dl"]
