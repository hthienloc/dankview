pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common

Singleton {
    id: root

    property var fileList: []
    property int currentIndex: 0
    readonly property string currentFilePath: fileList.length > 0 && currentIndex >= 0 && currentIndex < fileList.length ? fileList[currentIndex] : ""
    readonly property string currentFileName: {
        if (!currentFilePath) return "";
        const parts = currentFilePath.split("/");
        return parts[parts.length - 1];
    }

    property var currentMeta: ({})
    property real zoom: 1.0
    property real fitScale: 1.0
    property int rotation: 0
    readonly property int normalizedRotation: ((rotation % 360) + 360) % 360
    property bool resettingTransform: false
    property bool flipH: false
    property bool flipV: false
    property bool isAnimated: false
    property bool isPlaying: true
    property int currentFrame: 0
    property int frameCount: 1
    property bool inspectorOpen: false
    property bool isFullscreen: Quickshell.env("DVIEW_FULLSCREEN") === "1"
    property real panX: 0
    property real panY: 0

    function togglePlayback() {
        isPlaying = !isPlaying;
    }

    onCurrentFilePathChanged: {
        resetTransform();
        if (currentFilePath) {
            fetchMetadata();
        } else {
            currentMeta = ({});
        }
    }

    Component.onCompleted: {
        const initImg = Quickshell.env("DVIEW_INITIAL_IMAGE");
        if (initImg) {
            loadDirectoryFor(initImg);
        }
    }

    readonly property string dviewBin: Quickshell.env("DVIEW_BIN") || "dview"

    function loadDirectoryFor(filePath) {
        listProc.command = [dviewBin, "-list", filePath];
        listProc.running = true;
    }

    function fetchMetadata() {
        if (!currentFilePath) return;
        infoProc.command = [dviewBin, "-info", currentFilePath];
        infoProc.running = true;
    }

    Process {
        id: listProc
        running: false
        command: []
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    if (data && data.files && data.files.length > 0) {
                        root.fileList = data.files;
                        root.currentIndex = data.currentIndex >= 0 && data.currentIndex < data.files.length ? data.currentIndex : 0;
                    }
                } catch (e) {
                    console.warn("Failed to parse image list JSON:", e);
                }
            }
        }
    }

    Process {
        id: infoProc
        running: false
        command: []
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    if (data) {
                        root.currentMeta = data;
                    }
                } catch (e) {
                    console.warn("Failed to parse metadata JSON:", e);
                }
            }
        }
    }

    Process {
        id: trashProc
        running: false
        command: []
        onExited: exitCode => {
            if (exitCode === 0) {
                root.showToast("Moved to trash (Ctrl+Z to undo)");
                removeCurrentFromList();
            } else {
                root.showToast("Failed to move image to trash", true);
            }
        }
    }

    Process {
        id: restoreProc
        running: false
        command: []
        stdout: StdioCollector {
            onStreamFinished: {
                const restored = text.trim();
                if (restored.length > 0) {
                    root.showToast("Restored from trash");
                    root.loadDirectoryFor(restored);
                } else {
                    root.showToast("Nothing to undo", true);
                }
            }
        }
    }

    Process {
        id: copyProc
        running: false
        command: []
        onExited: exitCode => {
            if (exitCode === 0) {
                root.showToast("Image copied to clipboard");
            } else {
                root.showToast("Failed to copy image to clipboard", true);
            }
        }
    }

    Process {
        id: copyPathProc
        running: false
        command: []
        onExited: exitCode => {
            if (exitCode === 0) {
                root.showToast("File path copied to clipboard");
            } else {
                root.showToast("Failed to copy path", true);
            }
        }
    }

    Process {
        id: wallpaperProc
        running: false
        command: []
        onExited: exitCode => {
            if (exitCode === 0) {
                root.showToast("Wallpaper set");
            } else {
                root.showToast("Failed to set wallpaper", true);
            }
        }
    }

    function nextImage() {
        if (fileList.length <= 1) return;
        currentIndex = (currentIndex + 1) % fileList.length;
    }

    function prevImage() {
        if (fileList.length <= 1) return;
        currentIndex = (currentIndex - 1 + fileList.length) % fileList.length;
    }

    function jumpToIndex(idx) {
        if (idx >= 0 && idx < fileList.length) {
            currentIndex = idx;
        }
    }

    function rotateClockwise() {
        rotation += 90;
    }

    function rotateCounterClockwise() {
        rotation -= 90;
    }

    function toggleFlipHorizontal() {
        flipH = !flipH;
    }

    function toggleFlipVertical() {
        flipV = !flipV;
    }

    Process {
        id: openDialogProc
        running: false
        command: [
            "sh", "-c",
            "zenity --file-selection --title=\"Open Image\" --file-filter=\"Images | *.jpg *.jpeg *.png *.webp *.svg *.gif *.bmp *.avif *.heic *.heif *.jxl *.tif *.tiff *.exr *.hdr *.tga *.qoi *.psd *.dds\" 2>/dev/null || kdialog --getopenfilename . \"*.jpg *.jpeg *.png *.webp *.svg *.gif *.bmp *.avif *.heic *.heif *.jxl *.tif *.tiff *.exr *.hdr *.tga *.qoi *.psd *.dds\" 2>/dev/null"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                const picked = text.trim();
                if (picked.length > 0) {
                    root.loadDirectoryFor(picked);
                }
            }
        }
    }

    function openFileDialog() {
        openDialogProc.running = true;
    }

    function zoomAt(factor, cursorX, cursorY, vpWidth, vpHeight) {
        const oldZoom = zoom;
        const newZoom = Math.max(0.05, Math.min(30.0, oldZoom * factor));
        if (Math.abs(newZoom - oldZoom) < 0.0001) return;

        // Center of viewport relative to cursor
        const cx = cursorX - vpWidth / 2;
        const cy = cursorY - vpHeight / 2;

        // Shift pan so that the image pixel under cursor stays under cursor
        panX = (panX - cx) * (newZoom / oldZoom) + cx;
        panY = (panY - cy) * (newZoom / oldZoom) + cy;
        zoom = newZoom;
    }

    function zoomIn() {
        zoom = Math.min(zoom * 1.25, 30.0);
    }

    function zoomOut() {
        zoom = Math.max(zoom / 1.25, 0.05);
    }

    function fitToWindow() {
        zoom = 1.0;
        panX = 0;
        panY = 0;
    }

    function actualSize() {
        panX = 0;
        panY = 0;
        if (fitScale > 0) {
            zoom = 1.0 / fitScale;
        } else {
            zoom = 1.0;
        }
    }

    function resetZoom() {
        fitToWindow();
    }

    function resetTransform() {
        resettingTransform = true;
        zoom = 1.0;
        rotation = 0;
        flipH = false;
        flipV = false;
        panX = 0;
        panY = 0;
        resettingTransform = false;
    }

    function toggleInspector() {
        inspectorOpen = !inspectorOpen;
    }

    function toggleFullscreen() {
        isFullscreen = !isFullscreen;
    }

    function copyToClipboard() {
        if (!currentFilePath) return;
        const ext = currentFilePath.split('.').pop().toLowerCase();
        const mime = (ext === "jpg" || ext === "jpeg") ? "image/jpeg" : ("image/" + ext);
        copyProc.command = [
            "sh", "-c",
            "dms cl copy -t " + mime + " < " + JSON.stringify(currentFilePath) + " 2>/dev/null || wl-copy -t " + mime + " < " + JSON.stringify(currentFilePath) + " 2>/dev/null || wl-copy < " + JSON.stringify(currentFilePath)
        ];
        copyProc.running = true;
    }

    function copyPathToClipboard() {
        if (!currentFilePath) return;
        copyPathProc.command = [
            "sh", "-c",
            "dms cl copy " + JSON.stringify(currentFilePath) + " 2>/dev/null || wl-copy " + JSON.stringify(currentFilePath)
        ];
        copyPathProc.running = true;
    }

    function openContainingFolder() {
        if (!currentFilePath) return;
        const dir = currentMeta.directory || currentFilePath.substring(0, currentFilePath.lastIndexOf("/"));
        Quickshell.execDetached(["xdg-open", dir]);
    }

    function setAsWallpaper() {
        if (!currentFilePath) return;
        const path = currentFilePath;
        // Try DMS IPC first; fall back to swww, then swaybg
        wallpaperProc.command = [
            "sh", "-c",
            "dms ipc call wallpaper set " + JSON.stringify(path) +
            " 2>/dev/null || swww img " + JSON.stringify(path) +
            " 2>/dev/null || swaybg -i " + JSON.stringify(path) + " 2>/dev/null"
        ];
        wallpaperProc.running = true;
    }

    function showToast(message, isError) {
        const method = isError ? "error" : "info";
        Quickshell.execDetached([
            "sh", "-c",
            "dms ipc call toast " + method + " " + JSON.stringify(message) + " 2>/dev/null || notify-send " + (isError ? "-u critical " : "") + JSON.stringify("DankView") + " " + JSON.stringify(message)
        ]);
    }

    property string lastTrashedPath: ""

    function moveToTrash() {
        if (!currentFilePath) return;
        lastTrashedPath = currentFilePath;
        trashProc.command = ["gio", "trash", currentFilePath];
        trashProc.running = true;
    }

    function undoTrash() {
        restoreProc.command = [
            "python3", "-c",
            `
import os, glob, urllib.parse, shutil

target = ${JSON.stringify(lastTrashedPath)}
trash_dir = os.path.expanduser("~/.local/share/Trash")
info_files = glob.glob(os.path.join(trash_dir, "info", "*.trashinfo"))
if not info_files:
    exit(0)

info_files.sort(key=os.path.getmtime, reverse=True)
for info in info_files:
    base = os.path.basename(info)[:-10]
    file_entry = os.path.join(trash_dir, "files", base)
    orig_path = None
    try:
        with open(info, "r", encoding="utf-8") as f:
            for line in f:
                if line.startswith("Path="):
                    orig_path = urllib.parse.unquote(line.strip()[5:])
                    break
    except Exception:
        continue

    if orig_path and os.path.exists(file_entry):
        if not target or orig_path == target:
            os.makedirs(os.path.dirname(orig_path), exist_ok=True)
            shutil.move(file_entry, orig_path)
            try:
                os.remove(info)
            except Exception:
                pass
            print(orig_path)
            break
`
        ];
        restoreProc.running = true;
    }

    function removeCurrentFromList() {
        const list = root.fileList.slice();
        list.splice(root.currentIndex, 1);
        root.fileList = list;
        if (root.currentIndex >= list.length) {
            root.currentIndex = Math.max(0, list.length - 1);
        }
    }
}
