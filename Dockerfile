# syntax=docker/dockerfile:1
FROM golang:1.22 AS builder

WORKDIR /app

COPY go.mod .
RUN go mod download

COPY . .

RUN go build -o app main.go

FROM scratch

COPY --from=builder /app/app /app

ENTRYPOINT ["/app"]
