import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.DankCommon.Widgets
import "."

FloatingWindow {
    id: window

    title: ImageService.currentFileName ? (ImageService.currentFileName + " — DankView") : "DankView"
    minimumSize: Qt.size(480, 360)
    implicitWidth: 1050
    implicitHeight: 720
    color: Theme.surfaceContainerLowest
    visible: true

    property bool showOverlays: true

    Timer {
        id: hideOverlaysTimer
        interval: 3000
        repeat: false
        onTriggered: {
            if (!headerHover.hovered && !bottomHover.hovered && !ImageService.inspectorOpen) {
                window.showOverlays = false;
            }
        }
    }

    Item {
        id: rootContent
        anchors.fill: parent
        focus: true

        // Keyboard navigation and shortcuts
        Keys.onPressed: event => {
            switch (event.key) {
            // Navigation
            case Qt.Key_Left:
            case Qt.Key_PageUp:
            case Qt.Key_Backspace:
                ImageService.prevImage();
                event.accepted = true;
                break;
            case Qt.Key_Right:
            case Qt.Key_PageDown:
            case Qt.Key_Space:
                ImageService.nextImage();
                event.accepted = true;
                break;

            // Zoom & Scale
            case Qt.Key_Plus:
            case Qt.Key_Equal:
                ImageService.zoomIn();
                event.accepted = true;
                break;
            case Qt.Key_Minus:
                ImageService.zoomOut();
                event.accepted = true;
                break;
            case Qt.Key_0:
                ImageService.fitToWindow();
                event.accepted = true;
                break;
            case Qt.Key_1:
                ImageService.actualSize();
                event.accepted = true;
                break;

            // Rotation & Orientation
            case Qt.Key_R:
                if (event.modifiers & Qt.ShiftModifier) {
                    ImageService.rotateCounterClockwise();
                } else {
                    ImageService.rotateClockwise();
                }
                event.accepted = true;
                break;
            case Qt.Key_L:
                ImageService.rotateCounterClockwise();
                event.accepted = true;
                break;
            case Qt.Key_H:
            case Qt.Key_M:
                ImageService.toggleFlipHorizontal();
                event.accepted = true;
                break;
            case Qt.Key_V:
                ImageService.toggleFlipVertical();
                event.accepted = true;
                break;

            // Actions & Editing
            case Qt.Key_C:
                ImageService.copyToClipboard();
                event.accepted = true;
                break;
            case Qt.Key_X:
                ImageService.toggleCropMode();
                event.accepted = true;
                break;
            case Qt.Key_S:
                saveDialog.cropRegion = null;
                ImageService.openSaveDialog();
                event.accepted = true;
                break;
            case Qt.Key_P:
                ImageService.printImage();
                event.accepted = true;
                break;
            case Qt.Key_W:
                ImageService.setAsWallpaper();
                event.accepted = true;
                break;

            // File & Trash Management
            case Qt.Key_O:
                ImageService.openFileDialog();
                event.accepted = true;
                break;
            case Qt.Key_Delete:
            case Qt.Key_D:
                ImageService.moveToTrash();
                event.accepted = true;
                break;
            case Qt.Key_Z:
            case Qt.Key_U:
                ImageService.undoTrash();
                event.accepted = true;
                break;

            // View & Window Controls
            case Qt.Key_F:
            case Qt.Key_F11:
                windowControls.tryToggleMaximize();
                event.accepted = true;
                break;
            case Qt.Key_I:
                ImageService.toggleInspector();
                event.accepted = true;
                break;
            case Qt.Key_K:
            case Qt.Key_Tab:
                ImageService.toggleLockUI();
                event.accepted = true;
                break;

            // Modal & Dialog Keys
            case Qt.Key_Return:
            case Qt.Key_Enter:
                if (ImageService.cropMode && !cropOverlay.promptVisible) {
                    cropOverlay.applyCrop();
                    event.accepted = true;
                }
                break;
            case Qt.Key_Escape:
                if (ImageService.uiLocked) {
                    ImageService.uiLocked = false;
                    window.showOverlays = true;
                    hideOverlaysTimer.restart();
                    event.accepted = true;
                } else if (cropOverlay.promptVisible) {
                    cropOverlay.promptVisible = false;
                    event.accepted = true;
                } else if (ImageService.cropMode) {
                    ImageService.cropMode = false;
                    event.accepted = true;
                } else if (ImageService.saveMode) {
                    ImageService.saveMode = false;
                    saveDialog.cropRegion = null;
                    event.accepted = true;
                } else if (ImageService.inspectorOpen) {
                    ImageService.inspectorOpen = false;
                    event.accepted = true;
                } else if (window.maximized) {
                    windowControls.tryToggleMaximize();
                    event.accepted = true;
                } else {
                    Qt.quit();
                }
                break;
            }
        }

        // Global mouse activity tracker to show/hide controls
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onPositionChanged: {
                if (!ImageService.uiLocked) {
                    window.showOverlays = true;
                    hideOverlaysTimer.restart();
                }
            }
        }

        // Floating Window Controls (resizing, moving, maximizing)
        FloatingWindowControls {
            id: windowControls
            targetWindow: window
        }

        // Main Image Canvas
        ImageCanvas {
            anchors.fill: parent
        }

        // Dismiss inspector when clicking outside it
        MouseArea {
            anchors.fill: parent
            enabled: ImageService.inspectorOpen
            visible: enabled
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: ImageService.inspectorOpen = false
        }

        // Top Header Bar
        ImageHeaderBar {
            id: headerBar
            windowControls: windowControls
            targetWindow: window
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            opacity: !ImageService.uiLocked && (window.showOverlays || ImageService.inspectorOpen || ImageService.cropMode) ? 1.0 : 0.0
            visible: opacity > 0

            HoverHandler {
                id: headerHover
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.shortDuration
                    easing.type: Theme.standardEasing
                }
            }
        }

        // Bottom Tool Bar (Floating Pill)
        ImageBottomBar {
            id: bottomBar
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: !ImageService.uiLocked && window.showOverlays && ImageService.currentFilePath !== "" && !ImageService.inspectorOpen && !ImageService.cropMode && !ImageService.saveMode ? 1.0 : 0.0
            visible: opacity > 0

            HoverHandler {
                id: bottomHover
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.shortDuration
                    easing.type: Theme.standardEasing
                }
            }
        }

        // Floating Lock Badge (shown only when UI is locked and hovered nearby)
        Item {
            id: lockBadgeArea
            anchors.top: parent.top
            anchors.right: parent.right
            width: 76
            height: 76
            z: 90
            visible: ImageService.uiLocked

            Rectangle {
                id: floatingLockBadge
                anchors.centerIn: parent
                width: 40
                height: 40
                radius: 20
                color: lockBadgeMouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh
                opacity: lockBadgeMouse.containsMouse ? 0.95 : 0.0
                border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.3)
                border.width: 1

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.shortDuration
                        easing.type: Theme.standardEasing
                    }
                }

                DankIcon {
                    anchors.centerIn: parent
                    name: "lock_open"
                    size: 20
                    color: Theme.primary
                }
            }

            MouseArea {
                id: lockBadgeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    ImageService.toggleLockUI();
                    window.showOverlays = true;
                    hideOverlaysTimer.restart();
                }
            }
        }

        // Slide-out EXIF Inspector Drawer
        ExifInspector {
            id: inspector
            anchors.top: headerBar.bottom
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: ImageService.inspectorOpen ? 0 : -width
            visible: anchors.rightMargin > -width || ImageService.inspectorOpen

            Behavior on anchors.rightMargin {
                NumberAnimation {
                    duration: Theme.shortDuration
                    easing.type: Theme.standardEasing
                }
            }
        }

        // Crop Overlay
        CropOverlay {
            id: cropOverlay
            anchors.fill: parent
            visible: ImageService.cropMode
            imageX: {
                if (!visible) return 0;
                return (parent.width - imageW) / 2 + ImageService.panX;
            }
            imageY: {
                if (!visible) return 0;
                return (parent.height - imageH) / 2 + ImageService.panY;
            }
            imageW: {
                if (!visible) return 1;
                const m = ImageService.currentMeta;
                return m.width > 0 ? m.width * ImageService.fitScale * ImageService.zoom : 1;
            }
            imageH: {
                if (!visible) return 1;
                const m = ImageService.currentMeta;
                return m.height > 0 ? m.height * ImageService.fitScale * ImageService.zoom : 1;
            }
            srcW: ImageService.currentMeta.width || 1
            srcH: ImageService.currentMeta.height || 1

            onCropped: (x, y, w, h) => ImageService.executeCrop(x, y, w, h)
            onSaveCopyRequested: (x, y, w, h) => ImageService.saveCropCopy(x, y, w, h)
            onCopyRequested: (x, y, w, h) => ImageService.copyCropToClipboard(x, y, w, h)
            onSaveAsRequested: (x, y, w, h) => {
                ImageService.cropMode = false;
                saveDialog.cropRegion = { x: x, y: y, w: w, h: h };
                saveDialog.customDestPath = "";
                ImageService.saveMode = true;
            }
            onCancelled: ImageService.cropMode = false
        }

        // Save As / Export Dialog
        SaveDialog {
            id: saveDialog
            anchors.fill: parent
            visible: ImageService.saveMode
            onCancelled: {
                ImageService.saveMode = false;
                saveDialog.cropRegion = null;
            }
            onSaved: {
                ImageService.saveMode = false;
                saveDialog.cropRegion = null;
            }
        }
    }
}
