FROM golang:1.20-alpine as build_base
# RUN apk add bash ca-certificates git gcc g++ libc-dev
WORKDIR /app
# Force the go compiler to use modules
ENV GO111MODULE=on
# We want to populate the module cache based on the go.{mod,sum} files.
COPY go.mod .
COPY go.sum .
RUN go mod download

# === This image builds the app. ===
FROM build_base AS builder
# Here we copy the rest of the source code
COPY . .
ENV GOOS=linux
ENV GOARCH=amd64
RUN go build -o main -ldflags '-w -extldflags "-static"' .

# === Target image ===
FROM gcr.io/distroless/base
COPY --from=builder /app/main /
EXPOSE 55555
CMD ["/main"]
