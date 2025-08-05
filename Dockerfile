# Dockerfile для мультиплатформенної збірки Go додатку
# Використовує стандартний docker build без buildx

# Використовуємо альтернативний registry quay.io замість Docker Hub
FROM quay.io/projectquay/golang:1.21 AS builder

# Аргументи для cross-compilation (можна передавати через --build-arg)
ARG TARGETOS=linux
ARG TARGETARCH=amd64

# Інформація про збірку
RUN echo "Building for $TARGETOS/$TARGETARCH"

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

# Мінімальний runtime образ
FROM scratch

# Копіюємо скомпільований додаток
COPY --from=builder /app/app /app

# Встановлюємо змінну середовища для тестування
ENV TEST_ENV=docker-container

# Мітки для ідентифікації
LABEL org.opencontainers.image.title="Multi-platform Go Test App"
LABEL org.opencontainers.image.description="Go application for cross-platform testing"
LABEL org.opencontainers.image.version="1.0.0"

# Налаштування для тестування
ENV APP_ENV=production

# Точка входу
ENTRYPOINT ["/app"]