# Мультиплатформенний Dockerfile для Go додатку
# Підтримує: linux/amd64, linux/arm64, darwin/amd64, darwin/arm64, windows/amd64

# Використовуємо альтернативний registry quay.io замість Docker Hub
FROM --platform=$BUILDPLATFORM quay.io/projectquay/golang:1.21 AS builder

# Встановлюємо аргументи для cross-compilation
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH

# Інформація про збірку
RUN echo "Building on $BUILDPLATFORM for $TARGETPLATFORM"

# Створюємо робочу директорію
WORKDIR /app

# Копіюємо go.mod та go.sum (якщо є)
COPY go.mod* go.sum* ./

# Завантажуємо залежності
RUN go mod download

# Копіюємо вихідний код
COPY . .

# Встановлюємо змінні середовища для cross-compilation
ENV CGO_ENABLED=0
ENV GOOS=${TARGETOS}
ENV GOARCH=${TARGETARCH}

# Компілюємо додаток для цільової платформи
RUN go build -a -installsuffix cgo -o app .

# Многостадийная сборка - минимальный runtime образ
FROM scratch AS runtime-linux
COPY --from=builder /app/app /app
ENV TEST_ENV=docker-linux
ENTRYPOINT ["/app"]

# Для Windows потрібен базовий образ з runtime
FROM mcr.microsoft.com/windows/nanoserver:ltsc2022 AS runtime-windows
COPY --from=builder /app/app /app.exe
ENV TEST_ENV=docker-windows
ENTRYPOINT ["/app.exe"]

# Вибираємо відповідний runtime образ на основі цільової ОС
FROM runtime-${TARGETOS} AS final

# Мітки для ідентифікації
LABEL org.opencontainers.image.title="Multi-platform Go Test App"
LABEL org.opencontainers.image.description="Go application for cross-platform testing"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.platform="${TARGETPLATFORM}"

# Налаштування для тестування
ENV APP_ENV=production