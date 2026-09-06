import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services

Rectangle {
    id: root

    height: 48
    implicitWidth: layout.implicitWidth + 24
    radius: 24
    color: Theme.surfaceContainer ? Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.90) : "#e6222222"
    border.color: Theme.outlineVariant ? Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.2) : "#33ffffff"
    border.width: 1

    component ToolButton: Rectangle {
        property string iconText: ""
        property string tooltip: ""
        signal clicked

        width: 36
        height: 36
        radius: 18
        color: mouse.containsMouse ? (Theme.surfaceContainerHighest || "#444444") : "transparent"

        Text {
            anchors.centerIn: parent
            text: iconText
            font.pixelSize: 15
            color: Theme.onSurface || "#ffffff"
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    component BarSeparator: Rectangle {
        width: 1
        height: 20
        color: Theme.outlineVariant || "#44ffffff"
        opacity: 0.3
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 4

        ToolButton {
            iconText: "‹"
            tooltip: "Previous Image (Left)"
            onClicked: ImageService.prevImage()
        }

        ToolButton {
            iconText: "›"
            tooltip: "Next Image (Right)"
            onClicked: ImageService.nextImage()
        }

        BarSeparator {}

        ToolButton {
            iconText: "↺"
            tooltip: "Rotate Counter-Clockwise"
            onClicked: ImageService.rotateCounterClockwise()
        }

        ToolButton {
            iconText: "↻"
            tooltip: "Rotate Clockwise"
            onClicked: ImageService.rotateClockwise()
        }

        ToolButton {
            iconText: "⇄"
            tooltip: "Flip Horizontally"
            onClicked: ImageService.toggleFlipHorizontal()
        }

        BarSeparator {}

        ToolButton {
            iconText: "−"
            tooltip: "Zoom Out"
            onClicked: ImageService.zoomOut()
        }

        ToolButton {
            iconText: "+"
            tooltip: "Zoom In"
            onClicked: ImageService.zoomIn()
        }

        ToolButton {
            iconText: "1:1"
            tooltip: "Actual Size"
            onClicked: ImageService.resetZoom()
        }

        BarSeparator {}

        ToolButton {
            iconText: "📋"
            tooltip: "Copy to Clipboard"
            onClicked: ImageService.copyToClipboard()
        }

        ToolButton {
            iconText: "🗑"
            tooltip: "Move to Trash"
            onClicked: ImageService.moveToTrash()
        }
    }
}
