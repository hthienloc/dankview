import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

Rectangle {
    id: root

    height: 48
    implicitWidth: layout.implicitWidth + 24
    radius: 24
    color: Qt.rgba(Theme.surfaceContainerHigh.r, Theme.surfaceContainerHigh.g, Theme.surfaceContainerHigh.b, 0.92)
    border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.35)
    border.width: 1

    component BarSeparator: Rectangle {
        width: 1
        height: 20
        color: Theme.outlineVariant
        opacity: 0.35
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 4

        DankActionButton {
            iconName: "chevron_left"
            iconSize: 20
            iconColor: Theme.surfaceText
            buttonSize: 36
            tooltipText: "Previous Image (Left)"
            tooltipSide: "top"
            onClicked: ImageService.prevImage()
        }

        DankActionButton {
            iconName: "chevron_right"
            iconSize: 20
            iconColor: Theme.surfaceText
            buttonSize: 36
            tooltipText: "Next Image (Right)"
            tooltipSide: "top"
            onClicked: ImageService.nextImage()
        }

        BarSeparator {}

        DankActionButton {
            iconName: "rotate_left"
            iconSize: 18
            iconColor: Theme.surfaceText
            buttonSize: 36
            tooltipText: "Rotate Counter-Clockwise (Shift+R)"
            tooltipSide: "top"
            onClicked: ImageService.rotateCounterClockwise()
        }

        DankActionButton {
            iconName: "rotate_right"
            iconSize: 18
            iconColor: Theme.surfaceText
            buttonSize: 36
            tooltipText: "Rotate Clockwise (R)"
            tooltipSide: "top"
            onClicked: ImageService.rotateClockwise()
        }

        DankActionButton {
            iconName: "flip"
            iconSize: 18
            iconColor: Theme.surfaceText
            buttonSize: 36
            tooltipText: "Flip Horizontally"
            tooltipSide: "top"
            onClicked: ImageService.toggleFlipHorizontal()
        }

        BarSeparator {}

        DankActionButton {
            iconName: "zoom_out"
            iconSize: 18
            iconColor: Theme.surfaceText
            buttonSize: 36
            tooltipText: "Zoom Out (-)"
            tooltipSide: "top"
            onClicked: ImageService.zoomOut()
        }

        DankActionButton {
            iconName: "zoom_in"
            iconSize: 18
            iconColor: Theme.surfaceText
            buttonSize: 36
            tooltipText: "Zoom In (+)"
            tooltipSide: "top"
            onClicked: ImageService.zoomIn()
        }

        DankActionButton {
            iconName: "aspect_ratio"
            iconSize: 18
            iconColor: Theme.surfaceText
            buttonSize: 36
            tooltipText: "Actual Size 100% (0)"
            tooltipSide: "top"
            onClicked: ImageService.resetZoom()
        }

        BarSeparator {}

        DankActionButton {
            iconName: "content_copy"
            iconSize: 18
            iconColor: Theme.surfaceText
            buttonSize: 36
            tooltipText: "Copy to Clipboard (Ctrl+C)"
            tooltipSide: "top"
            onClicked: ImageService.copyToClipboard()
        }

        DankActionButton {
            iconName: "delete"
            iconSize: 18
            iconColor: Theme.error
            buttonSize: 36
            tooltipText: "Move to Trash (Delete)"
            tooltipSide: "top"
            onClicked: ImageService.moveToTrash()
        }
    }
}
