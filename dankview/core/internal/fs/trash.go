package fs

import (
	"bufio"
	"fmt"
	"io"
	"net/url"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

type trashEntry struct {
	infoPath string
	filePath string
	origPath string
	modTime  int64
}

// getTrashDir returns the XDG Trash directory path.
func getTrashDir() (string, error) {
	if xdgData := os.Getenv("XDG_DATA_HOME"); xdgData != "" {
		return filepath.Join(xdgData, "Trash"), nil
	}
	home, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(home, ".local", "share", "Trash"), nil
}

// RestoreLastTrashed restores a trashed file. If targetPath is specified,
// it restores the newest entry matching targetPath. If targetPath is empty,
// it restores the newest trashed entry.
// Returns the restored file's absolute path.
func RestoreLastTrashed(targetPath string) (string, error) {
	trashDir, err := getTrashDir()
	if err != nil {
		return "", fmt.Errorf("failed to determine trash directory: %w", err)
	}

	return restoreFromTrashDir(trashDir, targetPath)
}

func restoreFromTrashDir(trashDir, targetPath string) (string, error) {
	infoDir := filepath.Join(trashDir, "info")
	filesDir := filepath.Join(trashDir, "files")

	entries, err := os.ReadDir(infoDir)
	if err != nil {
		if os.IsNotExist(err) {
			return "", nil
		}
		return "", fmt.Errorf("failed to read trash info dir: %w", err)
	}

	var candidates []trashEntry

	for _, entry := range entries {
		if entry.IsDir() || !strings.HasSuffix(entry.Name(), ".trashinfo") {
			continue
		}

		infoPath := filepath.Join(infoDir, entry.Name())
		infoStat, err := entry.Info()
		if err != nil {
			continue
		}

		origPath, err := parseTrashInfoPath(infoPath)
		if err != nil || origPath == "" {
			continue
		}

		if targetPath != "" && origPath != targetPath {
			continue
		}

		baseName := strings.TrimSuffix(entry.Name(), ".trashinfo")
		trashedFilePath := filepath.Join(filesDir, baseName)

		if _, err := os.Stat(trashedFilePath); err != nil {
			continue
		}

		candidates = append(candidates, trashEntry{
			infoPath: infoPath,
			filePath: trashedFilePath,
			origPath: origPath,
			modTime:  infoStat.ModTime().UnixNano(),
		})
	}

	if len(candidates) == 0 {
		return "", nil
	}

	// Sort newest first
	sort.Slice(candidates, func(i, j int) bool {
		return candidates[i].modTime > candidates[j].modTime
	})

	selected := candidates[0]

	// Ensure destination directory exists
	if err := os.MkdirAll(filepath.Dir(selected.origPath), 0o755); err != nil {
		return "", fmt.Errorf("failed to create target directory: %w", err)
	}

	// Move file back
	if err := moveFile(selected.filePath, selected.origPath); err != nil {
		return "", fmt.Errorf("failed to restore file: %w", err)
	}

	// Clean up .trashinfo file
	_ = os.Remove(selected.infoPath)

	return selected.origPath, nil
}

func parseTrashInfoPath(infoPath string) (string, error) {
	file, err := os.Open(infoPath)
	if err != nil {
		return "", err
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if strings.HasPrefix(line, "Path=") {
			rawPath := strings.TrimPrefix(line, "Path=")
			unescaped, err := url.PathUnescape(rawPath)
			if err == nil {
				return unescaped, nil
			}
			return rawPath, nil
		}
	}

	return "", scanner.Err()
}

func moveFile(src, dst string) error {
	// Try fast rename
	if err := os.Rename(src, dst); err == nil {
		return nil
	}

	// Fallback to copy + delete across mount points
	in, err := os.Open(src)
	if err != nil {
		return err
	}
	defer in.Close()

	out, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer out.Close()

	if _, err := io.Copy(out, in); err != nil {
		return err
	}

	in.Close()
	out.Close()
	return os.Remove(src)
}
