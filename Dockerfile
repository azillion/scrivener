FROM golang:1-stretch

WORKDIR ./src/azillion/scrivener
COPY ./ ./

RUN make
