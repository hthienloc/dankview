import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

Item {
    id: root

    height: 40

    component IslandButton: Rectangle {
        id: btn
        property string iconName: ""
        property real iconRotation: 0
        property string tooltipText: ""
        property bool isActive: false
        signal clicked()

        implicitWidth: 36
        implicitHeight: 36
        radius: 8
        color: isActive ? Theme.primaryContainer : (btnMouse.containsMouse ? Theme.surfaceContainerHighest : "transparent")

        Behavior on color {
            ColorAnimation { duration: 100 }
        }

        DankIcon {
            anchors.centerIn: parent
            name: btn.iconName
            rotation: btn.iconRotation
            size: 18
            color: btn.isActive ? Theme.primary : Theme.surfaceText
        }

        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
    }

    // Toolbar Row containing 3 islands
    Item {
        id: toolbarRow
        anchors.fill: parent

        // Left Island: Zoom Controls
        Rectangle {
            id: zoomIsland
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            height: 40
            width: zoomRow.implicitWidth + 8
            radius: 12
            color: Qt.rgba(Theme.surfaceContainerHigh.r, Theme.surfaceContainerHigh.g, Theme.surfaceContainerHigh.b, 0.88)
            border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.28)
            border.width: 1

            RowLayout {
                id: zoomRow
                anchors.centerIn: parent
                spacing: 2

                IslandButton {
                    iconName: "zoom_out"
                    tooltipText: "Zoom Out (-)"
                    onClicked: ImageService.zoomOut()
                }

                IslandButton {
                    iconName: "zoom_in"
                    tooltipText: "Zoom In (+)"
                    onClicked: ImageService.zoomIn()
                }

                IslandButton {
                    iconName: "crop_free"
                    tooltipText: "Fit to Window (0)"
                    onClicked: ImageService.fitToWindow()
                }
            }
        }

        // Center Island: Transform & Editing Controls
        Rectangle {
            id: editIsland
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            height: 40
            width: editRow.implicitWidth + 8
            radius: 12
            color: Qt.rgba(Theme.surfaceContainerHigh.r, Theme.surfaceContainerHigh.g, Theme.surfaceContainerHigh.b, 0.88)
            border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.28)
            border.width: 1

            RowLayout {
                id: editRow
                anchors.centerIn: parent
                spacing: 2

                IslandButton {
                    iconName: "undo"
                    tooltipText: "Undo (Ctrl+Z)"
                    enabled: ImageService.canUndo
                    opacity: enabled ? 1.0 : 0.35
                    onClicked: ImageService.undoTransform()
                }

                IslandButton {
                    iconName: "redo"
                    tooltipText: "Redo (Ctrl+Y)"
                    enabled: ImageService.canRedo
                    opacity: enabled ? 1.0 : 0.35
                    onClicked: ImageService.redoTransform()
                }

                IslandButton {
                    iconName: "rotate_left"
                    tooltipText: "Rotate Counter-Clockwise (L / Shift+R)"
                    onClicked: ImageService.rotateCounterClockwise()
                }

                IslandButton {
                    iconName: "rotate_right"
                    tooltipText: "Rotate Clockwise (R)"
                    onClicked: ImageService.rotateClockwise()
                }

                IslandButton {
                    iconName: "flip"
                    tooltipText: "Flip Horizontally (H / M)"
                    onClicked: ImageService.toggleFlipHorizontal()
                }

                IslandButton {
                    iconName: "flip"
                    iconRotation: 90
                    tooltipText: "Flip Vertically (V)"
                    onClicked: ImageService.toggleFlipVertical()
                }

                IslandButton {
                    iconName: "crop"
                    tooltipText: "Crop (X / Ctrl+X)"
                    isActive: ImageService.cropMode
                    onClicked: ImageService.toggleCropMode()
                }

                // Animation Play/Pause if image is animated
                IslandButton {
                    visible: ImageService.isAnimated
                    iconName: ImageService.isPlaying ? "pause" : "play_arrow"
                    tooltipText: ImageService.isPlaying ? "Pause Animation (Space)" : "Play Animation (Space)"
                    onClicked: ImageService.togglePlayback()
                }
            }
        }

        // Right Island: Actions (Copy & Delete)
        RowLayout {
            id: rightIsland
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            // Copy button
            Rectangle {
                width: 40
                height: 40
                radius: 12
                color: copyMouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.28)
                border.width: 1

                Behavior on color { ColorAnimation { duration: 100 } }

                DankIcon {
                    anchors.centerIn: parent
                    name: "content_copy"
                    size: 19
                    color: Theme.surfaceText
                }

                MouseArea {
                    id: copyMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ImageService.copyToClipboard()
                }
            }

            // Delete / Trash button (Accent Red)
            Rectangle {
                width: 40
                height: 40
                radius: 12
                color: deleteMouse.containsMouse ? Qt.lighter(Theme.error, 1.15) : Theme.error

                Behavior on color { ColorAnimation { duration: 100 } }

                DankIcon {
                    anchors.centerIn: parent
                    name: "delete"
                    size: 19
                    color: Theme.onError || "#ffffff"
                }

                MouseArea {
                    id: deleteMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ImageService.moveToTrash()
                }
            }
        }
    }
}
