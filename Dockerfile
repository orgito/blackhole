FROM golang:alpine AS builder

WORKDIR /usr/src/app

RUN apk add --no-cache make bash

# pre-copy/cache go.mod for pre-downloading dependencies and only redownloading them in subsequent builds if they change
COPY go.mod go.sum ./
RUN go mod download && go mod verify


COPY . .
RUN sed -i 's/-L1/-n 1/g' list_bindirs.sh
RUN make

FROM alpine:latest AS release
COPY --from=builder /usr/src/app/blackhole /usr/src/app/replay /usr/local/bin/

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/blackhole"]
