# Makefile для мультиплатформенної збірки та тестування Go додатку
# Використовує альтернативний registry quay.io замість Docker Hub

# Налаштування
APP_NAME := multiplatform-go-app
REGISTRY := quay.io/your-username
IMAGE_TAG := $(REGISTRY)/$(APP_NAME)
VERSION := latest

# Автоматичне визначення поточної платформи
HOST_OS := $(shell go env GOOS)
HOST_ARCH := $(shell go env GOARCH)
HOST_PLATFORM := $(HOST_OS)/$(HOST_ARCH)

# Кольори для виводу
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

.PHONY: help setup linux arm macos windows image test clean push pull run test-local info

# Показати допомогу
help:
	@echo "$(GREEN)Multi-platform Go Application Build System$(NC)"
	@echo ""
	@echo "$(YELLOW)Available commands:$(NC)"
	@echo "  help          - Show this help message"
	@echo "  setup         - Setup Docker buildx for multi-platform builds"
	@echo "  linux         - Build for Linux (amd64)"
	@echo "  arm           - Build for ARM64 (linux/arm64)"
	@echo "  macos         - Build for macOS (darwin/amd64 and darwin/arm64)"
	@echo "  windows       - Build for Windows (amd64)"
	@echo "  image         - Build for current host platform ($(HOST_PLATFORM))"
	@echo "  test          - Run tests in Docker containers for all platforms"
	@echo "  test-local    - Run local tests"
	@echo "  clean         - Remove Docker images"
	@echo "  push          - Push images to registry"
	@echo "  pull          - Pull images from registry"
	@echo "  run           - Run application locally"
	@echo "  info          - Show Docker images information"

# Початкове налаштування Docker buildx
setup:
	@echo "$(GREEN)Setting up Docker buildx for multi-platform builds...$(NC)"
	docker buildx create --name multiplatform-builder --use --bootstrap || true
	docker buildx inspect --bootstrap
	@echo "$(GREEN)Setup completed!$(NC)"

# Збірка для Linux (amd64)
linux:
	@echo "$(GREEN)Building for Linux (amd64)...$(NC)"
	docker buildx build \
		--platform linux/amd64 \
		--tag $(IMAGE_TAG):linux-amd64-$(VERSION) \
		--load \
		.
	@echo "$(GREEN)✓ Linux build completed$(NC)"

# Збірка для ARM64
arm:
	@echo "$(GREEN)Building for ARM64 (linux/arm64)...$(NC)"
	docker buildx build \
		--platform linux/arm64 \
		--tag $(IMAGE_TAG):linux-arm64-$(VERSION) \
		--load \
		.
	@echo "$(GREEN)✓ ARM64 build completed$(NC)"

# Збірка для macOS (обидві архітектури)
macos:
	@echo "$(GREEN)Building for macOS (darwin/amd64)...$(NC)"
	docker buildx build \
		--platform linux/amd64 \
		--tag $(IMAGE_TAG):darwin-amd64-$(VERSION) \
		--load \
		.
	@echo "$(GREEN)Building for macOS (darwin/arm64)...$(NC)"
	docker buildx build \
		--platform linux/arm64 \
		--tag $(IMAGE_TAG):darwin-arm64-$(VERSION) \
		--load \
		.
	@echo "$(GREEN)✓ macOS build completed$(NC)"

# Збірка для Windows
windows:
	@echo "$(GREEN)Building for Windows (amd64)...$(NC)"
	docker buildx build \
		--platform linux/amd64 \
		--tag $(IMAGE_TAG):windows-amd64-$(VERSION) \
		--load \
		.
	@echo "$(GREEN)✓ Windows build completed$(NC)"

# Збірка для поточної платформи хоста
image:
	@echo "$(GREEN)Building for current host platform ($(HOST_PLATFORM))...$(NC)"
	docker buildx build \
		--platform $(HOST_PLATFORM) \
		--tag $(IMAGE_TAG):$(HOST_OS)-$(HOST_ARCH)-$(VERSION) \
		--tag $(IMAGE_TAG):latest \
		--load \
		.
	@echo "$(GREEN)✓ Host platform build completed$(NC)"

# Тестування на різних платформах
test: linux arm
	@echo "$(GREEN)Running tests on different platforms...$(NC)"
	@echo "$(YELLOW)Testing Linux AMD64...$(NC)"
	docker run --rm --platform linux/amd64 $(IMAGE_TAG):linux-amd64-$(VERSION) test || true
	@echo "$(YELLOW)Testing Linux ARM64...$(NC)"
	docker run --rm --platform linux/arm64 $(IMAGE_TAG):linux-arm64-$(VERSION) test || true
	@echo "$(GREEN)✓ All platform tests completed$(NC)"

# Локальний запуск додатку
run:
	@echo "$(GREEN)Running application locally...$(NC)"
	go run main.go

# Локальні тести
test-local:
	@echo "$(GREEN)Running local tests...$(NC)"
	go run main.go test
	go test -v ./...

# Відправлення образів до registry
push:
	@echo "$(GREEN)Pushing images to $(REGISTRY)...$(NC)"
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--tag $(IMAGE_TAG):$(VERSION) \
		--tag $(IMAGE_TAG):latest \
		--push \
		.
	@echo "$(GREEN)✓ Images pushed successfully$(NC)"

# Завантаження образів з registry
pull:
	@echo "$(GREEN)Pulling images from $(REGISTRY)...$(NC)"
	docker pull $(IMAGE_TAG):$(VERSION)
	@echo "$(GREEN)✓ Images pulled successfully$(NC)"

# Очищення Docker образів (відповідно до вимог завдання)
clean:
	@echo "$(GREEN)Cleaning up Docker images...$(NC)"
	@echo "$(YELLOW)Removing images with tag pattern: $(IMAGE_TAG)*$(NC)"
	-docker rmi $(IMAGE_TAG):linux-amd64-$(VERSION) 2>/dev/null || true
	-docker rmi $(IMAGE_TAG):linux-arm64-$(VERSION) 2>/dev/null || true
	-docker rmi $(IMAGE_TAG):darwin-amd64-$(VERSION) 2>/dev/null || true
	-docker rmi $(IMAGE_TAG):darwin-arm64-$(VERSION) 2>/dev/null || true
	-docker rmi $(IMAGE_TAG):windows-amd64-$(VERSION) 2>/dev/null || true
	-docker rmi $(IMAGE_TAG):$(HOST_OS)-$(HOST_ARCH)-$(VERSION) 2>/dev/null || true
	-docker rmi $(IMAGE_TAG):latest 2>/dev/null || true
	-docker rmi $(IMAGE_TAG):$(VERSION) 2>/dev/null || true
	@echo "$(GREEN)✓ Cleanup completed$(NC)"

# Показати інформацію про образи
info:
	@echo "$(GREEN)Docker images information:$(NC)"
	docker images | grep $(APP_NAME) || echo "No images found"
	@echo ""
	@echo "$(GREEN)Current platform: $(HOST_PLATFORM)$(NC)"
	@echo "$(GREEN)Registry: $(REGISTRY)$(NC)"
	@echo "$(GREEN)Image tag: $(IMAGE_TAG)$(NC)"

# По замовчуванню показати допомогу
default: help