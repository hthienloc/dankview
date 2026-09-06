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
	Directory    string    `json:"directory"`
	FileSize     int64     `json:"fileSize"`
	FileSizeText string    `json:"fileSizeText"`
	Format       string    `json:"format"`
	Width        int       `json:"width"`
	Height       int       `json:"height"`
	AspectRatio  string    `json:"aspectRatio"`
	Megapixels   string    `json:"megapixels,omitempty"`
	ModTime      time.Time `json:"modTime"`
	ModTimeText  string    `json:"modTimeText"`
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
	mp := ""
	if cfg.Width > 0 && cfg.Height > 0 {
		gcd := func(a, b int) int {
			for b != 0 {
				a, b = b, a%b
			}
			return a
		}
		g := gcd(cfg.Width, cfg.Height)
		aspectRatio = fmt.Sprintf("%d:%d", cfg.Width/g, cfg.Height/g)
		pixels := float64(cfg.Width * cfg.Height)
		if pixels >= 1000000 {
			mp = fmt.Sprintf("%.1f MP", pixels/1000000.0)
		} else {
			mp = fmt.Sprintf("%.0f kP", pixels/1000.0)
		}
	}

	meta := &Metadata{
		FilePath:     filePath,
		FileName:     filepath.Base(filePath),
		Directory:    filepath.Dir(filePath),
		FileSize:     stat.Size(),
		FileSizeText: formatBytes(stat.Size()),
		Format:       strings.ToUpper(format),
		Width:        cfg.Width,
		Height:       cfg.Height,
		AspectRatio:  aspectRatio,
		Megapixels:   mp,
		ModTime:      stat.ModTime(),
		ModTimeText:  stat.ModTime().Format("Jan 02, 2006 15:04"),
	}

	return meta, nil
}
