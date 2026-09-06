# DankView (`dview`)

A modern, fast, and feature-complete standalone Image Viewer designed for the Linux desktop and the DankMaterialShell ecosystem, inspired by GNOME Loupe.

Built with **Quickshell (QtQuick/QML)** for a fluid Material 3 interface and **Go** for high-performance directory traversal, metadata extraction, and desktop integration.

---

## Features

- **Fluid Canvas**: Smooth mouse wheel zoom, trackpad pinch gestures, click-and-drag panning, and auto-fit to viewport.
- **Dynamic Checkerboard**: Automatic transparency grid rendered using dynamic theme colors for transparent PNG, WebP, and SVG files.
- **Directory Traversal**: Cycle through adjacent images in the folder with arrow keys, edge click zones, or the bottom floating toolbar.
- **Transformations**: Lossless 90° clockwise and counter-clockwise rotation and horizontal/vertical flipping with smooth cubic animations.
- **Image Details & EXIF Inspector**: Slide-out Material 3 side sheet displaying:
  - Hero summary card with file name, format tag, resolution, megapixels, and file size.
  - Quick action chips: **Copy Image**, **Copy Path**, and **Open Containing Folder**.
  - Detailed image attributes (dimensions, megapixels, aspect ratio, exact byte size, modification timestamp).
  - Photography & optics strip with 4-cell quick specs (Aperture, Shutter Speed, Focal Length, ISO) and camera model.
  - Storage location with path copying and folder reveal.
- **DankMaterialShell & System Integration**:
  - Automatically synchronizes theme colors from `dms-colors.json` (Matugen).
  - Reads configured font family, font scale, and monospace font from `~/.config/DankMaterialShell/settings.json` or GNOME gsettings.
  - Integrates clipboard copying via `dms cl copy` (with `wl-copy` fallback).
  - Triggers native DMS toasts via `dms ipc call toast` (with `notify-send` fallback).
- **Transient UI**: Distraction-free view with auto-hiding header and floating pill toolbar.
- **Zero Hardcoded Colors**: 100% semantic theme tokens (`Theme.*`) adapting to dark and light palettes.
- **Desktop Entry**: Includes XDG `.desktop` file registering standard `image/*` MIME types.

---

## Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| `Right` / `Space` / `PageDown` | Next image |
| `Left` / `Backspace` / `PageUp` | Previous image |
| `+` / `=` / `Wheel Up` | Zoom in |
| `-` / `Wheel Down` | Zoom out |
| `0` | Reset zoom and transformations |
| `Double Click` | Toggle 200% zoom / 100% fit |
| `r` | Rotate clockwise (90°) |
| `Shift + r` | Rotate counter-clockwise (90°) |
| `f` / `F11` | Toggle maximize / fullscreen |
| `i` | Toggle Image Details & EXIF Inspector |
| `Ctrl + C` | Copy image to clipboard |
| `Delete` | Move image to trash (`gio trash`) |
| `Esc` | Close inspector / restore window / quit |

---

## Project Structure

```
dankview/
├── Makefile                          # Top-level build and run orchestration
├── distro/
│   └── com.danklinux.dankview.desktop# Desktop entry with image/* MIME associations
├── core/                             # Go CLI & backend services
│   ├── cmd/dview/                    # Entrypoint and Quickshell launcher
│   ├── internal/
│   │   ├── fs/                       # Natural directory scanning & image filtering
│   │   ├── exif/                     # Dimensions, format & EXIF metadata extraction
│   │   └── theme/                    # DMS settings & system font resolution
│   ├── Makefile                      # Go build targets (build, test, fmt, vet)
│   └── go.mod
├── dank-qml-common/                  # Git submodule with shared Material 3 components
└── quickshell/                       # Quickshell frontend
    ├── shell.qml                     # ShellRoot entrypoint
    ├── Common/
    │   ├── Theme.qml                 # Dynamic theme & Matugen color bindings
    │   ├── StockTheme.js             # Built-in M3 palettes
    │   ├── SettingsData.qml          # UI and viewer persistent settings
    │   └── Paths.qml                 # XDG standard paths helper
    ├── Services/
    │   └── ImageService.qml          # Core state, navigation & process execution
    └── Modules/ImageViewer/
        ├── ImageViewerWindow.qml     # Floating window with keyboard & gesture management
        ├── ImageCanvas.qml           # Viewport, zoom, pan, pinch & checkerboard canvas
        ├── ImageHeaderBar.qml        # Auto-hiding header with file title & window controls
        ├── ImageBottomBar.qml        # Floating pill toolbar
        └── ExifInspector.qml         # Slide-out Material 3 details sheet
```

---

## CLI Usage

```bash
# Open an image
dview photo.jpg

# Open directory containing target image
dview /path/to/gallery/image.png

# Open in fullscreen
dview -f photo.jpg

# Inspect image metadata as JSON (no UI)
dview -info photo.jpg

# List directory images and current index as JSON (no UI)
dview -list /path/to/folder

# Print version
dview -v
```

---

## Building & Installation

### Requirements

- Go 1.21+
- [Quickshell](https://quickshell.outfoxxed.me/) (QtQuick/QML Wayland shell)
- `dms` (optional, for native clipboard and toast notifications)
- `wl-clipboard` (optional, clipboard fallback)
- `gio` (optional, trash support)

### Development

```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/AvengeMedia/dankview.git
cd dankview

# Fast build
make dev

# Run against an image
make run after.png

# Run test suite
make test

# Format and vet Go code
make fmt && make vet
```

### Installation

```bash
sudo make install PREFIX=/usr/local
```

This installs `dview` to `/usr/local/bin/dview` and the `.desktop` file to `/usr/local/share/applications/`.

---

## License

MIT License.
