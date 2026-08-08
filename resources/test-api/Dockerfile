# Builder stage
FROM golang:1.26-alpine AS builder

WORKDIR /app

# Copy go.mod and go.sum if they existed, but they don't here.
# If there were dependencies, we'd copy them here.

COPY . .

# Build the static binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o test-api .

# Final stage
FROM scratch

# Create a non-root user
# Since scratch has no /etc/passwd, we can just use a UID
USER 1000:1000

# Copy the binary from builder
COPY --from=builder /app/test-api /test-api

# Expose port 8080
EXPOSE 8080

# Forgejo source OCI label
LABEL org.opencontainers.image.source="https://git.giulia-harry.dev/harry/homelab"

ENTRYPOINT ["/test-api"]
