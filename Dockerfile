FROM golang:1-stretch

ARG GOOS=linux
ARG GOARCH=amd64

ENV REPOSITORY=scrivener
ENV GITHUB_TOKEN
ENV GITHUB_SHA
ENV GITHUB_REF
ENV GITHUB_REPOSITORY

RUN apt-get update && apt-get install -y --no-install-recommends \
		make \
		zip \
		jq \
		curl

WORKDIR ./src/azillion/scrivener
COPY . ./

RUN chmod 777 ./Makefile

RUN make
