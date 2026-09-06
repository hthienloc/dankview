# DankView Roadmap (GNOME Loupe Parity & Enhancements)

Feature parity and tracking against [GNOME Loupe](https://gitlab.gnome.org/GNOME/loupe).

---

## 1. Viewing & Shortcuts

- [x] **Cursor-anchored Wheel Zoom**: Zoom centered on mouse coordinate.
- [x] **Hover-protected Autohide**: Header & bottom bars remain visible while hovered.
- [x] **Dynamic Theme Token Duration**: Use `Theme.shortDuration` & `Theme.standardEasing` across transitions.
- [x] **Lossless 90° Rotations**: Clockwise (`R`) and Counter-Clockwise (`Shift+R`).
- [x] **Keyboard Mirroring / Flipping**:
  - `Ctrl+M` / `H`: Flip horizontally.
  - `V`: Flip vertically.
- [x] **Dual Zoom Modes**:
  - `0`: Fit to window (best fit, reset pan).
  - `Ctrl+1`: Actual size (100% 1:1 pixel scale).
- [x] **Open File Dialog (`Ctrl+O`)**: Native Wayland / Portal / zenity file picker to load external images.

---

## 2. EXIF & Metadata Inspector

- [x] Slide-out Material 3 Inspector (`I`).
- [x] Exposure & photography optics summary (aperture, shutter, focal length, ISO, camera model).
- [x] Image resolution, megapixels, format, file size, timestamps.
- [x] Direct clipboard copy of image (`Ctrl+C`) and file path.
- [x] Direct folder reveal (`xdg-open`).
- [x] GPS map coordinates card with Open in Maps & Copy Coordinates actions (when GPS EXIF tags exist).

---

## 3. Playback & Media Handling

- [x] **Animated Image Playback Controls**:
  - Play/Pause toggle badge on header (`Play` / `Pause`) for animated GIF / WebP.
- [ ] Frame scrubber / seek slider for multi-frame animations.
- [ ] **Extended Format Decoding**:
  - Native AVIF / HEIC / JXL support verification via Qt image plugins.

---

## 4. Desktop Integration & Actions

- [ ] **Desktop Wallpaper Integration**: Set current image as wallpaper via DMS IPC or `swww` / `hyprpaper`.
- [ ] **Print Support (`Ctrl+P`)**: Launch system print portal (`org.freedesktop.portal.Print`).
- [x] **Trash & Undo**:
  - Send to trash (`Delete`).
  - Undo trash action (`Ctrl+Z`).

---

## 5. Basic Editing Tools

- [ ] **Crop Tool**: Interactive rectangular crop overlay with aspect ratio presets (1:1, 4:3, 16:9, Freeform).
- [ ] **Save As / Export**: Export to PNG, JPEG, WebP with compression quality options and metadata stripping.
