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

    function resizeFromEdge(edge, mouseX, mouseY, origX, origY, origW, origH, offX, offY) {
        const minSize = 20;

        if (edge === "n") {
            const anchorY = origY + origH;
            let targetY = mouseY - offY;
            targetY = Math.max(imageY, Math.min(targetY, anchorY - minSize));
            let newH = anchorY - targetY;
            let newW = origW;
            let newX = origX;

            if (aspectRatio !== "") {
                const parts = aspectRatio.split(":");
                const ar = parseFloat(parts[0]) / parseFloat(parts[1]);
                if (ar > 0) {
                    newW = newH * ar;
                    if (newW > imageW) {
                        newW = imageW;
                        newH = newW / ar;
                        targetY = anchorY - newH;
                    }
                    const centerX = origX + origW / 2;
                    newX = Math.max(imageX, Math.min(centerX - newW / 2, imageX + imageW - newW));
                }
            }

            cropX = newX;
            cropY = targetY;
            cropW = newW;
            cropH = newH;
        } else if (edge === "s") {
            const anchorY = origY;
            let targetY = mouseY - offY;
            targetY = Math.min(imageY + imageH, Math.max(targetY, anchorY + minSize));
            let newH = targetY - anchorY;
            let newW = origW;
            let newX = origX;

            if (aspectRatio !== "") {
                const parts = aspectRatio.split(":");
                const ar = parseFloat(parts[0]) / parseFloat(parts[1]);
                if (ar > 0) {
                    newW = newH * ar;
                    if (newW > imageW) {
                        newW = imageW;
                        newH = newW / ar;
                    }
                    const centerX = origX + origW / 2;
                    newX = Math.max(imageX, Math.min(centerX - newW / 2, imageX + imageW - newW));
                }
            }

            cropX = newX;
            cropY = origY;
            cropW = newW;
            cropH = newH;
        } else if (edge === "w") {
            const anchorX = origX + origW;
            let targetX = mouseX - offX;
            targetX = Math.max(imageX, Math.min(targetX, anchorX - minSize));
            let newW = anchorX - targetX;
            let newH = origH;
            let newY = origY;

            if (aspectRatio !== "") {
                const parts = aspectRatio.split(":");
                const ar = parseFloat(parts[0]) / parseFloat(parts[1]);
                if (ar > 0) {
                    newH = newW / ar;
                    if (newH > imageH) {
                        newH = imageH;
                        newW = newH * ar;
                        targetX = anchorX - newW;
                    }
                    const centerY = origY + origH / 2;
                    newY = Math.max(imageY, Math.min(centerY - newH / 2, imageY + imageH - newH));
                }
            }

            cropX = targetX;
            cropY = newY;
            cropW = newW;
            cropH = newH;
        } else if (edge === "e") {
            const anchorX = origX;
            let targetX = mouseX - offX;
            targetX = Math.min(imageX + imageW, Math.max(targetX, anchorX + minSize));
            let newW = targetX - anchorX;
            let newH = origH;
            let newY = origY;

            if (aspectRatio !== "") {
                const parts = aspectRatio.split(":");
                const ar = parseFloat(parts[0]) / parseFloat(parts[1]);
                if (ar > 0) {
                    newH = newW / ar;
                    if (newH > imageH) {
                        newH = imageH;
                        newW = newH * ar;
                    }
                    const centerY = origY + origH / 2;
                    newY = Math.max(imageY, Math.min(centerY - newH / 2, imageY + imageH - newH));
                }
            }

            cropX = origX;
            cropY = newY;
            cropW = newW;
            cropH = newH;
        }
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

    // Edge Handles (Top/N, Bottom/S, Left/W, Right/E)
    // Top (N)
    Rectangle {
        x: cropX + cropW / 2 - 20; y: cropY - 6
        width: 40; height: 12
        color: "transparent"
        Rectangle {
            anchors.centerIn: parent
            width: 24; height: 5
            radius: 2.5
            color: "white"
            border.color: Qt.rgba(0, 0, 0, 0.45)
            border.width: 1
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.SizeVerCursor
            property real offY: 0
            property real origX: 0; property real origY: 0
            property real origW: 0; property real origH: 0
            onPressed: mouse => {
                const p = mapToItem(root, mouse.x, mouse.y);
                origX = cropX; origY = cropY; origW = cropW; origH = cropH;
                offY = p.y - origY;
            }
            onPositionChanged: mouse => {
                const p = mapToItem(root, mouse.x, mouse.y);
                root.resizeFromEdge("n", p.x, p.y, origX, origY, origW, origH, 0, offY);
            }
        }
    }

    // Bottom (S)
    Rectangle {
        x: cropX + cropW / 2 - 20; y: cropY + cropH - 6
        width: 40; height: 12
        color: "transparent"
        Rectangle {
            anchors.centerIn: parent
            width: 24; height: 5
            radius: 2.5
            color: "white"
            border.color: Qt.rgba(0, 0, 0, 0.45)
            border.width: 1
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.SizeVerCursor
            property real offY: 0
            property real origX: 0; property real origY: 0
            property real origW: 0; property real origH: 0
            onPressed: mouse => {
                const p = mapToItem(root, mouse.x, mouse.y);
                origX = cropX; origY = cropY; origW = cropW; origH = cropH;
                offY = p.y - (origY + origH);
            }
            onPositionChanged: mouse => {
                const p = mapToItem(root, mouse.x, mouse.y);
                root.resizeFromEdge("s", p.x, p.y, origX, origY, origW, origH, 0, offY);
            }
        }
    }

    // Left (W)
    Rectangle {
        x: cropX - 6; y: cropY + cropH / 2 - 20
        width: 12; height: 40
        color: "transparent"
        Rectangle {
            anchors.centerIn: parent
            width: 5; height: 24
            radius: 2.5
            color: "white"
            border.color: Qt.rgba(0, 0, 0, 0.45)
            border.width: 1
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.SizeHorCursor
            property real offX: 0
            property real origX: 0; property real origY: 0
            property real origW: 0; property real origH: 0
            onPressed: mouse => {
                const p = mapToItem(root, mouse.x, mouse.y);
                origX = cropX; origY = cropY; origW = cropW; origH = cropH;
                offX = p.x - origX;
            }
            onPositionChanged: mouse => {
                const p = mapToItem(root, mouse.x, mouse.y);
                root.resizeFromEdge("w", p.x, p.y, origX, origY, origW, origH, offX, 0);
            }
        }
    }

    // Right (E)
    Rectangle {
        x: cropX + cropW - 6; y: cropY + cropH / 2 - 20
        width: 12; height: 40
        color: "transparent"
        Rectangle {
            anchors.centerIn: parent
            width: 5; height: 24
            radius: 2.5
            color: "white"
            border.color: Qt.rgba(0, 0, 0, 0.45)
            border.width: 1
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.SizeHorCursor
            property real offX: 0
            property real origX: 0; property real origY: 0
            property real origW: 0; property real origH: 0
            onPressed: mouse => {
                const p = mapToItem(root, mouse.x, mouse.y);
                origX = cropX; origY = cropY; origW = cropW; origH = cropH;
                offX = p.x - (origX + origW);
            }
            onPositionChanged: mouse => {
                const p = mapToItem(root, mouse.x, mouse.y);
                root.resizeFromEdge("e", p.x, p.y, origX, origY, origW, origH, offX, 0);
            }
        }
    }

    // Live dimension badge floating near the crop rect
    Rectangle {
        id: dimBadge
        x: Math.max(8, Math.min(parent.width - width - 8, cropX + cropW / 2 - width / 2))
        y: cropY - height - 10 >= 10 ? (cropY - height - 10) : (cropY + 10)
        implicitWidth: dimText.implicitWidth + 16
        implicitHeight: 24
        radius: 12
        color: Qt.rgba(0, 0, 0, 0.75)
        border.color: Qt.rgba(1, 1, 1, 0.25)
        border.width: 1
        z: 20

        Text {
            id: dimText
            anchors.centerIn: parent
            text: {
                const scaleX = srcW / imageW;
                const scaleY = srcH / imageH;
                const w = Math.round(cropW * scaleX);
                const h = Math.round(cropH * scaleY);
                return w + " × " + h + " px" + (aspectRatio !== "" ? (" • " + aspectRatio) : "");
            }
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall - 1
            font.weight: Font.DemiBold
            color: "white"
        }
    }

    // Bottom toolbar: aspect ratio pills + Apply/Cancel
    Rectangle {
        id: bottomToolbar
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

            // Reset button to revert to full image
            DankActionButton {
                iconName: "restart_alt"
                iconSize: 18
                buttonSize: 32
                iconColor: Theme.surfaceText
                tooltipText: "Reset to Full Image"
                tooltipSide: "top"
                onClicked: {
                    root.aspectRatio = "";
                    root.cropX = root.imageX;
                    root.cropY = root.imageY;
                    root.cropW = root.imageW;
                    root.cropH = root.imageH;
                }
            }

            // Separator
            Rectangle {
                width: 1; height: 22
                color: Theme.outlineVariant
                opacity: 0.4
            }

            // Cancel
            Rectangle {
                implicitWidth: cancelRow.implicitWidth + 24
                implicitHeight: 36
                radius: 18
                color: cancelMouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerLow
                border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.35)
                border.width: 1

                RowLayout {
                    id: cancelRow
                    anchors.centerIn: parent
                    spacing: 6
                    DankIcon { name: "close"; size: 16; color: Theme.surfaceText }
                    Text {
                        text: "Cancel"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                    }
                }

                MouseArea {
                    id: cancelMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.cancelled()
                }
            }

            // Done / Apply
            Rectangle {
                implicitWidth: doneRow.implicitWidth + 24
                implicitHeight: 36
                radius: 18
                color: doneMouse.containsMouse
                    ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.85)
                    : Theme.primary

                RowLayout {
                    id: doneRow
                    anchors.centerIn: parent
                    spacing: 6
                    DankIcon { name: "check"; size: 16; color: Theme.primaryText }
                    Text {
                        text: "Done"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.DemiBold
                        color: Theme.primaryText
                    }
                }

                MouseArea {
                    id: doneMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.applyCrop()
                }
            }
        }
    }

    // Action popover menu anchored directly above the Done button
    Item {
        id: doneMenuContainer
        visible: root.promptVisible
        anchors.fill: parent
        z: 100

        // Click outside to dismiss
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onClicked: root.promptVisible = false
        }

        Rectangle {
            id: doneMenuCard
            anchors.bottom: bottomToolbar.top
            anchors.bottomMargin: 10
            anchors.right: bottomToolbar.right
            width: 240
            radius: 14
            color: Theme.surfaceContainerHigh
            border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.35)
            border.width: 1
            height: doneMenuCol.implicitHeight + 12

            // Swallow clicks inside the card
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                onClicked: {}
            }

            ColumnLayout {
                id: doneMenuCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 6
                spacing: 2

                // Item 1: Save Copy (_crop) - Recommended
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 36
                    radius: 8
                    color: item1Mouse.containsMouse ? Theme.surfaceContainerHighest : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10

                        DankIcon {
                            name: "copy_all"
                            size: 18
                            color: Theme.primary
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "Save Copy (_crop)"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.DemiBold
                            color: Theme.surfaceText
                        }

                        Rectangle {
                            implicitHeight: 16
                            implicitWidth: recText.implicitWidth + 8
                            radius: 4
                            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.25)
                            Text {
                                id: recText
                                anchors.centerIn: parent
                                text: "Rec"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall - 3
                                font.weight: Font.Bold
                                color: Theme.primary
                            }
                        }
                    }

                    MouseArea {
                        id: item1Mouse
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

                // Item 2: Copy to Clipboard
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 36
                    radius: 8
                    color: item2Mouse.containsMouse ? Theme.surfaceContainerHighest : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10

                        DankIcon {
                            name: "content_copy"
                            size: 18
                            color: Theme.surfaceText
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "Copy to Clipboard"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }
                    }

                    MouseArea {
                        id: item2Mouse
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

                // Item 3: Save As...
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 36
                    radius: 8
                    color: item3Mouse.containsMouse ? Theme.surfaceContainerHighest : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10

                        DankIcon {
                            name: "folder_open"
                            size: 18
                            color: Theme.surfaceText
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "Save As..."
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }
                    }

                    MouseArea {
                        id: item3Mouse
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

                // Divider before overwrite
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.outlineVariant
                    opacity: 0.25
                }

                // Item 4: Overwrite Original
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 36
                    radius: 8
                    color: item4Mouse.containsMouse ? Theme.surfaceContainerHighest : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10

                        DankIcon {
                            name: "save"
                            size: 18
                            color: Theme.surfaceText
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "Overwrite Original"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }
                    }

                    MouseArea {
                        id: item4Mouse
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
            }
        }
    }
}
