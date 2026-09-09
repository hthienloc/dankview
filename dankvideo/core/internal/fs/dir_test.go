package fs

import (
	"os"
	"path/filepath"
	"testing"
)

func TestIsVideoFile(t *testing.T) {
	tests := []struct {
		name     string
		expected bool
	}{
		{"sample.mp4", true},
		{"video.MKV", true},
		{"clip.webm", true},
		{"movie.mov", true},
		{"stream.ts", true},
		{"image.png", false},
		{"doc.pdf", false},
		{"audio.mp3", false},
	}

	for _, tt := range tests {
		if got := IsVideoFile(tt.name); got != tt.expected {
			t.Errorf("IsVideoFile(%q) = %v; want %v", tt.name, got, tt.expected)
		}
	}
}

func TestScanDirectory(t *testing.T) {
	tmpDir, err := os.MkdirTemp("", "dankvideo_test_*")
	if err != nil {
		t.Fatalf("failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tmpDir)

	testFiles := []string{"b.mp4", "a.mkv", "ignore.txt", "c.webm"}
	for _, name := range testFiles {
		p := filepath.Join(tmpDir, name)
		if err := os.WriteFile(p, []byte("fake video"), 0644); err != nil {
			t.Fatalf("failed to write test file %q: %v", name, err)
		}
	}

	target := filepath.Join(tmpDir, "b.mp4")
	list, err := ScanDirectory(target)
	if err != nil {
		t.Fatalf("ScanDirectory failed: %v", err)
	}

	if len(list.Files) != 3 {
		t.Fatalf("expected 3 video files, got %d", len(list.Files))
	}

	if list.CurrentIndex != 1 {
		t.Fatalf("expected currentIndex 1 for b.mp4, got %d", list.CurrentIndex)
	}
}
