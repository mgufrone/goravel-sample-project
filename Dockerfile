FROM golang:alpine AS builder

ENV GO111MODULE=on \
    CGO_ENABLED=0

WORKDIR /build
RUN --mount=src=go.mod,dst=go.mod \
    --mount=src=go.sum,dst=go.sum \
    --mount=type=cache,dst=/root/go/pkg/mod \
    go mod download -x
RUN --mount=src=.,dst=. \
    --mount=type=cache,dst=/root/go/pkg/mod \
    --mount=type=cache,dst=/root/.cache/go-build \
    go build --ldflags "-extldflags -static" -o /tmp/main .

FROM alpine:latest

WORKDIR /www

COPY database/ /www/database/
COPY public/ /www/public/
COPY storage/ /www/storage/
COPY resources/ /www/resources/
COPY --from=builder /tmp/main /www/

ENTRYPOINT ["/www/main"]
