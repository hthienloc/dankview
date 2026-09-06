import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services

Rectangle {
    id: root

    width: 320
    color: Theme.surfaceContainer ? Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.95) : "#f01c1c1c"
    border.color: Theme.outlineVariant ? Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.25) : "#33ffffff"
    border.width: 1

    component InfoRow: RowLayout {
        property string label: ""
        property string value: ""
        visible: value !== ""

        Layout.fillWidth: true
        spacing: 8

        Text {
            Layout.preferredWidth: 100
            text: label
            font.pixelSize: 12
            color: Theme.onSurfaceVariant || "#aaaaaa"
        }

        Text {
            Layout.fillWidth: true
            text: value
            font.pixelSize: 12
            font.weight: Font.Medium
            color: Theme.onSurface || "#ffffff"
            wrapMode: Text.WrapAnywhere
            elide: Text.ElideRight
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // Header
        RowLayout {
            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true
                text: "Image Properties"
                font.pixelSize: 15
                font.weight: Font.DemiBold
                color: Theme.onSurface || "#ffffff"
            }

            Rectangle {
                width: 28
                height: 28
                radius: 14
                color: closeMouse.containsMouse ? (Theme.surfaceContainerHighest || "#444444") : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    font.pixelSize: 13
                    color: Theme.onSurface || "#ffffff"
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ImageService.inspectorOpen = false
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.outlineVariant || "#33ffffff"
            opacity: 0.3
        }

        // General Details
        Text {
            text: "Details"
            font.pixelSize: 12
            font.weight: Font.Bold
            color: Theme.primary || "#3b82f6"
        }

        InfoRow {
            label: "File Name"
            value: ImageService.currentMeta.fileName || ImageService.currentFileName
        }

        InfoRow {
            label: "Format"
            value: ImageService.currentMeta.format || ""
        }

        InfoRow {
            label: "File Size"
            value: ImageService.currentMeta.fileSizeText || ""
        }

        InfoRow {
            label: "Dimensions"
            value: ImageService.currentMeta.width > 0 ? (ImageService.currentMeta.width + " × " + ImageService.currentMeta.height + " px") : ""
        }

        InfoRow {
            label: "Aspect Ratio"
            value: ImageService.currentMeta.aspectRatio || ""
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.outlineVariant || "#33ffffff"
            opacity: 0.3
        }

        // Camera Details (if EXIF exists)
        Text {
            visible: ImageService.currentMeta.cameraModel !== undefined && ImageService.currentMeta.cameraModel !== ""
            text: "Camera & Exposure"
            font.pixelSize: 12
            font.weight: Font.Bold
            color: Theme.primary || "#3b82f6"
        }

        InfoRow {
            label: "Camera"
            value: (ImageService.currentMeta.cameraMake || "") + " " + (ImageService.currentMeta.cameraModel || "")
        }

        InfoRow {
            label: "Aperture"
            value: ImageService.currentMeta.fNumber || ""
        }

        InfoRow {
            label: "Exposure"
            value: ImageService.currentMeta.exposureTime || ""
        }

        InfoRow {
            label: "ISO"
            value: ImageService.currentMeta.iso || ""
        }

        InfoRow {
            label: "Focal Length"
            value: ImageService.currentMeta.focalLength || ""
        }

        InfoRow {
            label: "Date Taken"
            value: ImageService.currentMeta.dateTaken || ""
        }

        Item {
            Layout.fillHeight: true
        }

        // File path footer
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                text: "Location"
                font.pixelSize: 11
                color: Theme.onSurfaceVariant || "#888888"
            }

            Text {
                Layout.fillWidth: true
                text: ImageService.currentFilePath
                font.pixelSize: 11
                color: Theme.onSurface || "#dddddd"
                wrapMode: Text.WrapAnywhere
            }
        }
    }
}
