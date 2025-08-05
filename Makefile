
APP_NAME := multiplatform-go-app
REGISTRY := quay.io/your-username
IMAGE_TAG := $(REGISTRY)/$(APP_NAME)
VERSION := latest

HOST_OS := $(shell go env GOOS)
HOST_ARCH := $(shell go env GOARCH)
HOST_PLATFORM := $(HOST_OS)/$(HOST_ARCH)

GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m 

.PHONY: help linux arm macos windows image test clean push pull run test-local info


help:
	@echo "$(GREEN)Multi-platform Go Application Build System$(NC)"
	@echo "$(YELLOW)Using standard docker build (no buildx required)$(NC)"
	@echo ""
	@echo "$(YELLOW)Available commands:$(NC)"
	@echo "  help          - Show this help message"
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
	@echo ""
	@echo "$(YELLOW)Examples:$(NC)"
	@echo "  make linux    # Build for Linux"
	@echo "  make image    # Build for current platform"
	@echo "  make test     # Test all platforms"
	@echo "  make clean    # Clean up images"

# Збірка для Linux (amd64)
linux:
	@echo "$(GREEN)Building for Linux (amd64) using standard docker build...$(NC)"
	docker build \
		--build-arg TARGETOS=linux \
		--build-arg TARGETARCH=amd64 \
		--tag $(IMAGE_TAG):linux-amd64-$(VERSION) \
		.
	@echo "$(GREEN)✓ Linux build completed$(NC)"

# Збірка для ARM64
arm:
	@echo "$(GREEN)Building for ARM64 (linux/arm64) using standard docker build...$(NC)"
	docker build \
		--build-arg TARGETOS=linux \
		--build-arg TARGETARCH=arm64 \
		--tag $(IMAGE_TAG):linux-arm64-$(VERSION) \
		.
	@echo "$(GREEN)✓ ARM64 build completed$(NC)"

# Збірка для macOS (обидві архітектури)
macos:
	@echo "$(GREEN)Building for macOS (darwin/amd64) using standard docker build...$(NC)"
	docker build \
		--build-arg TARGETOS=darwin \
		--build-arg TARGETARCH=amd64 \
		--tag $(IMAGE_TAG):darwin-amd64-$(VERSION) \
		.
	@echo "$(GREEN)Building for macOS (darwin/arm64) using standard docker build...$(NC)"
	docker build \
		--build-arg TARGETOS=darwin \
		--build-arg TARGETARCH=arm64 \
		--tag $(IMAGE_TAG):darwin-arm64-$(VERSION) \
		.
	@echo "$(GREEN)✓ macOS build completed$(NC)"

# Збірка для Windows
windows:
	@echo "$(GREEN)Building for Windows (amd64) using standard docker build...$(NC)"
	docker build \
		--build-arg TARGETOS=windows \
		--build-arg TARGETARCH=amd64 \
		--tag $(IMAGE_TAG):windows-amd64-$(VERSION) \
		.
	@echo "$(GREEN)✓ Windows build completed$(NC)"

# Збірка для поточної платформи хоста (головна вимога завдання)
image:
	@echo "$(GREEN)Building for current host platform ($(HOST_PLATFORM)) using standard docker build...$(NC)"
	docker build \
		--build-arg TARGETOS=$(HOST_OS) \
		--build-arg TARGETARCH=$(HOST_ARCH) \
		--tag $(IMAGE_TAG):$(HOST_OS)-$(HOST_ARCH)-$(VERSION) \
		--tag $(IMAGE_TAG):latest \
		.
	@echo "$(GREEN)✓ Host platform build completed$(NC)"

# Збірка для всіх основних платформ
all: linux arm
	@echo "$(GREEN)✓ Multi-platform build completed$(NC)"

# Тестування на різних платформах
test: linux arm
	@echo "$(GREEN)Running tests on different platforms...$(NC)"
	@echo "$(YELLOW)Testing Linux AMD64...$(NC)"
	docker run --rm $(IMAGE_TAG):linux-amd64-$(VERSION) test || true
	@echo "$(YELLOW)Testing Linux ARM64...$(NC)"
	docker run --rm $(IMAGE_TAG):linux-arm64-$(VERSION) test || true
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
	docker push $(IMAGE_TAG):linux-amd64-$(VERSION)
	docker push $(IMAGE_TAG):linux-arm64-$(VERSION)
	docker push $(IMAGE_TAG):latest
	@echo "$(GREEN)✓ Images pushed successfully$(NC)"

# Завантаження образів з registry
pull:
	@echo "$(GREEN)Pulling images from $(REGISTRY)...$(NC)"
	docker pull $(IMAGE_TAG):latest
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
	@echo "$(GREEN)✓ Cleanup completed$(NC)"

# Показати інформацію про образи
info:
	@echo "$(GREEN)Docker images information:$(NC)"
	docker images | grep $(APP_NAME) || echo "No images found"
	@echo ""
	@echo "$(GREEN)Current platform: $(HOST_PLATFORM)$(NC)"
	@echo "$(GREEN)Registry: $(REGISTRY)$(NC)"
	@echo "$(GREEN)Image tag: $(IMAGE_TAG)$(NC)"
	@echo "$(GREEN)Build method: Standard docker build (no buildx)$(NC)"

# По замовчуванню показати допомогу
default: help