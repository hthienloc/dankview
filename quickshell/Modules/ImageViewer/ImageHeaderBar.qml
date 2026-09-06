import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

Rectangle {
    id: root

    property var windowControls: null
    property var targetWindow: null

    height: 52
    color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.90)
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
        anchors.leftMargin: 14
        anchors.rightMargin: 10
        spacing: 10

        // App/File Icon & Name
        DankIcon {
            name: "image"
            size: 22
            color: Theme.primary
        }

        Text {
            Layout.fillWidth: true
            text: ImageService.currentFileName || "DankView"
            font.family: Theme.fontFamily || "Google Sans Flex"
            font.pixelSize: 15
            font.weight: Font.DemiBold
            color: Theme.surfaceText
            elide: Text.ElideMiddle
        }

        // Center: Counter badge e.g. "3 / 12"
        Rectangle {
            visible: ImageService.fileList.length > 0
            height: 28
            width: counterText.implicitWidth + 18
            radius: 14
            color: Theme.surfaceContainerHighest

            Text {
                id: counterText
                anchors.centerIn: parent
                text: (ImageService.currentIndex + 1) + " / " + ImageService.fileList.length
                font.family: Theme.fontFamily || "Google Sans Flex"
                font.pixelSize: 13
                font.weight: Font.Medium
                color: Theme.surfaceVariantText
            }
        }

        // Zoom percentage badge
        Rectangle {
            height: 30
            width: zoomRow.implicitWidth + 16
            radius: 15
            color: zoomMouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh

            RowLayout {
                id: zoomRow
                anchors.centerIn: parent
                spacing: 4

                DankIcon {
                    name: "zoom_in"
                    size: 16
                    color: Theme.surfaceVariantText
                }

                Text {
                    text: Math.round(ImageService.zoom * 100) + "%"
                    font.family: Theme.fontFamily || "Google Sans Flex"
                    font.pixelSize: 13
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
            iconSize: 19
            iconColor: ImageService.inspectorOpen ? Theme.primary : Theme.surfaceText
            backgroundColor: ImageService.inspectorOpen ? Theme.surfaceContainerHighest : "transparent"
            tooltipText: "Image Properties (I)"
            tooltipSide: "bottom"
            onClicked: ImageService.toggleInspector()
        }

        Rectangle {
            width: 1
            height: 20
            color: Theme.outlineVariant
            opacity: 0.4
        }

        // Window Controls (minimize, maximize/fullscreen, close)
        DankActionButton {
            visible: root.windowControls && root.windowControls.canMinimize
            iconName: "minimize"
            iconSize: 18
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
            iconName: (root.targetWindow && root.targetWindow.maximized) ? "fullscreen_exit" : "fullscreen"
            iconSize: 19
            iconColor: Theme.surfaceText
            tooltipText: (root.targetWindow && root.targetWindow.maximized) ? "Restore (F)" : "Maximize (F)"
            tooltipSide: "bottom"
            onClicked: {
                if (root.windowControls)
                    root.windowControls.tryToggleMaximize();
            }
        }

        DankActionButton {
            iconName: "close"
            iconSize: 19
            iconColor: Theme.surfaceText
            tooltipText: "Close (Esc)"
            tooltipSide: "bottom"
            onClicked: Qt.quit()
        }
    }
}
