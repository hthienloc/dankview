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

        // View & Zoom controls
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
            tooltipText: "Actual Size 100% (1 / Ctrl+1)"
            tooltipSide: "top"
            onClicked: ImageService.actualSize()
        }

        BarSeparator {}

        // Transform & Editing tools
        DankActionButton {
            iconName: "rotate_left"
            iconSize: 20
            iconColor: Theme.surfaceText
            buttonSize: 38
            tooltipText: "Rotate Counter-Clockwise (L / Shift+R)"
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
            tooltipText: "Flip Horizontally (H / M)"
            tooltipSide: "top"
            onClicked: ImageService.toggleFlipHorizontal()
        }

        DankActionButton {
            iconName: "crop"
            iconSize: 20
            iconColor: ImageService.cropMode ? Theme.primary : Theme.surfaceText
            buttonSize: 38
            tooltipText: "Crop (X / Ctrl+X)"
            tooltipSide: "top"
            onClicked: ImageService.toggleCropMode()
        }

        BarSeparator {}

        // Export & Clipboard actions
        DankActionButton {
            iconName: "content_copy"
            iconSize: 20
            iconColor: Theme.surfaceText
            buttonSize: 38
            tooltipText: "Copy to Clipboard (C / Ctrl+C)"
            tooltipSide: "top"
            onClicked: ImageService.copyToClipboard()
        }

        DankActionButton {
            iconName: "save"
            iconSize: 20
            iconColor: ImageService.saveMode ? Theme.primary : Theme.surfaceText
            buttonSize: 38
            tooltipText: "Save As / Export (S / Ctrl+S)"
            tooltipSide: "top"
            onClicked: ImageService.openSaveDialog()
        }

        BarSeparator {}

        // Destructive action (Trash)
        DankActionButton {
            iconName: "delete"
            iconSize: 20
            iconColor: Theme.error
            buttonSize: 38
            tooltipText: "Move to Trash (D / Delete)"
            tooltipSide: "top"
            onClicked: ImageService.moveToTrash()
        }
    }
}
