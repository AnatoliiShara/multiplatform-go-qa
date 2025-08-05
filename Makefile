APP_NAME := multiplatform-go-qa
OUTPUT_DIR := build

PLATFORMS := linux/amd64 linux/arm64 windows/amd64 darwin/amd64

.PHONY: all clean build docker

all: build

build:
	@mkdir -p $(OUTPUT_DIR)
	@for platform in $(PLATFORMS); do \
		GOOS=$${platform%/*} GOARCH=$${platform#*/} \
		go build -o $(OUTPUT_DIR)/$(APP_NAME)-$${GOOS}-$${GOARCH} main.go ; \
	done

docker:
	docker build -t myuser/multiplatform-go-qa:latest .

clean:
	rm -rf $(OUTPUT_DIR)
	docker rmi quay.io/projectquay/$(APP_NAME):latest || true
