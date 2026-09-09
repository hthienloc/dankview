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

        DankIcon {
            name: "movie"
            size: 22
            color: Theme.primary
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            Layout.fillWidth: true
            Layout.minimumWidth: 50
            Layout.alignment: Qt.AlignVCenter
            text: VideoService.currentFileName || "DankVideo"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeLarge
            font.weight: Font.DemiBold
            color: Theme.surfaceText
            elide: Text.ElideMiddle
        }

        // Counter badge e.g. "2 / 5"
        Rectangle {
            visible: VideoService.fileList.length > 0
            Layout.preferredHeight: 28
            Layout.preferredWidth: counterText.implicitWidth + 18
            radius: 14
            color: Theme.surfaceContainerHighest

            Text {
                id: counterText
                anchors.centerIn: parent
                text: (VideoService.currentIndex + 1) + " / " + VideoService.fileList.length
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
                color: Theme.surfaceVariantText
            }
        }

        // Resolution & Codec badge if available
        Rectangle {
            visible: VideoService.currentMeta && (VideoService.currentMeta.videoCodec || VideoService.currentMeta.width > 0)
            Layout.preferredHeight: 28
            Layout.preferredWidth: codecRow.implicitWidth + 18
            radius: 14
            color: Theme.surfaceContainerHigh

            RowLayout {
                id: codecRow
                anchors.centerIn: parent
                spacing: 4

                DankIcon {
                    name: "hd"
                    size: 16
                    color: Theme.surfaceVariantText
                    visible: VideoService.currentMeta && VideoService.currentMeta.height >= 720
                }

                Text {
                    id: codecText
                    text: {
                        if (!VideoService.currentMeta) return "";
                        let parts = [];
                        if (VideoService.currentMeta.videoCodec) {
                            parts.push(VideoService.currentMeta.videoCodec.toUpperCase());
                        }
                        if (VideoService.currentMeta.width > 0) {
                            parts.push(VideoService.currentMeta.width + "x" + VideoService.currentMeta.height);
                        }
                        return parts.join(" • ");
                    }
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Medium
                    color: Theme.surfaceVariantText
                }
            }
        }

        // Open Video Action
        DankActionButton {
            iconName: "folder_open"
            iconSize: 19
            iconColor: Theme.surfaceText
            tooltipText: "Open Video (O)"
            tooltipSide: "bottom"
            Layout.alignment: Qt.AlignVCenter
            onClicked: VideoService.openFileDialog()
        }

        // Inspector Toggle
        DankActionButton {
            visible: VideoService.currentFilePath !== ""
            iconName: "info"
            iconSize: 19
            iconColor: VideoService.inspectorOpen ? Theme.primary : Theme.surfaceText
            backgroundColor: VideoService.inspectorOpen ? Theme.surfaceContainerHighest : "transparent"
            tooltipText: "Media Details (I)"
            tooltipSide: "bottom"
            Layout.alignment: Qt.AlignVCenter
            onClicked: VideoService.toggleInspector()
        }

        // Lock UI / Zen View
        DankActionButton {
            visible: VideoService.currentFilePath !== ""
            iconName: "lock_open"
            iconSize: 19
            iconColor: Theme.surfaceText
            tooltipText: "Lock UI / Clean View (K)"
            tooltipSide: "bottom"
            Layout.alignment: Qt.AlignVCenter
            onClicked: VideoService.toggleLockUI()
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: 20
            Layout.alignment: Qt.AlignVCenter
            color: Theme.outlineVariant
            opacity: 0.4
        }

        DankActionButton {
            visible: root.windowControls && root.windowControls.canMinimize
            iconName: "minimize"
            iconSize: 18
            iconColor: Theme.surfaceText
            tooltipText: "Minimize"
            tooltipSide: "bottom"
            Layout.alignment: Qt.AlignVCenter
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
            Layout.alignment: Qt.AlignVCenter
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
            Layout.alignment: Qt.AlignVCenter
            onClicked: Qt.quit()
        }
    }
}
