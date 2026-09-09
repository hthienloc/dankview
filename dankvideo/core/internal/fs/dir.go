package fs

import (
	"os"
	"path/filepath"
	"sort"
	"strings"
)

var SupportedVideoExtensions = map[string]bool{
	".mp4":  true,
	".mkv":  true,
	".webm": true,
	".mov":  true,
	".avi":  true,
	".flv":  true,
	".wmv":  true,
	".m4v":  true,
	".ogv":  true,
	".3gp":  true,
	".ts":   true,
}

func IsVideoFile(filename string) bool {
	ext := strings.ToLower(filepath.Ext(filename))
	return SupportedVideoExtensions[ext]
}

type VideoList struct {
	Directory    string   `json:"directory"`
	Files        []string `json:"files"`
	CurrentIndex int      `json:"currentIndex"`
}

func ScanDirectory(targetPath string) (*VideoList, error) {
	absPath, err := filepath.Abs(targetPath)
	if err != nil {
		return nil, err
	}

	info, err := os.Stat(absPath)
	if err != nil {
		return nil, err
	}

	var dir string
	var targetFile string

	if info.IsDir() {
		dir = absPath
	} else {
		dir = filepath.Dir(absPath)
		targetFile = absPath
	}

	entries, err := os.ReadDir(dir)
	if err != nil {
		return nil, err
	}

	var files []string
	currentIndex := 0

	for _, entry := range entries {
		if entry.IsDir() {
			continue
		}
		if IsVideoFile(entry.Name()) {
			fullPath := filepath.Join(dir, entry.Name())
			files = append(files, fullPath)
		}
	}

	sort.Strings(files)

	if targetFile != "" {
		for i, f := range files {
			if f == targetFile {
				currentIndex = i
				break
			}
		}
	}

	return &VideoList{
		Directory:    dir,
		Files:        files,
		CurrentIndex: currentIndex,
	}, nil
}
