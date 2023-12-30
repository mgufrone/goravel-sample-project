FROM golang:alpine AS builder

ENV GO111MODULE=on \
    CGO_ENABLED=0

WORKDIR /build
RUN --mount=src=go.mod,dst=go.mod \
    --mount=src=go.sum,dst=go.sum \
    go mod download -x
RUN --mount=src=.,dst=. \
    go build --ldflags "-extldflags -static" -o /tmp/main .

FROM alpine:latest

WORKDIR /www

COPY database/ /www/database/
COPY public/ /www/public/
COPY storage/ /www/storage/
COPY resources/ /www/resources/
COPY --from=builder /tmp/main /www/

ENTRYPOINT ["/www/main"]
