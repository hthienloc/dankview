import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

Rectangle {
    id: root

    height: 52
    implicitWidth: layout.implicitWidth + 28
    radius: 26
    color: Qt.rgba(Theme.surfaceContainerHigh.r, Theme.surfaceContainerHigh.g, Theme.surfaceContainerHigh.b, 0.94)
    border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.35)
    border.width: 1

    component BarSeparator: Rectangle {
        width: 1
        height: 22
        color: Theme.outlineVariant
        opacity: 0.35
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 5

        DankActionButton {
            iconName: "rotate_left"
            iconSize: 20
            iconColor: Theme.surfaceText
            buttonSize: 38
            tooltipText: "Rotate Counter-Clockwise (Shift+R)"
            tooltipSide: "top"
            onClicked: ImageService.rotateCounterClockwise()
        }

        DankActionButton {
            iconName: "rotate_right"
            iconSize: 20
            iconColor: Theme.surfaceText
            buttonSize: 38
            tooltipText: "Rotate Clockwise (R)"
            tooltipSide: "top"
            onClicked: ImageService.rotateClockwise()
        }

        DankActionButton {
            iconName: "flip"
            iconSize: 20
            iconColor: Theme.surfaceText
            buttonSize: 38
            tooltipText: "Flip Horizontally (Ctrl+M / H)"
            tooltipSide: "top"
            onClicked: ImageService.toggleFlipHorizontal()
        }

        BarSeparator {}

        DankActionButton {
            iconName: "zoom_out"
            iconSize: 20
            iconColor: Theme.surfaceText
            buttonSize: 38
            tooltipText: "Zoom Out (-)"
            tooltipSide: "top"
            onClicked: ImageService.zoomOut()
        }

        DankActionButton {
            iconName: "zoom_in"
            iconSize: 20
            iconColor: Theme.surfaceText
            buttonSize: 38
            tooltipText: "Zoom In (+)"
            tooltipSide: "top"
            onClicked: ImageService.zoomIn()
        }

        DankActionButton {
            iconName: "fit_screen"
            iconSize: 20
            iconColor: Theme.surfaceText
            buttonSize: 38
            tooltipText: "Fit to Window (0)"
            tooltipSide: "top"
            onClicked: ImageService.fitToWindow()
        }

        DankActionButton {
            iconName: "aspect_ratio"
            iconSize: 20
            iconColor: Theme.surfaceText
            buttonSize: 38
            tooltipText: "Actual Size 100% (Ctrl+1)"
            tooltipSide: "top"
            onClicked: ImageService.actualSize()
        }

        BarSeparator {}

        DankActionButton {
            iconName: "content_copy"
            iconSize: 20
            iconColor: Theme.surfaceText
            buttonSize: 38
            tooltipText: "Copy to Clipboard (Ctrl+C)"
            tooltipSide: "top"
            onClicked: ImageService.copyToClipboard()
        }

        DankActionButton {
            iconName: "delete"
            iconSize: 20
            iconColor: Theme.error
            buttonSize: 38
            tooltipText: "Move to Trash (Delete)"
            tooltipSide: "top"
            onClicked: ImageService.moveToTrash()
        }
    }
}
