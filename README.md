# Multi-Platform Go Application

Цей проект демонструє мультиплатформенну збірку та тестування Go додатків з використанням Docker та Makefile.

## Підтримувані платформи

- **Linux**: AMD64, ARM64
- **macOS**: AMD64 (Intel), ARM64 (Apple Silicon)
- **Windows**: AMD64

## Вимоги

- Docker з підтримкою buildx
- Make
- Go 1.21+ (для локальної розробки)

## Швидкий старт

### 1. Початкове налаштування

```bash
# Налаштування Docker buildx для мультиплатформенної збірки
make setup
```

### 2. Збірка для різних платформ

```bash
# Збірка для Linux
make linux

# Збірка для ARM64
make arm

# Збірка для macOS
make macos

# Збірка для Windows
make windows

# Збірка для поточної платформи хоста
make image
```

### 3. Тестування

```bash
# Запуск тестів на різних платформах
make test

# Локальне тестування
make test-local

# Запуск додатку локально
make run
```

### 4. Очищення

```bash
# Видалення всіх створених Docker образів
make clean
```

## Структура проекту

```
.
├── Dockerfile          # Мультиплатформенний Dockerfile
├── Makefile            # Система збірки та тестування
├── main.go             # Головний файл додатку
├── main_test.go        # Unit тести
├── go.mod              # Go модуль
├── README.md           # Ця документація
└── .dockerignore       # Файли для ігнорування при збірці
```

## Команди Makefile

| Команда | Опис |
|---------|------|
| `make help` | Показати допомогу |
| `make setup` | Налаштування Docker buildx |
| `make linux` | Збірка для Linux AMD64 |
| `make arm` | Збірка для Linux ARM64 |
| `make macos` | Збірка для macOS (обидві архітектури) |
| `make windows` | Збірка для Windows AMD64 |
| `make image` | Збірка для поточної платформи |
| `make test` | Тестування на різних платформах |
| `make clean` | Видалення Docker образів |
| `make push` | Відправлення до registry |
| `make pull` | Завантаження з registry |

## Використання альтернативного registry

Проект налаштований на використання `quay.io` замість Docker Hub для уникнення проблем з ліцензуванням та лімітами.

Для використання власного registry:

1. Змініть змінну `REGISTRY` в Makefile:
   ```makefile
   REGISTRY := quay.io/your-username
   ```

2. Увійдіть до registry:
   ```bash
   docker login quay.io
   ```

3. Відправте образи:
   ```bash
   make push
   ```

## CI/CD Integration

### GitLab CI приклад

```yaml
stages:
  - build
  - test
  - deploy

variables:
  REGISTRY: quay.io/your-username
  APP_NAME: multiplatform-go-app

build_multiplatform:
  stage: build
  script:
    - make setup
    - make all
  only:
    - main
    - develop

test_platforms:
  stage: test
  script:
    - make test
  dependencies:
    - build_multiplatform
```

### GitHub Actions приклад

```yaml
name: Multi-platform Build and Test

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
    
    - name: Build for all platforms
      run: |
        make setup
        make linux
        make arm
        
    - name: Run tests
      run: make test
    
    - name: Clean up
      run: make clean
```

## Troubleshooting

### Помилка з buildx

Якщо отримуєте помилку з buildx:
```bash
make setup
docker buildx ls
```

### Проблеми з cross-compilation

Переконайтеся, що встановлено підтримку QEMU:
```bash
docker run --privileged --rm tonistiigi/binfmt --install all
```

### Недостатньо місця на диску

Очистіть невикористовувані образи:
```bash
make clean
docker system prune -f
```

## Розробка

### Локальний запуск

```bash
go run main.go
```

### Запуск тестів

```bash
go run main.go test
```

### Додавання нових платформ

1. Оновіть відповідні команди в Makefile
2. Додайте платформу до команди `test`
3. Оновіть документацію

