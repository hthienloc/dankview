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
    property int rotation: 0
    property bool flipH: false
    property bool flipV: false
    property bool inspectorOpen: false
    property bool isFullscreen: Quickshell.env("DVIEW_FULLSCREEN") === "1"
    property real panX: 0
    property real panY: 0

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

    function loadDirectoryFor(filePath) {
        listProc.command = ["dview", "-list", filePath];
        listProc.running = true;
    }

    function fetchMetadata() {
        if (!currentFilePath) return;
        infoProc.command = ["dview", "-info", currentFilePath];
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
                removeCurrentFromList();
            }
        }
    }

    Process {
        id: copyProc
        running: false
        command: []
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
        rotation = (rotation + 90) % 360;
    }

    function rotateCounterClockwise() {
        rotation = (rotation + 270) % 360;
    }

    function toggleFlipHorizontal() {
        flipH = !flipH;
    }

    function toggleFlipVertical() {
        flipV = !flipV;
    }

    function zoomIn() {
        zoom = Math.min(zoom * 1.25, 30.0);
    }

    function zoomOut() {
        zoom = Math.max(zoom / 1.25, 0.05);
    }

    function resetZoom() {
        zoom = 1.0;
        panX = 0;
        panY = 0;
    }

    function resetTransform() {
        zoom = 1.0;
        rotation = 0;
        flipH = false;
        flipV = false;
        panX = 0;
        panY = 0;
    }

    function toggleInspector() {
        inspectorOpen = !inspectorOpen;
    }

    function toggleFullscreen() {
        isFullscreen = !isFullscreen;
    }

    function copyToClipboard() {
        if (!currentFilePath) return;
        // Copies image data or file path to wayland clipboard via wl-copy
        copyProc.command = ["wl-copy", "--type", "text/uri-list", "file://" + currentFilePath];
        copyProc.running = true;
    }

    function moveToTrash() {
        if (!currentFilePath) return;
        trashProc.command = ["gio", "trash", currentFilePath];
        trashProc.running = true;
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
