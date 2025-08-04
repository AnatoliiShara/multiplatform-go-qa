package main

import (
	"runtime"
	"testing"
)

func TestAdd(t *testing.T) {
	tests := []struct {
		name     string
		a, b     int
		expected int
	}{
		{"positive numbers", 2, 3, 5},
		{"negative numbers", -1, -2, -3},
		{"zero and positive", 0, 5, 5},
		{"large numbers", 1000, 2000, 3000},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := add(tt.a, tt.b)
			if result != tt.expected {
				t.Errorf("add(%d, %d) = %d; expected %d", tt.a, tt.b, result, tt.expected)
			}
		})
	}
}

func TestPlatformInfo(t *testing.T) {
	os := runtime.GOOS
	arch := runtime.GOARCH
	
	t.Logf("Running on: %s/%s", os, arch)
	
	// Перевіряємо, що платформа визначається правильно
	if os == "" {
		t.Error("OS should not be empty")
	}
	
	if arch == "" {
		t.Error("Architecture should not be empty")
	}
	
	// Перевіряємо підтримувані платформи
	supportedOS := map[string]bool{
		"linux":   true,
		"darwin":  true,
		"windows": true,
	}
	
	supportedArch := map[string]bool{
		"amd64": true,
		"arm64": true,
		"386":   true,
	}
	
	if !supportedOS[os] {
		t.Logf("Warning: OS %s might not be officially supported", os)
	}
	
	if !supportedArch[arch] {
		t.Logf("Warning: Architecture %s might not be officially supported", arch)
	}
}

func BenchmarkAdd(b *testing.B) {
	for i := 0; i < b.N; i++ {
		add(42, 24)
	}
}

func BenchmarkPlatformDetection(b *testing.B) {
	for i := 0; i < b.N; i++ {
		_ = runtime.GOOS
		_ = runtime.GOARCH
	}
}