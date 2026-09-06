import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

// Crop overlay drawn over the image viewport.
// Caller must provide imageX/imageY/imageW/imageH — the screen-space rect of the
// displayed image (after zoom/pan), so we can map crop coords to image pixels.
Item {
    id: root

    signal cropped(int x, int y, int w, int h)
    signal saveCopyRequested(int x, int y, int w, int h)
    signal saveAsRequested(int x, int y, int w, int h)
    signal copyRequested(int x, int y, int w, int h)
    signal cancelled()

    property bool promptVisible: false
    property var pendingCrop: null

    onVisibleChanged: {
        if (!visible) {
            promptVisible = false;
            pendingCrop = null;
        }
    }

    property real imageX: 0
    property real imageY: 0
    property real imageW: 1
    property real imageH: 1
    property int  srcW: 1
    property int  srcH: 1

    // Aspect ratio lock: "" = freeform
    property string aspectRatio: ""

    // Crop rect in screen space, clamped to image bounds
    property real cropX: imageX + imageW * 0.1
    property real cropY: imageY + imageH * 0.1
    property real cropW: imageW * 0.8
    property real cropH: imageH * 0.8

    readonly property int handleSize: 14

    // Reset crop rect whenever the image position/size changes
    onImageXChanged: _reset()
    onImageYChanged: _reset()
    onImageWChanged: _reset()
    onImageHChanged: _reset()

    function _reset() {
        cropX = imageX + imageW * 0.1;
        cropY = imageY + imageH * 0.1;
        cropW = imageW * 0.8;
        cropH = imageH * 0.8;
    }

    function _clamp() {
        // Clamp size when resizing: keep within image bounds, preserve min size
        if (cropX < imageX) { cropW -= (imageX - cropX); cropX = imageX; }
        if (cropY < imageY) { cropH -= (imageY - cropY); cropY = imageY; }
        if (cropX + cropW > imageX + imageW) cropW = imageX + imageW - cropX;
        if (cropY + cropH > imageY + imageH) cropH = imageY + imageH - cropY;
        cropW = Math.max(20, cropW);
        cropH = Math.max(20, cropH);
    }

    // Clamp position only (used when moving): preserves rect size
    function _clampMove() {
        cropX = Math.max(imageX, Math.min(cropX, imageX + imageW - cropW));
        cropY = Math.max(imageY, Math.min(cropY, imageY + imageH - cropH));
    }

    function _applyAspect() {
        if (aspectRatio === "") return;
        const parts = aspectRatio.split(":");
        const ar = parseFloat(parts[0]) / parseFloat(parts[1]);
        if (!ar || ar <= 0) return;

        const centerX = cropX + cropW / 2;
        const centerY = cropY + cropH / 2;

        let w = cropW;
        let h = w / ar;
        if (h > imageH) {
            h = imageH;
            w = h * ar;
        }
        if (w > imageW) {
            w = imageW;
            h = w / ar;
        }

        cropW = Math.max(20, w);
        cropH = Math.max(20, h);
        cropX = centerX - cropW / 2;
        cropY = centerY - cropH / 2;
        _clampMove();
    }

    function resizeFromCorner(corner, mouseX, mouseY, origX, origY, origW, origH, offX, offY) {
        let anchorX = 0;
        let anchorY = 0;
        let sx = 1;
        let sy = 1;

        if (corner === "nw") {
            anchorX = origX + origW;
            anchorY = origY + origH;
            sx = -1;
            sy = -1;
        } else if (corner === "ne") {
            anchorX = origX;
            anchorY = origY + origH;
            sx = 1;
            sy = -1;
        } else if (corner === "sw") {
            anchorX = origX + origW;
            anchorY = origY;
            sx = -1;
            sy = 1;
        } else if (corner === "se") {
            anchorX = origX;
            anchorY = origY;
            sx = 1;
            sy = 1;
        }

        let targetX = mouseX - offX;
        let targetY = mouseY - offY;

        targetX = Math.max(imageX, Math.min(targetX, imageX + imageW));
        targetY = Math.max(imageY, Math.min(targetY, imageY + imageH));

        let rawW = sx * (targetX - anchorX);
        let rawH = sy * (targetY - anchorY);

        const minSize = 20;

        const maxW = sx < 0 ? (anchorX - imageX) : (imageX + imageW - anchorX);
        const maxH = sy < 0 ? (anchorY - imageY) : (imageY + imageH - anchorY);

        let w = Math.max(minSize, Math.min(rawW, maxW));
        let h = Math.max(minSize, Math.min(rawH, maxH));

        if (aspectRatio !== "") {
            const parts = aspectRatio.split(":");
            const ar = parseFloat(parts[0]) / parseFloat(parts[1]);
            if (ar > 0) {
                if (w / h > ar) {
                    h = w / ar;
                } else {
                    w = h * ar;
                }

                if (w > maxW) {
                    w = maxW;
                    h = w / ar;
                }
                if (h > maxH) {
                    h = maxH;
                    w = h * ar;
                }

                w = Math.max(minSize, w);
                h = Math.max(minSize / ar, h);
            }
        }

        cropX = sx < 0 ? (anchorX - w) : anchorX;
        cropY = sy < 0 ? (anchorY - h) : anchorY;
        cropW = w;
        cropH = h;
    }

    function applyCrop() {
        const scaleX = srcW / imageW;
        const scaleY = srcH / imageH;
        const px = Math.round((cropX - imageX) * scaleX);
        const py = Math.round((cropY - imageY) * scaleY);
        const pw = Math.round(cropW * scaleX);
        const ph = Math.round(cropH * scaleY);
        pendingCrop = {
            x: Math.max(0, px),
            y: Math.max(0, py),
            w: Math.min(pw, srcW - px),
            h: Math.min(ph, srcH - py)
        };
        promptVisible = true;
    }

    // Dark scrim outside the crop rect (4 rectangles)
    Rectangle { // top
        x: 0; y: 0; width: parent.width; height: cropY
        color: Qt.rgba(0, 0, 0, 0.55)
    }
    Rectangle { // bottom
        x: 0; y: cropY + cropH; width: parent.width
        height: parent.height - (cropY + cropH)
        color: Qt.rgba(0, 0, 0, 0.55)
    }
    Rectangle { // left
        x: 0; y: cropY; width: cropX; height: cropH
        color: Qt.rgba(0, 0, 0, 0.55)
    }
    Rectangle { // right
        x: cropX + cropW; y: cropY
        width: parent.width - (cropX + cropW); height: cropH
        color: Qt.rgba(0, 0, 0, 0.55)
    }

    // Crop rect border
    Rectangle {
        x: cropX; y: cropY; width: cropW; height: cropH
        color: "transparent"
        border.color: "white"
        border.width: 1.5

        // Rule-of-thirds grid lines
        Repeater {
            model: 2
            delegate: Rectangle {
                x: parent.width * (index + 1) / 3; y: 0
                width: 1; height: parent.height
                color: Qt.rgba(1, 1, 1, 0.35)
            }
        }
        Repeater {
            model: 2
            delegate: Rectangle {
                x: 0; y: parent.height * (index + 1) / 3
                width: parent.width; height: 1
                color: Qt.rgba(1, 1, 1, 0.35)
            }
        }
    }

    // Move crop rect by dragging its center
    MouseArea {
        x: cropX + handleSize; y: cropY + handleSize
        width: cropW - handleSize * 2; height: cropH - handleSize * 2
        cursorShape: Qt.SizeAllCursor
        property real startX: 0; property real startY: 0
        property real origCropX: 0; property real origCropY: 0
        onPressed: mouse => {
            const p = mapToItem(root, mouse.x, mouse.y);
            startX = p.x; startY = p.y;
            origCropX = cropX; origCropY = cropY;
        }
        onPositionChanged: mouse => {
            const p = mapToItem(root, mouse.x, mouse.y);
            cropX = origCropX + (p.x - startX);
            cropY = origCropY + (p.y - startY);
            root._clampMove();
        }
    }

    // Corner handles — NW, NE, SW, SE
    component Handle: Rectangle {
        width: handleSize * 2; height: handleSize * 2
        color: "transparent"

        Rectangle {
            anchors.centerIn: parent
            width: handleSize; height: handleSize
            radius: 3
            color: "white"
            border.color: Qt.rgba(0, 0, 0, 0.4)
            border.width: 1
        }
    }

    // NW
    Handle {
        x: cropX - handleSize; y: cropY - handleSize
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.SizeFDiagCursor
            property real offX: 0; property real offY: 0
            property real origX: 0; property real origY: 0
            property real origW: 0; property real origH: 0
            onPressed: mouse => {
                const p = mapToItem(root, mouse.x, mouse.y);
                origX = cropX; origY = cropY; origW = cropW; origH = cropH;
                offX = p.x - origX;
                offY = p.y - origY;
            }
            onPositionChanged: mouse => {
                const p = mapToItem(root, mouse.x, mouse.y);
                root.resizeFromCorner("nw", p.x, p.y, origX, origY, origW, origH, offX, offY);
            }
        }
    }

    // NE
    Handle {
        x: cropX + cropW - handleSize; y: cropY - handleSize
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.SizeBDiagCursor
            property real offX: 0; property real offY: 0
            property real origX: 0; property real origY: 0
            property real origW: 0; property real origH: 0
            onPressed: mouse => {
                const p = mapToItem(root, mouse.x, mouse.y);
                origX = cropX; origY = cropY; origW = cropW; origH = cropH;
                offX = p.x - (origX + origW);
                offY = p.y - origY;
            }
            onPositionChanged: mouse => {
                const p = mapToItem(root, mouse.x, mouse.y);
                root.resizeFromCorner("ne", p.x, p.y, origX, origY, origW, origH, offX, offY);
            }
        }
    }

    // SW
    Handle {
        x: cropX - handleSize; y: cropY + cropH - handleSize
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.SizeBDiagCursor
            property real offX: 0; property real offY: 0
            property real origX: 0; property real origY: 0
            property real origW: 0; property real origH: 0
            onPressed: mouse => {
                const p = mapToItem(root, mouse.x, mouse.y);
                origX = cropX; origY = cropY; origW = cropW; origH = cropH;
                offX = p.x - origX;
                offY = p.y - (origY + origH);
            }
            onPositionChanged: mouse => {
                const p = mapToItem(root, mouse.x, mouse.y);
                root.resizeFromCorner("sw", p.x, p.y, origX, origY, origW, origH, offX, offY);
            }
        }
    }

    // SE
    Handle {
        x: cropX + cropW - handleSize; y: cropY + cropH - handleSize
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.SizeFDiagCursor
            property real offX: 0; property real offY: 0
            property real origX: 0; property real origY: 0
            property real origW: 0; property real origH: 0
            onPressed: mouse => {
                const p = mapToItem(root, mouse.x, mouse.y);
                origX = cropX; origY = cropY; origW = cropW; origH = cropH;
                offX = p.x - (origX + origW);
                offY = p.y - (origY + origH);
            }
            onPositionChanged: mouse => {
                const p = mapToItem(root, mouse.x, mouse.y);
                root.resizeFromCorner("se", p.x, p.y, origX, origY, origW, origH, offX, offY);
            }
        }
    }

    // Bottom toolbar: aspect ratio pills + Apply/Cancel
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 28
        height: 48
        radius: 24
        color: Qt.rgba(Theme.surfaceContainerHigh.r, Theme.surfaceContainerHigh.g, Theme.surfaceContainerHigh.b, 0.95)
        border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.35)
        border.width: 1
        implicitWidth: toolRow.implicitWidth + 24

        RowLayout {
            id: toolRow
            anchors.centerIn: parent
            spacing: 6

            // Aspect ratio presets
            Repeater {
                model: [
                    { label: "Free",  ar: "" },
                    { label: "1:1",   ar: "1:1" },
                    { label: "4:3",   ar: "4:3" },
                    { label: "16:9",  ar: "16:9" },
                    { label: "3:2",   ar: "3:2" }
                ]
                delegate: Rectangle {
                    implicitWidth: arLabel.implicitWidth + 16
                    implicitHeight: 32
                    radius: 16
                    color: root.aspectRatio === modelData.ar
                        ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.25)
                        : (arMouse.containsMouse ? Theme.surfaceContainerHighest : "transparent")
                    border.color: root.aspectRatio === modelData.ar
                        ? Theme.primary
                        : Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.4)
                    border.width: 1

                    Text {
                        id: arLabel
                        anchors.centerIn: parent
                        text: modelData.label
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.Medium
                        color: root.aspectRatio === modelData.ar ? Theme.primary : Theme.surfaceText
                    }

                    MouseArea {
                        id: arMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.aspectRatio = modelData.ar;
                            root._applyAspect();
                        }
                    }
                }
            }

            // Separator
            Rectangle {
                width: 1; height: 22
                color: Theme.outlineVariant
                opacity: 0.4
            }

            // Cancel
            DankActionButton {
                iconName: "close"
                iconSize: 18
                buttonSize: 36
                iconColor: Theme.surfaceText
                tooltipText: "Cancel (Esc)"
                tooltipSide: "top"
                onClicked: root.cancelled()
            }

            // Apply / Crop
            Rectangle {
                implicitWidth: applyRow.implicitWidth + 20
                implicitHeight: 36
                radius: 18
                color: applyMouse.containsMouse
                    ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.85)
                    : Theme.primary

                RowLayout {
                    id: applyRow
                    anchors.centerIn: parent
                    spacing: 6

                    DankIcon {
                        name: "crop"
                        size: 16
                        color: Theme.primaryText
                    }

                    Text {
                        text: "Crop"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.DemiBold
                        color: Theme.primaryText
                    }
                }

                MouseArea {
                    id: applyMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.applyCrop()
                }
            }
        }
    }

    // Modal dialog prompting user: 1. Overwrite, 2. Save Copy (_crop), 3. Save to Another Location
    Rectangle {
        id: promptModal
        visible: root.promptVisible
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6)
        z: 100

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onClicked: root.promptVisible = false
        }

        Rectangle {
            anchors.centerIn: parent
            width: 440
            radius: 16
            color: Theme.surfaceContainerHigh
            border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.25)
            border.width: 1
            implicitHeight: promptCol.implicitHeight + 36

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                onClicked: {}
            }

            ColumnLayout {
                id: promptCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 20
                spacing: 12

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    DankIcon {
                        name: "crop"
                        size: 22
                        color: Theme.primary
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Save Cropped Image"
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
                        onClicked: root.promptVisible = false
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: "Choose how you want to save the cropped result:"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                }

                // Option 1: Overwrite original
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: opt1Row.implicitHeight + 20
                    radius: 12
                    color: opt1Mouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerLow
                    border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.25)
                    border.width: 1

                    RowLayout {
                        id: opt1Row
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Rectangle {
                            width: 36; height: 36; radius: 8
                            color: Theme.surfaceContainerHigh
                            DankIcon { anchors.centerIn: parent; name: "save"; size: 20; color: Theme.surfaceText }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                text: "Overwrite Original"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeMedium
                                font.weight: Font.DemiBold
                                color: Theme.surfaceText
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Replace the original image file directly with the cropped image."
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                            }
                        }

                        DankIcon { name: "chevron_right"; size: 18; color: Theme.surfaceVariantText; opacity: opt1Mouse.containsMouse ? 1.0 : 0.4 }
                    }

                    MouseArea {
                        id: opt1Mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.promptVisible = false;
                            if (root.pendingCrop) {
                                root.cropped(root.pendingCrop.x, root.pendingCrop.y, root.pendingCrop.w, root.pendingCrop.h);
                            }
                        }
                    }
                }

                // Option 2: Save copy in same folder (_crop) - Recommended
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: opt2Row.implicitHeight + 20
                    radius: 12
                    color: opt2Mouse.containsMouse ? Theme.surfaceContainerHighest : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)
                    border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.45)
                    border.width: 1

                    RowLayout {
                        id: opt2Row
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Rectangle {
                            width: 36; height: 36; radius: 8
                            color: Theme.primary
                            DankIcon { anchors.centerIn: parent; name: "copy_all"; size: 20; color: Theme.primaryText }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            RowLayout {
                                spacing: 8
                                Text {
                                    text: "Save Copy in Current Folder"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.DemiBold
                                    color: Theme.surfaceText
                                }
                                Rectangle {
                                    implicitHeight: 18; implicitWidth: badgeText.implicitWidth + 8; radius: 4
                                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.25)
                                    Text {
                                        id: badgeText
                                        anchors.centerIn: parent
                                        text: "Recommended"
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeSmall - 2
                                        font.weight: Font.DemiBold
                                        color: Theme.primary
                                    }
                                }
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Keep original and save as '" + (ImageService.currentFileName ? ImageService.currentFileName.replace(/\.[^.]+$/, "_crop") : "image_crop") + "' in the same folder."
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                            }
                        }

                        DankIcon { name: "chevron_right"; size: 18; color: Theme.primary; opacity: opt2Mouse.containsMouse ? 1.0 : 0.7 }
                    }

                    MouseArea {
                        id: opt2Mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.promptVisible = false;
                            if (root.pendingCrop) {
                                root.saveCopyRequested(root.pendingCrop.x, root.pendingCrop.y, root.pendingCrop.w, root.pendingCrop.h);
                            }
                        }
                    }
                }

                // Option: Copy to Clipboard
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: optCopyRow.implicitHeight + 20
                    radius: 12
                    color: optCopyMouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerLow
                    border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.25)
                    border.width: 1

                    RowLayout {
                        id: optCopyRow
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Rectangle {
                            width: 36; height: 36; radius: 8
                            color: Theme.surfaceContainerHigh
                            DankIcon { anchors.centerIn: parent; name: "content_copy"; size: 20; color: Theme.surfaceText }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                text: "Copy to Clipboard"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeMedium
                                font.weight: Font.DemiBold
                                color: Theme.surfaceText
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Copy cropped image directly to clipboard without saving to disk."
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                            }
                        }

                        DankIcon { name: "chevron_right"; size: 18; color: Theme.surfaceVariantText; opacity: optCopyMouse.containsMouse ? 1.0 : 0.4 }
                    }

                    MouseArea {
                        id: optCopyMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.promptVisible = false;
                            if (root.pendingCrop) {
                                root.copyRequested(root.pendingCrop.x, root.pendingCrop.y, root.pendingCrop.w, root.pendingCrop.h);
                            }
                        }
                    }
                }

                // Option 3: Save to another location...
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: opt3Row.implicitHeight + 20
                    radius: 12
                    color: opt3Mouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerLow
                    border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.25)
                    border.width: 1

                    RowLayout {
                        id: opt3Row
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Rectangle {
                            width: 36; height: 36; radius: 8
                            color: Theme.surfaceContainerHigh
                            DankIcon { anchors.centerIn: parent; name: "folder_open"; size: 20; color: Theme.surfaceText }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                text: "Save As / Export Elsewhere..."
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeMedium
                                font.weight: Font.DemiBold
                                color: Theme.surfaceText
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Choose a custom destination folder, file name, format, and quality."
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                            }
                        }

                        DankIcon { name: "chevron_right"; size: 18; color: Theme.surfaceVariantText; opacity: opt3Mouse.containsMouse ? 1.0 : 0.4 }
                    }

                    MouseArea {
                        id: opt3Mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.promptVisible = false;
                            if (root.pendingCrop) {
                                root.saveAsRequested(root.pendingCrop.x, root.pendingCrop.y, root.pendingCrop.w, root.pendingCrop.h);
                            }
                        }
                    }
                }

                // Cancel Button at bottom
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        implicitWidth: cancelBtnText.implicitWidth + 28
                        implicitHeight: 36
                        radius: 18
                        color: cancelBtnMouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerLow
                        border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.35)
                        border.width: 1

                        Text {
                            id: cancelBtnText
                            anchors.centerIn: parent
                            text: "Cancel"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                        MouseArea {
                            id: cancelBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.promptVisible = false
                        }
                    }
                }
            }
        }
    }
}
