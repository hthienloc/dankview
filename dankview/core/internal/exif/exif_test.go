package exif

import (
	"bytes"
	"image"
	"image/color"
	"image/png"
	"os"
	"path/filepath"
	"testing"
)

func TestFormatBytes(t *testing.T) {
	tests := []struct {
		bytes    int64
		expected string
	}{
		{500, "500 B"},
		{1024, "1.0 KB"},
		{2048, "2.0 KB"},
		{1048576, "1.0 MB"},
		{1572864, "1.5 MB"},
	}

	for _, tt := range tests {
		if got := formatBytes(tt.bytes); got != tt.expected {
			t.Errorf("formatBytes(%d) = %q; want %q", tt.bytes, got, tt.expected)
		}
	}
}

func TestGetMetadata(t *testing.T) {
	tmpDir := t.TempDir()
	imgPath := filepath.Join(tmpDir, "test.png")

	// Create valid 10x20 PNG image
	img := image.NewRGBA(image.Rect(0, 0, 10, 20))
	img.Set(0, 0, color.RGBA{R: 255, A: 255})

	var buf bytes.Buffer
	if err := png.Encode(&buf, img); err != nil {
		t.Fatalf("failed to encode png: %v", err)
	}

	if err := os.WriteFile(imgPath, buf.Bytes(), 0o644); err != nil {
		t.Fatalf("failed to write test image: %v", err)
	}

	meta, err := GetMetadata(imgPath)
	if err != nil {
		t.Fatalf("GetMetadata failed: %v", err)
	}

	if meta.Width != 10 || meta.Height != 20 {
		t.Errorf("expected 10x20, got %dx%d", meta.Width, meta.Height)
	}

	if meta.AspectRatio != "1:2" {
		t.Errorf("expected aspect ratio 1:2, got %q", meta.AspectRatio)
	}

	if meta.Format != "PNG" {
		t.Errorf("expected format PNG, got %q", meta.Format)
	}

	if meta.FileName != "test.png" {
		t.Errorf("expected fileName test.png, got %q", meta.FileName)
	}
}
