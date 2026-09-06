package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/AvengeMedia/dankview/core/internal/exif"
	"github.com/AvengeMedia/dankview/core/internal/fs"
)

var (
	Version   = "0.1.0"
	BuildTime = "unknown"
	Commit    = "unknown"
)

func getSystemFontSettings() (family string, scale float64, mono string) {
	scale = 1.0
	home, err := os.UserHomeDir()
	if err == nil {
		dmsPath := filepath.Join(home, ".config", "DankMaterialShell", "settings.json")
		if data, err := os.ReadFile(dmsPath); err == nil {
			var s struct {
				FontFamily     string  `json:"fontFamily"`
				MonoFontFamily string  `json:"monoFontFamily"`
				FontScale      float64 `json:"fontScale"`
			}
			if err := json.Unmarshal(data, &s); err == nil {
				if s.FontFamily != "" {
					family = s.FontFamily
				}
				if s.MonoFontFamily != "" {
					mono = s.MonoFontFamily
				}
				if s.FontScale > 0 {
					scale = s.FontScale
				}
			}
		}
	}

	if family == "" {
		out, err := exec.Command("gsettings", "get", "org.gnome.desktop.interface", "font-name").Output()
		if err == nil {
			f := strings.Trim(string(out), "'\n\" ")
			fields := strings.Fields(f)
			if len(fields) > 1 {
				if _, err := strconv.ParseFloat(fields[len(fields)-1], 64); err == nil {
					family = strings.Join(fields[:len(fields)-1], " ")
				} else {
					family = f
				}
			} else {
				family = f
			}
		}
	}

	return family, scale, mono
}

func findQuickshellDir(specified string) (string, error) {
	if specified != "" {
		abs, err := filepath.Abs(specified)
		if err == nil {
			if _, err := os.Stat(filepath.Join(abs, "shell.qml")); err == nil {
				return abs, nil
			}
		}
	}

	candidates := []string{
		"quickshell",
		"../quickshell",
		"../../quickshell",
		"/usr/local/share/quickshell/dankview",
		"/usr/share/quickshell/dankview",
	}

	execPath, err := os.Executable()
	if err == nil {
		execDir := filepath.Dir(execPath)
		candidates = append([]string{
			filepath.Join(execDir, "../quickshell"),
			filepath.Join(execDir, "quickshell"),
			filepath.Join(execDir, "../share/quickshell/dankview"),
		}, candidates...)
	}

	for _, cand := range candidates {
		abs, err := filepath.Abs(cand)
		if err == nil {
			if _, err := os.Stat(filepath.Join(abs, "shell.qml")); err == nil {
				return abs, nil
			}
		}
	}

	return "", fmt.Errorf("could not locate quickshell configuration (shell.qml)")
}

func main() {
	configDir := flag.String("c", "", "path to quickshell configuration directory")
	fullscreen := flag.Bool("f", false, "open in fullscreen mode")
	showVersion := flag.Bool("v", false, "show version")
	printInfo := flag.Bool("info", false, "print image metadata as JSON and exit")
	printList := flag.Bool("list", false, "print directory image list as JSON and exit")

	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "Usage: dview [options] [image-path]\n\n")
		fmt.Fprintf(os.Stderr, "DankView - Standalone Material 3 Image Viewer\n\nOptions:\n")
		flag.PrintDefaults()
	}

	flag.Parse()

	if *showVersion {
		fmt.Printf("dview version %s (built %s, commit %s)\n", Version, BuildTime, Commit)
		return
	}

	targetPath := "."
	if flag.NArg() > 0 {
		targetPath = flag.Arg(0)
	}

	absPath, err := filepath.Abs(targetPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error resolving path: %v\n", err)
		os.Exit(1)
	}

	if *printInfo {
		meta, err := exif.GetMetadata(absPath)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error reading metadata: %v\n", err)
			os.Exit(1)
		}
		enc := json.NewEncoder(os.Stdout)
		enc.SetIndent("", "  ")
		enc.Encode(meta)
		return
	}

	if *printList {
		list, err := fs.ScanDirectory(absPath)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error scanning directory: %v\n", err)
			os.Exit(1)
		}
		enc := json.NewEncoder(os.Stdout)
		enc.SetIndent("", "  ")
		enc.Encode(list)
		return
	}

	imgList, err := fs.ScanDirectory(absPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Warning: unable to scan directory: %v\n", err)
		imgList = &fs.ImageList{
			Directory:    filepath.Dir(absPath),
			Files:        []string{absPath},
			CurrentIndex: 0,
		}
	}

	qsDir, err := findQuickshellDir(*configDir)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}

	initialImage := absPath
	if len(imgList.Files) > 0 && imgList.CurrentIndex < len(imgList.Files) {
		initialImage = imgList.Files[imgList.CurrentIndex]
	}

	env := os.Environ()
	execPath, err := os.Executable()
	if err == nil {
		env = append(env, "DVIEW_BIN="+execPath)
	}
	env = append(env,
		"DVIEW_INITIAL_IMAGE="+initialImage,
		"DVIEW_DIR="+imgList.Directory,
		"DVIEW_INDEX="+strconv.Itoa(imgList.CurrentIndex),
	)
	sysFont, sysScale, sysMono := getSystemFontSettings()
	if sysFont != "" {
		env = append(env, "DVIEW_FONT_FAMILY="+sysFont)
	}
	if sysScale > 0 {
		env = append(env, fmt.Sprintf("DVIEW_FONT_SCALE=%.2f", sysScale))
	}
	if sysMono != "" {
		env = append(env, "DVIEW_MONO_FONT="+sysMono)
	}
	if *fullscreen {
		env = append(env, "DVIEW_FULLSCREEN=1")
	}

	cmd := exec.Command("quickshell", "-p", qsDir)
	cmd.Env = env
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	if err := cmd.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "Error running quickshell: %v\n", err)
		os.Exit(1)
	}
}
