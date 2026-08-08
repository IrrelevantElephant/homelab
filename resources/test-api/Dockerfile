FROM golang:1.26-alpine AS build

WORKDIR /src
COPY go.mod main.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /test-api .

FROM scratch

LABEL org.opencontainers.image.source="https://git.giulia-harry.dev/harry/homelab"

COPY --from=build /test-api /test-api

USER 65532:65532
EXPOSE 8080
ENTRYPOINT ["/test-api"]
