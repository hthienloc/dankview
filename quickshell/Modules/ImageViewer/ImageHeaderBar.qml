import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services

Rectangle {
    id: root

    height: 52
    color: Theme.surfaceContainer ? Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.85) : "#cc1e1e1e"
    radius: 0

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 12

        // Left: File name
        Text {
            Layout.fillWidth: true
            text: ImageService.currentFileName || "DankView"
            font.pixelSize: 14
            font.weight: Font.Medium
            color: Theme.onSurface || "#ffffff"
            elide: Text.ElideMiddle
        }

        // Center: Counter e.g. "3 / 12"
        Rectangle {
            visible: ImageService.fileList.length > 0
            height: 28
            width: counterText.implicitWidth + 16
            radius: 14
            color: Theme.surfaceContainerHigh || "#333333"

            Text {
                id: counterText
                anchors.centerIn: parent
                text: (ImageService.currentIndex + 1) + " / " + ImageService.fileList.length
                font.pixelSize: 12
                color: Theme.onSurfaceVariant || "#cccccc"
            }
        }

        // Right actions
        // Zoom % button
        Rectangle {
            height: 32
            width: zoomText.implicitWidth + 20
            radius: 16
            color: zoomMouse.containsMouse ? (Theme.surfaceContainerHighest || "#444444") : (Theme.surfaceContainerHigh || "#333333")

            Text {
                id: zoomText
                anchors.centerIn: parent
                text: Math.round(ImageService.zoom * 100) + "%"
                font.pixelSize: 12
                font.weight: Font.Medium
                color: Theme.onSurface || "#ffffff"
            }

            MouseArea {
                id: zoomMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: ImageService.resetZoom()
            }
        }

        // Inspector Toggle Button
        Rectangle {
            width: 32
            height: 32
            radius: 16
            color: ImageService.inspectorOpen ? (Theme.primary || "#3b82f6") : (infoMouse.containsMouse ? (Theme.surfaceContainerHighest || "#444444") : "transparent")

            Text {
                anchors.centerIn: parent
                text: "ℹ"
                font.pixelSize: 14
                color: ImageService.inspectorOpen ? (Theme.onPrimary || "#ffffff") : (Theme.onSurface || "#ffffff")
            }

            MouseArea {
                id: infoMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: ImageService.toggleInspector()
            }
        }

        // Fullscreen Toggle Button
        Rectangle {
            width: 32
            height: 32
            radius: 16
            color: fsMouse.containsMouse ? (Theme.surfaceContainerHighest || "#444444") : "transparent"

            Text {
                anchors.centerIn: parent
                text: ImageService.isFullscreen ? "⤦" : "⤢"
                font.pixelSize: 15
                color: Theme.onSurface || "#ffffff"
            }

            MouseArea {
                id: fsMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: ImageService.toggleFullscreen()
            }
        }
    }
}
