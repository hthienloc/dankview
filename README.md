# DankView (dview)

A modern, fast, and feature-complete standalone Image Viewer designed for the Linux desktop and the DankMaterialShell ecosystem, inspired by GNOME Loupe.

Built with **Quickshell (QtQuick/QML)** for a fluid Material 3 user interface and **Go** for high-performance directory traversal, metadata extraction, and system integration.

---

## Features

- **Fluid Canvas**: Smooth mouse wheel zoom, trackpad pinch gestures, click-and-drag pan, and auto-fit to window.
- **Directory Traversal**: Effortlessly cycle through next/previous images in the current folder using arrow keys, mouse edge buttons, or the bottom toolbar.
- **Transformations**: Lossless 90° clockwise/counter-clockwise rotation and horizontal/vertical flipping with smooth animations.
- **Image Inspector**: Slide-out properties drawer displaying image format, resolution, aspect ratio, file size, modification date, and EXIF camera specs (aperture, shutter speed, ISO, focal length).
- **Transient UI**: Clean, distraction-free view with auto-hiding header and floating bottom action pill inspired by GNOME Loupe.
- **Clipboard & Trash**: One-click / one-key shortcut to copy images to the Wayland clipboard (`wl-copy`) or move files to the trash (`gio trash`).
- **Standalone Integration**: Includes a `.desktop` file registering standard `image/*` MIME types, ready to serve as the default system image viewer or pair with file managers.
- **Multi-Window Support**: Launch multiple instances to inspect and compare images side-by-side.

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
| `r` / `Shift+r` | Rotate clockwise / counter-clockwise |
| `f` / `F11` | Toggle fullscreen |
| `i` | Toggle Image Properties & EXIF Inspector |
| `Ctrl+C` | Copy image to clipboard |
| `Delete` | Move image to trash |
| `Esc` | Close inspector / exit fullscreen / quit |

---

## Project Architecture

```
dankview/
├── Makefile                          # Top-level build orchestration
├── distro/
│   └── com.danklinux.dankview.desktop# Desktop entry with image/* MIME associations
├── core/                             # Go backend
│   ├── cmd/dview/                    # CLI binary & launcher
│   └── internal/
│       ├── fs/                       # Natural directory scanning & image filtering
│       └── exif/                     # EXIF metadata & image dimension extraction
└── quickshell/                       # Quickshell QML frontend
    ├── shell.qml                     # ShellRoot
    ├── Common -> dank-qml-common     # Shared Material 3 theme & utilities
    ├── Services/
    │   └── ImageService.qml          # Image viewer state, process runner & actions
    └── Modules/ImageViewer/
        ├── ImageViewerWindow.qml     # FloatingWindow with keyboard & overlay handlers
        ├── ImageCanvas.qml           # Pan, zoom, pinch, rotation, and animation canvas
        ├── ImageHeaderBar.qml        # Header with file name, counter & quick tools
        ├── ImageBottomBar.qml        # Floating action pill (Loupe-style)
        └── ExifInspector.qml         # Slide-out EXIF metadata drawer
```

---

## Building & Running

### Requirements

- `go` (1.21+)
- `quickshell` (Wayland QtQuick shell framework)
- `git`
- `wl-clipboard` (optional, for clipboard copying)
- `glib2` / `gio` (optional, for trash support)

### Setup & Build

```bash
# Clone with submodules (dank-qml-common)
git clone --recurse-submodules https://github.com/AvengeMedia/dankview.git
cd dankview

# Fast build
make dev

# Run against an image
make run after.png

# Or run directly via binary
./core/bin/dview /path/to/photo.jpg
```

---

## License

MIT License.
