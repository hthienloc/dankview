package fs

import (
	"os"
	"path/filepath"
	"testing"
	"time"
)

func TestRestoreFromTrashDir(t *testing.T) {
	trashDir := t.TempDir()
	infoDir := filepath.Join(trashDir, "info")
	filesDir := filepath.Join(trashDir, "files")
	origDir := t.TempDir()

	_ = os.MkdirAll(infoDir, 0o755)
	_ = os.MkdirAll(filesDir, 0o755)

	targetFile := filepath.Join(origDir, "video.mp4")
	trashedFile := filepath.Join(filesDir, "video.mp4")
	infoFile := filepath.Join(infoDir, "video.mp4.trashinfo")

	content := []byte("video content here")
	if err := os.WriteFile(trashedFile, content, 0o644); err != nil {
		t.Fatalf("failed to write trashed file: %v", err)
	}

	infoContent := "[Trash Info]\nPath=" + targetFile + "\nDeletionDate=" + time.Now().Format("2006-01-02T15:04:05") + "\n"
	if err := os.WriteFile(infoFile, []byte(infoContent), 0o644); err != nil {
		t.Fatalf("failed to write trashinfo: %v", err)
	}

	restored, err := restoreFromTrashDir(trashDir, targetFile)
	if err != nil {
		t.Fatalf("restoreFromTrashDir failed: %v", err)
	}

	if restored != targetFile {
		t.Errorf("expected restored path %q, got %q", targetFile, restored)
	}

	if _, err := os.Stat(targetFile); err != nil {
		t.Errorf("restored file does not exist at %q", targetFile)
	}

	if _, err := os.Stat(trashedFile); !os.IsNotExist(err) {
		t.Errorf("trashed file was not removed from %q", trashedFile)
	}

	if _, err := os.Stat(infoFile); !os.IsNotExist(err) {
		t.Errorf("trashinfo file was not removed from %q", infoFile)
	}
}
