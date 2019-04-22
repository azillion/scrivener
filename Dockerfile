FROM golang:1-stretch

ARG GOOS=linux
ARG GOARCH=amd64

RUN apt-get update && apt-get install -y --no-install-recommends \
		make \
		zip \
		jq \
		curl

WORKDIR ./src/azillion/scrivener
COPY . ./

RUN chmod 777 ./Makefile

RUN make
