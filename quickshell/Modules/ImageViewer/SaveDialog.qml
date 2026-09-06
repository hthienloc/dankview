import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

// Modal "Save As / Export" sheet.
// Emits saved(destPath) on success, cancelled() on dismiss.
Rectangle {
    id: root

    signal saved(string destPath)
    signal cancelled()

    // Input path to convert from (may be a cropped temp file)
    property string sourcePath: ImageService.currentFilePath

    color: Qt.rgba(0, 0, 0, 0.55)

    // Block input to canvas behind
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onClicked: root.cancelled()
    }

    // Sheet card
    Rectangle {
        anchors.centerIn: parent
        width: 360
        radius: 16
        color: Theme.surfaceContainerHigh
        border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.25)
        border.width: 1
        implicitHeight: sheetCol.implicitHeight + 32

        // Swallow clicks so they don't close the dialog
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onClicked: {}
        }

        ColumnLayout {
            id: sheetCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 16
            spacing: 14

            // Header
            RowLayout {
                Layout.fillWidth: true

                DankIcon { name: "save"; size: 20; color: Theme.primary }

                Text {
                    Layout.fillWidth: true
                    leftPadding: 8
                    text: "Save As / Export"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.DemiBold
                    color: Theme.surfaceText
                }

                DankActionButton {
                    iconName: "close"; iconSize: 18; buttonSize: 32
                    iconColor: Theme.surfaceText
                    onClicked: root.cancelled()
                }
            }

            // Format selector
            Text {
                text: "Format"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: ["PNG", "JPEG", "WebP"]
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 36
                        radius: 8
                        color: formatSelector.currentFormat === modelData
                            ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.22)
                            : (fmtMouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerLow)
                        border.color: formatSelector.currentFormat === modelData
                            ? Theme.primary
                            : Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.35)
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Medium
                            color: formatSelector.currentFormat === modelData ? Theme.primary : Theme.surfaceText
                        }

                        MouseArea {
                            id: fmtMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: formatSelector.currentFormat = modelData
                        }
                    }
                }

                // Invisible singleton to hold selection state
                Item { id: formatSelector; property string currentFormat: "PNG" }
            }

            // Quality slider (lossy only)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                visible: formatSelector.currentFormat !== "PNG"

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Quality"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: qualitySlider.value + "%"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                    }
                }

                Slider {
                    id: qualitySlider
                    Layout.fillWidth: true
                    from: 10; to: 100; stepSize: 1; value: 90
                }
            }

            // Metadata strip toggle
            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: "Strip metadata"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceText
                }

                Rectangle {
                    id: stripToggle
                    property bool checked: false
                    width: 40; height: 24; radius: 12
                    color: checked ? Theme.primary : Theme.surfaceContainerHighest
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Rectangle {
                        width: 18; height: 18; radius: 9
                        anchors.verticalCenter: parent.verticalCenter
                        x: stripToggle.checked ? parent.width - width - 3 : 3
                        color: "white"
                        Behavior on x { NumberAnimation { duration: 120 } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: stripToggle.checked = !stripToggle.checked
                    }
                }
            }

            // Action buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Item { Layout.fillWidth: true }

                // Cancel
                Rectangle {
                    implicitWidth: 80; implicitHeight: 36; radius: 18
                    color: cancelMouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerLow
                    border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.4)
                    border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                    }
                    MouseArea {
                        id: cancelMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.cancelled()
                    }
                }

                // Save
                Rectangle {
                    implicitWidth: 90; implicitHeight: 36; radius: 18
                    color: saveMouse.containsMouse
                        ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.85)
                        : Theme.primary
                    Text {
                        anchors.centerIn: parent
                        text: "Save"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.DemiBold
                        color: Theme.primaryText
                    }
                    MouseArea {
                        id: saveMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root._doSave()
                    }
                }
            }

            // Spacer at bottom
            Item { implicitHeight: 4 }
        }
    }

    function _extFor(fmt) {
        if (fmt === "JPEG") return "jpg";
        if (fmt === "WebP") return "webp";
        return "png";
    }

    function _doSave() {
        const src = root.sourcePath;
        if (!src) return;

        const fmt = formatSelector.currentFormat;
        const ext = _extFor(fmt);
        const quality = fmt === "PNG" ? "" : String(Math.round(qualitySlider.value));

        // Build dest path: same dir as source, append _export suffix, change ext
        const base = src.substring(0, src.lastIndexOf(".")) || src;
        const dest = base + "_export." + ext;

        root.saved(dest);

        let cmd;
        if (stripToggle.checked) {
            cmd = quality !== ""
                ? ["magick", src, "-quality", quality, "-strip", dest]
                : ["magick", src, "-strip", dest];
        } else {
            cmd = quality !== ""
                ? ["magick", src, "-quality", quality, dest]
                : ["magick", src, dest];
        }
        saveProc.command = cmd;
        saveProc.running = true;
    }

    Process {
        id: saveProc
        running: false
        command: []
        onExited: exitCode => {
            if (exitCode === 0) {
                ImageService.showToast("Saved to " + ImageService.currentFileName.replace(/\.[^.]+$/, "_export") + "…");
            } else {
                ImageService.showToast("Export failed", true);
            }
        }
    }
}
