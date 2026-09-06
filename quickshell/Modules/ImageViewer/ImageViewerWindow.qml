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

        // Keyboard navigation
        Keys.onPressed: event => {
            switch (event.key) {
            case Qt.Key_Left:
            case Qt.Key_PageUp:
            case Qt.Key_Backspace:
                ImageService.prevImage();
                event.accepted = true;
                break;
            case Qt.Key_Right:
            case Qt.Key_PageDown:
                ImageService.nextImage();
                event.accepted = true;
                break;
            case Qt.Key_Space:
                if (ImageService.isAnimated) {
                    ImageService.togglePlayback();
                } else {
                    ImageService.nextImage();
                }
                event.accepted = true;
                break;
            case Qt.Key_Plus:
            case Qt.Key_Equal:
                ImageService.zoomIn();
                event.accepted = true;
                break;
            case Qt.Key_Minus:
                ImageService.zoomOut();
                event.accepted = true;
                break;
            case Qt.Key_1:
                if (event.modifiers & Qt.ControlModifier) {
                    ImageService.actualSize();
                    event.accepted = true;
                }
                break;
            case Qt.Key_0:
                ImageService.fitToWindow();
                event.accepted = true;
                break;
            case Qt.Key_O:
                if (event.modifiers & Qt.ControlModifier) {
                    ImageService.openFileDialog();
                    event.accepted = true;
                }
                break;
            case Qt.Key_M:
                if (event.modifiers & Qt.ControlModifier) {
                    ImageService.toggleFlipHorizontal();
                    event.accepted = true;
                }
                break;
            case Qt.Key_H:
                ImageService.toggleFlipHorizontal();
                event.accepted = true;
                break;
            case Qt.Key_V:
                ImageService.toggleFlipVertical();
                event.accepted = true;
                break;
            case Qt.Key_R:
                if (event.modifiers & Qt.ShiftModifier) {
                    ImageService.rotateCounterClockwise();
                } else {
                    ImageService.rotateClockwise();
                }
                event.accepted = true;
                break;
            case Qt.Key_F:
            case Qt.Key_F11:
                windowControls.tryToggleMaximize();
                event.accepted = true;
                break;
            case Qt.Key_I:
                ImageService.toggleInspector();
                event.accepted = true;
                break;
            case Qt.Key_C:
                if (event.modifiers & Qt.ControlModifier) {
                    ImageService.copyToClipboard();
                    event.accepted = true;
                }
                break;
            case Qt.Key_Delete:
                ImageService.moveToTrash();
                event.accepted = true;
                break;
            case Qt.Key_Escape:
                if (ImageService.inspectorOpen) {
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
                window.showOverlays = true;
                hideOverlaysTimer.restart();
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

        // Top Header Bar
        ImageHeaderBar {
            id: headerBar
            windowControls: windowControls
            targetWindow: window
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            opacity: window.showOverlays || ImageService.inspectorOpen ? 1.0 : 0.0
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
            opacity: window.showOverlays && !ImageService.inspectorOpen ? 1.0 : 0.0
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
    }
}
