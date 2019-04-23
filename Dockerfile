FROM golang:1-stretch

ARG GOOS=linux
ARG GOARCH=amd64
ARG REPOSITORY_ARG=scrivener

ENV GITHUB_TOKEN="$GITHUB_TOKEN_ARG"
ENV GITHUB_SHA="$GITHUB_SHA_ARG"
ENV GITHUB_REF="$GITHUB_REF_ARG"
ENV GITHUB_REPOSITORY="$GITHUB_REPOSITORY_ARG"
ENV REPOSITORY=$REPOSITORY_ARG

RUN apt-get update && apt-get install -y --no-install-recommends \
		make \
		zip \
		jq \
		curl
RUN mkdir -p /tmp
RUN touch /tmp/response.json
WORKDIR ./src/azillion/scrivener
COPY . ./

RUN chmod 777 ./Makefile

ENTRYPOINT ["make"]
