package exif

import (
	"fmt"
	"image"
	_ "image/gif"
	_ "image/jpeg"
	_ "image/png"
	"os"
	"path/filepath"
	"strings"
	"time"
)

// Metadata contains displayable properties for an image.
type Metadata struct {
	FilePath     string    `json:"filePath"`
	FileName     string    `json:"fileName"`
	FileSize     int64     `json:"fileSize"`
	FileSizeText string    `json:"fileSizeText"`
	Format       string    `json:"format"`
	Width        int       `json:"width"`
	Height       int       `json:"height"`
	AspectRatio  string    `json:"aspectRatio"`
	ModTime      time.Time `json:"modTime"`
	CameraMake   string    `json:"cameraMake,omitempty"`
	CameraModel  string    `json:"cameraModel,omitempty"`
	ExposureTime string    `json:"exposureTime,omitempty"`
	FNumber      string    `json:"fNumber,omitempty"`
	ISO          string    `json:"iso,omitempty"`
	FocalLength  string    `json:"focalLength,omitempty"`
	DateTaken    string    `json:"dateTaken,omitempty"`
}

func formatBytes(b int64) string {
	const unit = 1024
	if b < unit {
		return fmt.Sprintf("%d B", b)
	}
	div, exp := int64(unit), 0
	for n := b / unit; n >= unit; n /= unit {
		div *= unit
		exp++
	}
	return fmt.Sprintf("%.1f %cB", float64(b)/float64(div), "KMGTPE"[exp])
}

// GetMetadata extracts image dimensions and filesystem information.
func GetMetadata(filePath string) (*Metadata, error) {
	stat, err := os.Stat(filePath)
	if err != nil {
		return nil, err
	}

	file, err := os.Open(filePath)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	cfg, format, err := image.DecodeConfig(file)
	if err != nil {
		// Fallback for SVG or unsupported standard formats
		ext := strings.TrimPrefix(filepath.Ext(filePath), ".")
		format = strings.ToUpper(ext)
	}

	aspectRatio := ""
	if cfg.Width > 0 && cfg.Height > 0 {
		gcd := func(a, b int) int {
			for b != 0 {
				a, b = b, a%b
			}
			return a
		}
		g := gcd(cfg.Width, cfg.Height)
		aspectRatio = fmt.Sprintf("%d:%d", cfg.Width/g, cfg.Height/g)
	}

	meta := &Metadata{
		FilePath:     filePath,
		FileName:     filepath.Base(filePath),
		FileSize:     stat.Size(),
		FileSizeText: formatBytes(stat.Size()),
		Format:       strings.ToUpper(format),
		Width:        cfg.Width,
		Height:       cfg.Height,
		AspectRatio:  aspectRatio,
		ModTime:      stat.ModTime(),
	}

	return meta, nil
}
