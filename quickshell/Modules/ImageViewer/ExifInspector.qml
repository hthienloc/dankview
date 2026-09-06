import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

Rectangle {
    id: root

    width: 360
    color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.96)
    border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.3)
    border.width: 1

    component SectionHeader: RowLayout {
        property string title: ""
        property string iconName: ""

        Layout.fillWidth: true
        spacing: 8

        DankIcon {
            name: iconName
            size: 18
            color: Theme.primary
        }

        Text {
            Layout.fillWidth: true
            text: title
            font.family: Theme.fontFamily || "Google Sans Flex"
            font.pixelSize: 13
            font.weight: Font.DemiBold
            color: Theme.primary
        }
    }

    component InfoRow: RowLayout {
        property string label: ""
        property string value: ""
        visible: value !== ""

        Layout.fillWidth: true
        spacing: 12

        Text {
            Layout.preferredWidth: 105
            text: label
            font.family: Theme.fontFamily || "Google Sans Flex"
            font.pixelSize: 13
            color: Theme.surfaceVariantText
        }

        Text {
            Layout.fillWidth: true
            text: value
            font.family: Theme.fontFamily || "Google Sans Flex"
            font.pixelSize: 13
            font.weight: Font.Medium
            color: Theme.surfaceText
            wrapMode: Text.WrapAnywhere
            elide: Text.ElideRight
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 14

        // Top Drawer Header
        RowLayout {
            Layout.fillWidth: true

            DankIcon {
                name: "info"
                size: 22
                color: Theme.primary
            }

            Text {
                Layout.fillWidth: true
                text: "Image Properties"
                font.family: Theme.fontFamily || "Google Sans Flex"
                font.pixelSize: 16
                font.weight: Font.DemiBold
                color: Theme.surfaceText
            }

            DankActionButton {
                iconName: "close"
                iconSize: 20
                iconColor: Theme.surfaceText
                tooltipText: "Close Inspector (I)"
                tooltipSide: "left"
                onClicked: ImageService.inspectorOpen = false
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.outlineVariant
            opacity: 0.35
        }

        // Section: File Details
        SectionHeader {
            title: "File Details"
            iconName: "image"
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: fileCol.implicitHeight + 18
            radius: 12
            color: Theme.surfaceContainerHigh

            ColumnLayout {
                id: fileCol
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                InfoRow {
                    label: "Name"
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
                    label: "Resolution"
                    value: ImageService.currentMeta.width > 0 ? (ImageService.currentMeta.width + " × " + ImageService.currentMeta.height + " px") : ""
                }
                InfoRow {
                    label: "Aspect Ratio"
                    value: ImageService.currentMeta.aspectRatio || ""
                }
            }
        }

        // Section: Camera & EXIF (if available)
        SectionHeader {
            visible: ImageService.currentMeta.cameraModel !== undefined && ImageService.currentMeta.cameraModel !== ""
            title: "Camera & Optics"
            iconName: "photo_camera"
        }

        Rectangle {
            visible: ImageService.currentMeta.cameraModel !== undefined && ImageService.currentMeta.cameraModel !== ""
            Layout.fillWidth: true
            implicitHeight: exifCol.implicitHeight + 18
            radius: 12
            color: Theme.surfaceContainerHigh

            ColumnLayout {
                id: exifCol
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

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
            }
        }

        Item {
            Layout.fillHeight: true
        }

        // Location path card
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: pathCol.implicitHeight + 18
            radius: 12
            color: Theme.surfaceContainerLowest

            ColumnLayout {
                id: pathCol
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6

                RowLayout {
                    spacing: 6
                    DankIcon {
                        name: "folder"
                        size: 16
                        color: Theme.surfaceVariantText
                    }
                    Text {
                        text: "File Path"
                        font.family: Theme.fontFamily || "Google Sans Flex"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: Theme.surfaceVariantText
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: ImageService.currentFilePath
                    font.family: Theme.fontFamily || "Google Sans Flex"
                    font.pixelSize: 12
                    color: Theme.surfaceText
                    wrapMode: Text.WrapAnywhere
                }
            }
        }
    }
}
