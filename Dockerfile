FROM golang:1-stretch

ARG GOOS=linux
ARG GOARCH=amd64

RUN set -ex \
    && apk add --no-cache make

WORKDIR ./src/azillion/scrivener
COPY . ./

RUN chmod 777 ./Makefile

RUN make
