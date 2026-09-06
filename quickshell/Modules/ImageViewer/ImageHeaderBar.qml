import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

Rectangle {
    id: root

    property var windowControls: null

    height: 48
    color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.88)
    border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.25)
    border.width: 1

    // Drag header to move window
    MouseArea {
        anchors.fill: parent
        onPressed: {
            if (root.windowControls)
                root.windowControls.tryStartMove();
        }
        onDoubleClicked: {
            if (root.windowControls)
                root.windowControls.tryToggleMaximize();
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 8
        spacing: 8

        // App/File Icon & Name
        DankIcon {
            name: "image"
            size: 20
            color: Theme.primary
        }

        Text {
            Layout.fillWidth: true
            text: ImageService.currentFileName || "DankView"
            font.family: Theme.fontFamily || "Google Sans Flex"
            font.pixelSize: 13
            font.weight: Font.Medium
            color: Theme.surfaceText
            elide: Text.ElideMiddle
        }

        // Center: Counter badge e.g. "3 / 12"
        Rectangle {
            visible: ImageService.fileList.length > 0
            height: 26
            width: counterText.implicitWidth + 16
            radius: 13
            color: Theme.surfaceContainerHighest

            Text {
                id: counterText
                anchors.centerIn: parent
                text: (ImageService.currentIndex + 1) + " / " + ImageService.fileList.length
                font.family: Theme.fontFamily || "Google Sans Flex"
                font.pixelSize: 11
                font.weight: Font.Medium
                color: Theme.surfaceVariantText
            }
        }

        // Zoom percentage badge
        Rectangle {
            height: 28
            width: zoomRow.implicitWidth + 14
            radius: 14
            color: zoomMouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh

            RowLayout {
                id: zoomRow
                anchors.centerIn: parent
                spacing: 4

                DankIcon {
                    name: "zoom_in"
                    size: 14
                    color: Theme.surfaceVariantText
                }

                Text {
                    text: Math.round(ImageService.zoom * 100) + "%"
                    font.family: Theme.fontFamily || "Google Sans Flex"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: Theme.surfaceText
                }
            }

            MouseArea {
                id: zoomMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: ImageService.resetZoom()
            }
        }

        // Inspector Toggle
        DankActionButton {
            iconName: "info"
            iconSize: 18
            iconColor: ImageService.inspectorOpen ? Theme.primary : Theme.surfaceText
            backgroundColor: ImageService.inspectorOpen ? Theme.surfaceContainerHighest : "transparent"
            tooltipText: "Image Properties (I)"
            tooltipSide: "bottom"
            onClicked: ImageService.toggleInspector()
        }

        // Fullscreen Toggle
        DankActionButton {
            iconName: ImageService.isFullscreen ? "fullscreen_exit" : "fullscreen"
            iconSize: 18
            iconColor: Theme.surfaceText
            tooltipText: ImageService.isFullscreen ? "Exit Fullscreen (F)" : "Fullscreen (F)"
            tooltipSide: "bottom"
            onClicked: ImageService.toggleFullscreen()
        }

        Rectangle {
            width: 1
            height: 18
            color: Theme.outlineVariant
            opacity: 0.4
        }

        // Window Controls (minimize, maximize, close)
        DankActionButton {
            visible: root.windowControls && root.windowControls.canMinimize
            iconName: "minimize"
            iconSize: 16
            iconColor: Theme.surfaceText
            tooltipText: "Minimize"
            tooltipSide: "bottom"
            onClicked: {
                if (root.windowControls)
                    root.windowControls.tryMinimize();
            }
        }

        DankActionButton {
            visible: root.windowControls && root.windowControls.supported
            iconName: "crop_square"
            iconSize: 15
            iconColor: Theme.surfaceText
            tooltipText: "Maximize"
            tooltipSide: "bottom"
            onClicked: {
                if (root.windowControls)
                    root.windowControls.tryToggleMaximize();
            }
        }

        DankActionButton {
            iconName: "close"
            iconSize: 18
            iconColor: Theme.surfaceText
            tooltipText: "Close"
            tooltipSide: "bottom"
            onClicked: Qt.quit()
        }
    }
}
