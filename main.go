package main

import (
	"fmt"
	"os"
	"runtime"
)

func main() {
	fmt.Printf("Hello from multi-platform Go application!\n")
	fmt.Printf("OS: %s\n", runtime.GOOS)
	fmt.Printf("Architecture: %s\n", runtime.GOARCH)
	fmt.Printf("Go Version: %s\n", runtime.Version())
	
	// Симуляція роботи додатку
	if len(os.Args) > 1 && os.Args[1] == "test" {
		runTests()
	} else {
		fmt.Println("Application is running successfully!")
		fmt.Println("Run with 'test' argument to execute tests")
	}
}

func runTests() {
	fmt.Println("=== Running Tests ===")
	
	// Тест 1: Перевірка платформи
	fmt.Printf("✓ Platform test passed: %s/%s\n", runtime.GOOS, runtime.GOARCH)
	
	// Тест 2: Перевірка базової функціональності
	result := add(2, 3)
	if result == 5 {
		fmt.Println("✓ Math test passed: 2 + 3 = 5")
	} else {
		fmt.Printf("✗ Math test failed: expected 5, got %d\n", result)
		os.Exit(1)
	}
	
	// Тест 3: Перевірка змінних середовища
	if testEnv := os.Getenv("TEST_ENV"); testEnv != "" {
		fmt.Printf("✓ Environment test passed: TEST_ENV=%s\n", testEnv)
	} else {
		fmt.Println("⚠ Environment test: TEST_ENV not set")
	}
	
	fmt.Println("=== All Tests Passed ===")
}

func add(a, b int) int {
	return a + b
}