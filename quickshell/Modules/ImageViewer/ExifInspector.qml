import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

Rectangle {
    id: root

    width: 380
    color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.96)
    border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.25)
    border.width: 1

    component M3Card: Rectangle {
        Layout.fillWidth: true
        radius: 12
        color: Theme.surfaceContainerHigh
        border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.18)
        border.width: 1
    }

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
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeMedium
            font.weight: Font.DemiBold
            color: Theme.primary
        }
    }

    component DetailRow: RowLayout {
        property string label: ""
        property string value: ""
        property bool isMono: false
        visible: value !== ""

        Layout.fillWidth: true
        spacing: 12

        Text {
            Layout.preferredWidth: 105
            text: label
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceVariantText
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true
            text: value
            font.family: isMono ? Theme.monoFontFamily : Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
            color: Theme.surfaceText
            wrapMode: Text.WrapAnywhere
            elide: Text.ElideRight
        }
    }

    component ActionChip: Rectangle {
        id: chip
        property string iconName: ""
        property string label: ""
        signal clicked()

        implicitHeight: 32
        implicitWidth: chipRow.implicitWidth + 20
        radius: 8
        color: chipMouse.containsMouse ? Theme.surfaceContainerHighest : (Theme.surfaceContainerLow || Theme.surfaceContainerHigh)
        border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.3)
        border.width: 1

        RowLayout {
            id: chipRow
            anchors.centerIn: parent
            spacing: 6

            DankIcon {
                name: chip.iconName
                size: 16
                color: Theme.primary
            }

            Text {
                text: chip.label
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
                color: Theme.surfaceText
            }
        }

        MouseArea {
            id: chipMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: chip.clicked()
        }
    }

    component PillBadge: Rectangle {
        property alias text: badgeText.text
        property color textColor: Theme.surfaceText
        property color bgColor: Theme.surfaceContainerHighest
        property color borderColor: "transparent"

        implicitHeight: 24
        implicitWidth: badgeText.implicitWidth + 14
        radius: 12
        color: bgColor
        border.color: borderColor
        border.width: borderColor !== "transparent" ? 1 : 0

        Text {
            id: badgeText
            anchors.centerIn: parent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall - 1
            font.weight: Font.DemiBold
            color: textColor
        }
    }

    // Prevent mouse clicks and drags from falling through to the canvas underneath
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        hoverEnabled: true
        preventStealing: true
        onPressed: mouse => mouse.accepted = true
        onReleased: mouse => mouse.accepted = true
        onClicked: mouse => mouse.accepted = true
        onDoubleClicked: mouse => mouse.accepted = true
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 14
            spacing: 10

            DankIcon {
                name: "info"
                size: 22
                color: Theme.primary
            }

            Text {
                Layout.fillWidth: true
                text: "Details"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Font.DemiBold
                color: Theme.surfaceText
            }

            DankActionButton {
                iconName: "close"
                iconSize: 18
                buttonSize: 32
                iconColor: Theme.surfaceText
                tooltipText: "Close (I)"
                tooltipSide: "left"
                onClicked: ImageService.inspectorOpen = false
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.outlineVariant
            opacity: 0.25
        }

        DankFlickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: contentCol.implicitHeight + 28
            clip: true

            ColumnLayout {
                id: contentCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                spacing: 14

                // Hero File Card
                M3Card {
                    implicitHeight: heroCol.implicitHeight + 24

                    ColumnLayout {
                        id: heroCol
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Rectangle {
                                width: 40
                                height: 40
                                radius: 10
                                color: Theme.primaryContainer

                                DankIcon {
                                    anchors.centerIn: parent
                                    name: "image"
                                    size: 22
                                    color: Theme.primaryText
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    Layout.fillWidth: true
                                    text: ImageService.currentFileName || "Image"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.DemiBold
                                    color: Theme.surfaceText
                                    elide: Text.ElideMiddle
                                    wrapMode: Text.WrapAnywhere
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: ImageService.currentMeta.fileSizeText || ""
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                }
                            }
                        }

                        // Badges Row
                        Flow {
                            Layout.fillWidth: true
                            spacing: 6

                            PillBadge {
                                visible: ImageService.currentMeta.format !== undefined && ImageService.currentMeta.format !== ""
                                text: ImageService.currentMeta.format || ""
                                bgColor: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.22)
                                textColor: Theme.primary
                                borderColor: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.6)
                            }

                            PillBadge {
                                visible: ImageService.currentMeta.megapixels !== undefined && ImageService.currentMeta.megapixels !== ""
                                text: ImageService.currentMeta.megapixels || ""
                            }

                            PillBadge {
                                visible: ImageService.currentMeta.width > 0
                                text: ImageService.currentMeta.width + " × " + ImageService.currentMeta.height
                            }

                            PillBadge {
                                visible: ImageService.currentMeta.aspectRatio !== undefined && ImageService.currentMeta.aspectRatio !== ""
                                text: ImageService.currentMeta.aspectRatio || ""
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Theme.outlineVariant
                            opacity: 0.2
                        }

                        // Quick Action Buttons
                        Flow {
                            Layout.fillWidth: true
                            spacing: 8

                            ActionChip {
                                iconName: "content_copy"
                                label: "Copy Image"
                                onClicked: ImageService.copyToClipboard()
                            }

                            ActionChip {
                                iconName: "link"
                                label: "Copy Path"
                                onClicked: ImageService.copyPathToClipboard()
                            }

                            ActionChip {
                                iconName: "folder_open"
                                label: "Open Folder"
                                onClicked: ImageService.openContainingFolder()
                            }
                        }
                    }
                }

                // Section 1: Image Attributes
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    SectionHeader {
                        title: "Attributes"
                        iconName: "photo_size_select_actual"
                    }

                    M3Card {
                        implicitHeight: attrCol.implicitHeight + 24

                        ColumnLayout {
                            id: attrCol
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            DetailRow {
                                label: "Dimensions"
                                value: ImageService.currentMeta.width > 0 ? (ImageService.currentMeta.width + " × " + ImageService.currentMeta.height + " px") : ""
                            }
                            DetailRow {
                                label: "Megapixels"
                                value: ImageService.currentMeta.megapixels || ""
                            }
                            DetailRow {
                                label: "Aspect Ratio"
                                value: ImageService.currentMeta.aspectRatio || ""
                            }
                            DetailRow {
                                label: "File Size"
                                value: {
                                    if (!ImageService.currentMeta.fileSizeText) return "";
                                    const raw = ImageService.currentMeta.fileSize;
                                    if (typeof raw === "number" && raw > 0) {
                                        const formatted = Math.floor(raw).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
                                        return ImageService.currentMeta.fileSizeText + " (" + formatted + " B)";
                                    }
                                    return ImageService.currentMeta.fileSizeText;
                                }
                            }
                            DetailRow {
                                label: "Format"
                                value: ImageService.currentMeta.format || ""
                            }
                            DetailRow {
                                label: "Modified"
                                value: ImageService.currentMeta.modTimeText || ""
                            }
                        }
                    }
                }

                // Section 2: Camera & Optics (EXIF)
                ColumnLayout {
                    visible: (ImageService.currentMeta.cameraModel !== undefined && ImageService.currentMeta.cameraModel !== "") ||
                             (ImageService.currentMeta.fNumber !== undefined && ImageService.currentMeta.fNumber !== "")
                    Layout.fillWidth: true
                    spacing: 8

                    SectionHeader {
                        title: "Camera & Optics"
                        iconName: "photo_camera"
                    }

                    M3Card {
                        implicitHeight: cameraCol.implicitHeight + 24

                        ColumnLayout {
                            id: cameraCol
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Text {
                                Layout.fillWidth: true
                                visible: text !== ""
                                text: (ImageService.currentMeta.cameraMake ? ImageService.currentMeta.cameraMake + " " : "") + (ImageService.currentMeta.cameraModel || "")
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeMedium
                                font.weight: Font.DemiBold
                                color: Theme.surfaceText
                            }

                            // 4-cell Photography Quick Spec Grid (Loupe style)
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                // Aperture
                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: 48
                                    radius: 8
                                    color: Theme.surfaceContainerLow || Theme.surfaceContainerHigh
                                    border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.15)
                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 2
                                        Text {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: "Aperture"
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSizeSmall - 2
                                            color: Theme.surfaceVariantText
                                        }
                                        Text {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: ImageService.currentMeta.fNumber || "—"
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSizeSmall
                                            font.weight: Font.DemiBold
                                            color: Theme.surfaceText
                                        }
                                    }
                                }

                                // Shutter
                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: 48
                                    radius: 8
                                    color: Theme.surfaceContainerLow || Theme.surfaceContainerHigh
                                    border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.15)
                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 2
                                        Text {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: "Shutter"
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSizeSmall - 2
                                            color: Theme.surfaceVariantText
                                        }
                                        Text {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: ImageService.currentMeta.exposureTime || "—"
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSizeSmall
                                            font.weight: Font.DemiBold
                                            color: Theme.surfaceText
                                        }
                                    }
                                }

                                // Focal Length
                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: 48
                                    radius: 8
                                    color: Theme.surfaceContainerLow || Theme.surfaceContainerHigh
                                    border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.15)
                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 2
                                        Text {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: "Focal"
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSizeSmall - 2
                                            color: Theme.surfaceVariantText
                                        }
                                        Text {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: ImageService.currentMeta.focalLength || "—"
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSizeSmall
                                            font.weight: Font.DemiBold
                                            color: Theme.surfaceText
                                        }
                                    }
                                }

                                // ISO
                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: 48
                                    radius: 8
                                    color: Theme.surfaceContainerLow || Theme.surfaceContainerHigh
                                    border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.15)
                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 2
                                        Text {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: "ISO"
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSizeSmall - 2
                                            color: Theme.surfaceVariantText
                                        }
                                        Text {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: ImageService.currentMeta.iso || "—"
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSizeSmall
                                            font.weight: Font.DemiBold
                                            color: Theme.surfaceText
                                        }
                                    }
                                }
                            }

                            DetailRow {
                                label: "Date Taken"
                                value: ImageService.currentMeta.dateTaken || ""
                            }
                        }
                    }
                }

                // Section 3: Location
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    SectionHeader {
                        title: "Location"
                        iconName: "folder"
                    }

                    M3Card {
                        implicitHeight: locCol.implicitHeight + 24

                        ColumnLayout {
                            id: locCol
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            DetailRow {
                                label: "Folder"
                                value: ImageService.currentMeta.directory || ""
                                isMono: true
                            }

                            DetailRow {
                                label: "Full Path"
                                value: ImageService.currentFilePath
                                isMono: true
                            }
                        }
                    }
                }

                // Section 4: GPS Coordinates (if available in EXIF)
                ColumnLayout {
                    visible: ImageService.currentMeta.gpsPosition !== undefined && ImageService.currentMeta.gpsPosition !== ""
                    Layout.fillWidth: true
                    spacing: 8

                    SectionHeader {
                        title: "GPS Location"
                        iconName: "location_on"
                    }

                    M3Card {
                        implicitHeight: gpsCol.implicitHeight + 24

                        ColumnLayout {
                            id: gpsCol
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            DetailRow {
                                label: "Coordinates"
                                value: ImageService.currentMeta.gpsPosition || ""
                                isMono: true
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                ActionChip {
                                    iconName: "map"
                                    label: "Open in Maps"
                                    onClicked: {
                                        if (ImageService.currentMeta.mapsUrl) {
                                            Quickshell.execDetached(["xdg-open", ImageService.currentMeta.mapsUrl]);
                                        }
                                    }
                                }

                                ActionChip {
                                    iconName: "content_copy"
                                    label: "Copy Coordinates"
                                    onClicked: {
                                        if (ImageService.currentMeta.gpsPosition) {
                                            Quickshell.execDetached([
                                                "sh", "-c",
                                                "dms cl copy " + JSON.stringify(ImageService.currentMeta.gpsPosition) + " 2>/dev/null || wl-copy " + JSON.stringify(ImageService.currentMeta.gpsPosition)
                                            ]);
                                            ImageService.showToast("Coordinates copied to clipboard");
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
