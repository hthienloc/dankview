import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

Item {
    id: root

    property var cropOverlay: null

    height: 44

    component IslandButton: Rectangle {
        id: btn
        property string iconName: ""
        property real iconRotation: 0
        property string tooltipText: ""
        property bool isActive: false
        signal clicked()

        implicitWidth: 38
        implicitHeight: 38
        radius: 10
        color: isActive ? Theme.primaryContainer : (btnMouse.containsMouse ? Theme.surfaceContainerHighest : "transparent")

        Behavior on color {
            ColorAnimation { duration: 100 }
        }

        DankIcon {
            anchors.centerIn: parent
            name: btn.iconName
            rotation: btn.iconRotation
            size: 21
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

    component IslandSeparator: Rectangle {
        implicitWidth: 1
        implicitHeight: 20
        Layout.alignment: Qt.AlignVCenter
        Layout.leftMargin: 4
        Layout.rightMargin: 4
        color: Theme.outlineVariant
        opacity: 0.38
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
            height: 44
            width: zoomRow.implicitWidth + 12
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

                IslandSeparator {}

                IslandButton {
                    iconName: "crop_free"
                    tooltipText: "Fit to Window (0)"
                    onClicked: ImageService.fitToWindow()
                }
            }
        }

        // Center Island: Transform & Editing Controls (morphs into Crop controls in cropMode)
        Rectangle {
            id: editIsland
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            height: 44
            width: (ImageService.cropMode ? cropRow.implicitWidth : editRow.implicitWidth) + 16
            radius: 12
            color: Qt.rgba(Theme.surfaceContainerHigh.r, Theme.surfaceContainerHigh.g, Theme.surfaceContainerHigh.b, 0.88)
            border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.28)
            border.width: 1
            clip: true

            Behavior on width {
                NumberAnimation {
                    duration: Theme.shortDuration
                    easing.type: Theme.standardEasing
                }
            }

            // Normal editing tools row
            RowLayout {
                id: editRow
                anchors.centerIn: parent
                spacing: 2
                opacity: !ImageService.cropMode ? 1.0 : 0.0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.shortDuration
                        easing.type: Theme.standardEasing
                    }
                }

                // Group 1: Rotation
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

                IslandSeparator {}

                // Group 2: Flip
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

                IslandSeparator {}

                // Group 3: Crop
                IslandButton {
                    iconName: "crop"
                    tooltipText: "Crop (X / Ctrl+X)"
                    isActive: ImageService.cropMode
                    onClicked: ImageService.toggleCropMode()
                }

                IslandSeparator {
                    visible: ImageService.isAnimated
                }

                // Group 4: Animation Play/Pause if image is animated
                IslandButton {
                    visible: ImageService.isAnimated
                    iconName: ImageService.isPlaying ? "pause" : "play_arrow"
                    tooltipText: ImageService.isPlaying ? "Pause Animation (Space)" : "Play Animation (Space)"
                    onClicked: ImageService.togglePlayback()
                }
            }

            // Morphed Crop Controls Row
            RowLayout {
                id: cropRow
                anchors.centerIn: parent
                spacing: 4
                opacity: ImageService.cropMode ? 1.0 : 0.0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.shortDuration
                        easing.type: Theme.standardEasing
                    }
                }

                // Aspect ratio presets
                Repeater {
                    model: [
                        { label: "Free",  ar: "" },
                        { label: "1:1",   ar: "1:1" },
                        { label: "4:3",   ar: "4:3" },
                        { label: "16:9",  ar: "16:9" },
                        { label: "3:2",   ar: "3:2" }
                    ]
                    delegate: Rectangle {
                        readonly property bool isSelected: root.cropOverlay ? root.cropOverlay.aspectRatio === modelData.ar : false
                        implicitWidth: arLabel.implicitWidth + 14
                        implicitHeight: 32
                        radius: 8
                        color: isSelected
                            ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.25)
                            : (arMouse.containsMouse ? Theme.surfaceContainerHighest : "transparent")
                        border.color: isSelected
                            ? Theme.primary
                            : Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.35)
                        border.width: 1

                        Text {
                            id: arLabel
                            anchors.centerIn: parent
                            text: modelData.label
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Medium
                            color: isSelected ? Theme.primary : Theme.surfaceText
                        }

                        MouseArea {
                            id: arMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.cropOverlay) {
                                    root.cropOverlay.aspectRatio = modelData.ar;
                                    root.cropOverlay._applyAspect();
                                }
                            }
                        }
                    }
                }

                IslandSeparator {}

                // Reset button
                IslandButton {
                    iconName: "restart_alt"
                    tooltipText: "Reset Crop"
                    onClicked: {
                        if (root.cropOverlay) {
                            root.cropOverlay.aspectRatio = "";
                            root.cropOverlay.cropX = root.cropOverlay.imageX;
                            root.cropOverlay.cropY = root.cropOverlay.imageY;
                            root.cropOverlay.cropW = root.cropOverlay.imageW;
                            root.cropOverlay.cropH = root.cropOverlay.imageH;
                        }
                    }
                }

                IslandSeparator {}

                // Cancel button
                Rectangle {
                    implicitWidth: cancelRow.implicitWidth + 16
                    implicitHeight: 32
                    radius: 8
                    color: cancelMouse.containsMouse ? Theme.surfaceContainerHighest : "transparent"
                    border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.35)
                    border.width: 1

                    RowLayout {
                        id: cancelRow
                        anchors.centerIn: parent
                        spacing: 4
                        DankIcon { name: "close"; size: 16; color: Theme.surfaceText }
                        Text {
                            text: "Cancel"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }
                    }

                    MouseArea {
                        id: cancelMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.cropOverlay)
                                root.cropOverlay.cancelled();
                        }
                    }
                }

                // Done / Apply button
                Rectangle {
                    implicitWidth: doneRow.implicitWidth + 16
                    implicitHeight: 32
                    radius: 8
                    color: doneMouse.containsMouse
                        ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.85)
                        : Theme.primary

                    RowLayout {
                        id: doneRow
                        anchors.centerIn: parent
                        spacing: 4
                        DankIcon { name: "check"; size: 16; color: Theme.primaryText }
                        Text {
                            text: "Done"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.DemiBold
                            color: Theme.primaryText
                        }
                    }

                    MouseArea {
                        id: doneMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.cropOverlay)
                                root.cropOverlay.applyCrop();
                        }
                    }
                }
            }
        }

        // Right Island: Delete / Trash button (Accent Red)
        Rectangle {
            id: deleteBtn
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 38
            height: 38
            radius: 10
            color: deleteMouse.containsMouse ? Qt.lighter(Theme.error, 1.15) : Theme.error

            Behavior on color { ColorAnimation { duration: 100 } }

            DankIcon {
                anchors.centerIn: parent
                name: "delete"
                size: 21
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
