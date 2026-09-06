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
    signal cancelled()

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

    readonly property int HANDLE: 14

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
        // Ensure rect stays within image bounds
        if (cropX < imageX) { cropW -= (imageX - cropX); cropX = imageX; }
        if (cropY < imageY) { cropH -= (imageY - cropY); cropY = imageY; }
        if (cropX + cropW > imageX + imageW) cropW = imageX + imageW - cropX;
        if (cropY + cropH > imageY + imageH) cropH = imageY + imageH - cropY;
        cropW = Math.max(20, cropW);
        cropH = Math.max(20, cropH);
    }

    function _applyAspect() {
        if (aspectRatio === "") return;
        const parts = aspectRatio.split(":");
        const ar = parseFloat(parts[0]) / parseFloat(parts[1]);
        cropH = cropW / ar;
        // Re-clamp height
        if (cropY + cropH > imageY + imageH) {
            cropH = imageY + imageH - cropY;
            cropW = cropH * ar;
        }
    }

    function applyCrop() {
        const scaleX = srcW / imageW;
        const scaleY = srcH / imageH;
        const px = Math.round((cropX - imageX) * scaleX);
        const py = Math.round((cropY - imageY) * scaleY);
        const pw = Math.round(cropW * scaleX);
        const ph = Math.round(cropH * scaleY);
        root.cropped(
            Math.max(0, px), Math.max(0, py),
            Math.min(pw, srcW - px), Math.min(ph, srcH - py)
        );
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
        x: cropX + HANDLE; y: cropY + HANDLE
        width: cropW - HANDLE * 2; height: cropH - HANDLE * 2
        cursorShape: Qt.SizeAllCursor
        property real startX: 0; property real startY: 0
        property real origCropX: 0; property real origCropY: 0
        onPressed: mouse => { startX = mouse.x; startY = mouse.y; origCropX = cropX; origCropY = cropY; }
        onPositionChanged: mouse => {
            cropX = origCropX + (mouse.x - startX);
            cropY = origCropY + (mouse.y - startY);
            root._clamp();
        }
    }

    // Corner handles — NW, NE, SW, SE
    component Handle: Rectangle {
        width: HANDLE * 2; height: HANDLE * 2
        color: "transparent"

        Rectangle {
            anchors.centerIn: parent
            width: HANDLE; height: HANDLE
            radius: 3
            color: "white"
            border.color: Qt.rgba(0, 0, 0, 0.4)
            border.width: 1
        }
    }

    // NW
    Handle {
        x: cropX - HANDLE; y: cropY - HANDLE
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.SizeFDiagCursor
            property real startX: 0; property real startY: 0
            property real origX: 0; property real origY: 0
            property real origW: 0; property real origH: 0
            onPressed: mouse => {
                startX = mapToItem(root, mouse.x, mouse.y).x;
                startY = mapToItem(root, mouse.x, mouse.y).y;
                origX = cropX; origY = cropY; origW = cropW; origH = cropH;
            }
            onPositionChanged: mouse => {
                const p = mapToItem(root, mouse.x, mouse.y);
                const dx = p.x - startX; const dy = p.y - startY;
                cropX = origX + dx; cropW = origW - dx;
                cropY = origY + dy; cropH = origH - dy;
                root._clamp(); root._applyAspect();
            }
        }
    }

    // NE
    Handle {
        x: cropX + cropW - HANDLE; y: cropY - HANDLE
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.SizeBDiagCursor
            property real startX: 0; property real startY: 0
            property real origY: 0; property real origW: 0; property real origH: 0
            onPressed: mouse => {
                startX = mapToItem(root, mouse.x, mouse.y).x;
                startY = mapToItem(root, mouse.x, mouse.y).y;
                origY = cropY; origW = cropW; origH = cropH;
            }
            onPositionChanged: mouse => {
                const p = mapToItem(root, mouse.x, mouse.y);
                cropW = origW + (p.x - startX);
                cropY = origY + (p.y - startY); cropH = origH - (p.y - startY);
                root._clamp(); root._applyAspect();
            }
        }
    }

    // SW
    Handle {
        x: cropX - HANDLE; y: cropY + cropH - HANDLE
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.SizeBDiagCursor
            property real startX: 0; property real startY: 0
            property real origX: 0; property real origW: 0; property real origH: 0
            onPressed: mouse => {
                startX = mapToItem(root, mouse.x, mouse.y).x;
                startY = mapToItem(root, mouse.x, mouse.y).y;
                origX = cropX; origW = cropW; origH = cropH;
            }
            onPositionChanged: mouse => {
                const p = mapToItem(root, mouse.x, mouse.y);
                cropX = origX + (p.x - startX); cropW = origW - (p.x - startX);
                cropH = origH + (p.y - startY);
                root._clamp(); root._applyAspect();
            }
        }
    }

    // SE
    Handle {
        x: cropX + cropW - HANDLE; y: cropY + cropH - HANDLE
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.SizeFDiagCursor
            property real startX: 0; property real startY: 0
            property real origW: 0; property real origH: 0
            onPressed: mouse => {
                startX = mapToItem(root, mouse.x, mouse.y).x;
                startY = mapToItem(root, mouse.x, mouse.y).y;
                origW = cropW; origH = cropH;
            }
            onPositionChanged: mouse => {
                const p = mapToItem(root, mouse.x, mouse.y);
                cropW = origW + (p.x - startX);
                cropH = origH + (p.y - startY);
                root._clamp(); root._applyAspect();
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
}
