package fs

import (
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"
	"time"
)

// GalleryImage represents a single image with metadata for the gallery.
type GalleryImage struct {
	Path      string `json:"path"`
	Name      string `json:"name"`
	ModTime   int64  `json:"modTime"`
	DateGroup string `json:"dateGroup"`
	Category  string `json:"category"`
}

// GalleryGroup groups images under a specific date header (e.g., "Today", "Yesterday").
type GalleryGroup struct {
	DateGroup string         `json:"dateGroup"`
	Images    []GalleryImage `json:"images"`
}

// GalleryAlbum represents a category/folder of images with preview thumbnails.
type GalleryAlbum struct {
	Name       string   `json:"name"`
	Path       string   `json:"path"`
	IsPinned   bool     `json:"isPinned"`
	Previews   []string `json:"previews"`
	TotalCount int      `json:"totalCount"`
}

// GalleryData is the payload returned to QML.
type GalleryData struct {
	AllImages  []GalleryImage `json:"allImages"`
	Groups     []GalleryGroup `json:"groups"`
	Albums     []GalleryAlbum `json:"albums"`
	Categories []string       `json:"categories"`
}

// GetPicturesDir returns the user's Pictures directory or fallback ~/Pictures.
func GetPicturesDir() string {
	if out, err := exec.Command("xdg-user-dir", "PICTURES").Output(); err == nil {
		dir := strings.TrimSpace(string(out))
		if dir != "" && dir != "/" {
			return dir
		}
	}
	if home, err := os.UserHomeDir(); err == nil {
		return filepath.Join(home, "Pictures")
	}
	return ""
}

func computeDateGroup(t time.Time, today, yesterday time.Time) string {
	fileDate := time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, t.Location())
	if !fileDate.Before(today) {
		return "Today"
	}
	if fileDate.Equal(yesterday) {
		return "Yesterday"
	}
	if fileDate.Year() == today.Year() {
		return t.Format("January 2")
	}
	return t.Format("January 2, 2006")
}

// ScanGallery scans rootDir and its subdirectories for images and organizes them into GalleryData.
func ScanGallery(rootDir string) (*GalleryData, error) {
	if rootDir == "" {
		rootDir = GetPicturesDir()
	}

	absRoot, err := filepath.Abs(rootDir)
	if err != nil {
		return nil, err
	}

	now := time.Now()
	today := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())
	yesterday := today.AddDate(0, 0, -1)

	var allImages []GalleryImage
	albumMap := make(map[string]*GalleryAlbum)
	categorySet := make(map[string]bool)

	// Ensure Screenshots is tracked as pinned album if present or common
	screenshotDir := filepath.Join(absRoot, "Screenshots")
	albumMap[screenshotDir] = &GalleryAlbum{
		Name:     "Screenshots",
		Path:     screenshotDir,
		IsPinned: true,
		Previews: []string{},
	}

	// Walk max 2 levels deep
	_ = filepath.Walk(absRoot, func(path string, info os.FileInfo, err error) error {
		if err != nil || info == nil {
			return nil
		}

		rel, relErr := filepath.Rel(absRoot, path)
		if relErr == nil {
			depth := len(strings.Split(rel, string(os.PathSeparator)))
			if info.IsDir() && depth > 2 && rel != "." {
				return filepath.SkipDir
			}
		}

		if info.IsDir() {
			if path != absRoot {
				albumName := info.Name()
				isPinned := strings.EqualFold(albumName, "Screenshots") || strings.EqualFold(albumName, "Wallpapers")
				if _, exists := albumMap[path]; !exists {
					albumMap[path] = &GalleryAlbum{
						Name:     albumName,
						Path:     path,
						IsPinned: isPinned,
						Previews: []string{},
					}
				}
			}
			return nil
		}

		if !IsSupportedImage(path) {
			return nil
		}

		parentDir := filepath.Dir(path)
		category := "Pictures"
		if parentDir != absRoot {
			category = filepath.Base(parentDir)
		}

		img := GalleryImage{
			Path:      path,
			Name:      info.Name(),
			ModTime:   info.ModTime().Unix(),
			DateGroup: computeDateGroup(info.ModTime(), today, yesterday),
			Category:  category,
		}

		allImages = append(allImages, img)
		categorySet[category] = true

		// Add to album previews
		if alb, ok := albumMap[parentDir]; ok {
			alb.TotalCount++
			if len(alb.Previews) < 4 {
				alb.Previews = append(alb.Previews, path)
			}
		}

		return nil
	})

	// Sort images newest first
	sort.Slice(allImages, func(i, j int) bool {
		return allImages[i].ModTime > allImages[j].ModTime
	})

	// Group by date
	groupMap := make(map[string][]GalleryImage)
	var dateOrder []string
	for _, img := range allImages {
		grp := img.DateGroup
		if _, exists := groupMap[grp]; !exists {
			dateOrder = append(dateOrder, grp)
		}
		groupMap[grp] = append(groupMap[grp], img)
	}

	var groups []GalleryGroup
	for _, grpName := range dateOrder {
		groups = append(groups, GalleryGroup{
			DateGroup: grpName,
			Images:    groupMap[grpName],
		})
	}

	// Build albums list (Pinned first, then custom)
	var pinnedAlbums []GalleryAlbum
	var customAlbums []GalleryAlbum
	for _, alb := range albumMap {
		if alb.TotalCount > 0 || alb.IsPinned {
			if alb.IsPinned {
				pinnedAlbums = append(pinnedAlbums, *alb)
			} else {
				customAlbums = append(customAlbums, *alb)
			}
		}
	}

	sort.Slice(pinnedAlbums, func(i, j int) bool {
		return pinnedAlbums[i].Name < pinnedAlbums[j].Name
	})
	sort.Slice(customAlbums, func(i, j int) bool {
		return customAlbums[i].Name < customAlbums[j].Name
	})

	albums := append(pinnedAlbums, customAlbums...)

	// Build sorted categories: "All" first, then "Screenshots" if exists, then alphabetical
	var categories []string
	categories = append(categories, "All")
	if categorySet["Screenshots"] {
		categories = append(categories, "Screenshots")
	}
	var otherCats []string
	for cat := range categorySet {
		if cat != "All" && cat != "Screenshots" {
			otherCats = append(otherCats, cat)
		}
	}
	sort.Strings(otherCats)
	categories = append(categories, otherCats...)

	return &GalleryData{
		AllImages:  allImages,
		Groups:     groups,
		Albums:     albums,
		Categories: categories,
	}, nil
}
