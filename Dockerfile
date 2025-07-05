# Build stage
FROM nimlang/nim:2.2.0-alpine-regular as builder
WORKDIR /app

RUN apk --no-cache add libsass-dev pcre

COPY nitter.nimble .
RUN nimble install -y --depsOnly

COPY . .
RUN nimble build -d:danger -d:lto -d:strip --mm:refc \
    && nimble scss \
    && nimble md

# Final image
FROM alpine:latest
WORKDIR /app

RUN apk --no-cache add pcre ca-certificates

COPY --from=builder /app/nitter ./nitter
COPY --from=builder /app/nitter.example.conf ./nitter.conf
COPY --from=builder /app/public ./public
COPY --from=builder /app/sessions.jsonl ./sessions.jsonl

EXPOSE 8080
CMD ["./nitter"]
