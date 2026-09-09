package fs

import (
	"os"
	"path/filepath"
	"testing"
)

func TestIsSupportedImage(t *testing.T) {
	tests := []struct {
		path     string
		expected bool
	}{
		{"image.png", true},
		{"photo.JPG", true},
		{"banner.jpeg", true},
		{"graphic.webp", true},
		{"vector.svg", true},
		{"anim.gif", true},
		{"modern.avif", true},
		{"nextgen.jxl", true},
		{"document.pdf", false},
		{"notes.txt", false},
		{"binary.exe", false},
	}

	for _, tt := range tests {
		if got := IsSupportedImage(tt.path); got != tt.expected {
			t.Errorf("IsSupportedImage(%q) = %v; want %v", tt.path, got, tt.expected)
		}
	}
}

func TestScanDirectory(t *testing.T) {
	tmpDir := t.TempDir()

	img1 := filepath.Join(tmpDir, "a.png")
	img2 := filepath.Join(tmpDir, "b.jpg")
	nonImg := filepath.Join(tmpDir, "readme.txt")

	_ = os.WriteFile(img1, []byte("fake png"), 0o644)
	_ = os.WriteFile(img2, []byte("fake jpg"), 0o644)
	_ = os.WriteFile(nonImg, []byte("text"), 0o644)

	list, err := ScanDirectory(img2)
	if err != nil {
		t.Fatalf("ScanDirectory failed: %v", err)
	}

	if len(list.Files) != 2 {
		t.Errorf("expected 2 images, got %d", len(list.Files))
	}

	if list.CurrentIndex != 1 {
		t.Errorf("expected currentIndex to be 1 for b.jpg, got %d", list.CurrentIndex)
	}
}
