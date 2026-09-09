package exif

import (
	"encoding/json"
	"fmt"
	"image"
	_ "image/gif"
	_ "image/jpeg"
	_ "image/png"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
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
	GPSLatitude  float64   `json:"gpsLatitude,omitempty"`
	GPSLongitude float64   `json:"gpsLongitude,omitempty"`
	GPSPosition  string    `json:"gpsPosition,omitempty"`
	MapsURL      string    `json:"mapsUrl,omitempty"`
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

	populateExifTool(filePath, meta)

	return meta, nil
}

func populateExifTool(filePath string, meta *Metadata) {
	exiftoolBin, err := exec.LookPath("exiftool")
	if err != nil {
		return
	}

	cmd := exec.Command(exiftoolBin, "-json", "-c", "%.6f", filePath)
	out, err := cmd.Output()
	if err != nil {
		return
	}

	var records []map[string]interface{}
	if err := json.Unmarshal(out, &records); err != nil || len(records) == 0 {
		return
	}

	rec := records[0]

	getString := func(key string) string {
		if v, ok := rec[key]; ok && v != nil {
			return fmt.Sprintf("%v", v)
		}
		return ""
	}

	getFloat := func(key string) float64 {
		if v, ok := rec[key]; ok && v != nil {
			switch val := v.(type) {
			case float64:
				return val
			case string:
				parts := strings.Fields(val)
				if len(parts) > 0 {
					f, _ := strconv.ParseFloat(parts[0], 64)
					return f
				}
			}
		}
		return 0
	}

	if makeStr := getString("Make"); makeStr != "" {
		meta.CameraMake = makeStr
	}
	if modelStr := getString("Model"); modelStr != "" {
		meta.CameraModel = modelStr
	}
	if exp := getString("ExposureTime"); exp != "" {
		meta.ExposureTime = exp
	}
	if fnum := getString("FNumber"); fnum != "" {
		meta.FNumber = "f/" + fnum
	}
	if iso := getString("ISO"); iso != "" {
		meta.ISO = iso
	}
	if focal := getString("FocalLength"); focal != "" {
		meta.FocalLength = focal
	}
	if dateTaken := getString("DateTimeOriginal"); dateTaken != "" {
		meta.DateTaken = dateTaken
	}

	// GPS Coordinates
	lat := getFloat("GPSLatitude")
	lon := getFloat("GPSLongitude")

	latRef := strings.ToUpper(getString("GPSLatitudeRef"))
	lonRef := strings.ToUpper(getString("GPSLongitudeRef"))

	if strings.Contains(latRef, "S") && lat > 0 {
		lat = -lat
	}
	if strings.Contains(lonRef, "W") && lon > 0 {
		lon = -lon
	}

	if lat != 0 || lon != 0 {
		meta.GPSLatitude = lat
		meta.GPSLongitude = lon
		meta.GPSPosition = fmt.Sprintf("%.5f, %.5f", lat, lon)
		meta.MapsURL = fmt.Sprintf("https://www.openstreetmap.org/?mlat=%.6f&mlon=%.6f#map=16/%.6f/%.6f", lat, lon, lat, lon)
	}
}
