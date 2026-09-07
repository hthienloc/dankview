import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

Item {
    id: root

    clip: true

    readonly property string source: {
        if (!ImageService.currentFilePath) return "";
        const base = "file://" + encodeURI(ImageService.currentFilePath).replace(/#/g, "%23").replace(/\?/g, "%3F");
        return ImageService.reloadToken > 0 ? (base + "?v=" + ImageService.reloadToken) : base;
    }
    readonly property bool hasImage: ImageService.currentFilePath !== ""

    DropArea {
        anchors.fill: parent
        onDropped: drop => {
            if (drop.hasUrls && drop.urls.length > 0) {
                let urlStr = drop.urls[0].toString();
                if (urlStr.startsWith("file://")) {
                    urlStr = decodeURIComponent(urlStr.substring(7));
                }
                if (urlStr) {
                    ImageService.loadDirectoryFor(urlStr);
                    drop.acceptProposedAction();
                }
            }
        }
    }

    // Contrast background + checkerboard for transparent images
    Rectangle {
        anchors.fill: parent
        color: Theme.surfaceContainerLowest

        Canvas {
            id: checkerCanvas
            anchors.fill: parent
            opacity: root.hasImage ? 0.5 : 0.0
            visible: opacity > 0
            onPaint: {
                const ctx = getContext("2d");
                const s = 16;
                ctx.fillStyle = Theme.surfaceContainerLowest;
                ctx.fillRect(0, 0, width, height);
                ctx.fillStyle = Theme.surfaceContainerLow;
                for (let y = 0; y < height; y += s) {
                    const rowEven = Math.floor(y / s) % 2 === 0;
                    for (let x = (rowEven ? 0 : s); x < width; x += s * 2) {
                        ctx.fillRect(x, y, s, s);
                    }
                }
            }
            Connections {
                target: Theme
                function onSurfaceContainerLowestChanged() { checkerCanvas.requestPaint(); }
                function onSurfaceContainerLowChanged() { checkerCanvas.requestPaint(); }
            }
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
        }
    }

    Item {
        id: viewport
        anchors.fill: parent
        visible: root.hasImage

        Item {
            id: container
            width: imageElement.paintedWidth > 0 ? imageElement.paintedWidth : imageElement.implicitWidth
            height: imageElement.paintedHeight > 0 ? imageElement.paintedHeight : imageElement.implicitHeight
            x: (viewport.width - width) / 2 + ImageService.panX
            y: (viewport.height - height) / 2 + ImageService.panY
            scale: ImageService.zoom
            rotation: ImageService.rotation

            transform: [
                Scale {
                    origin.x: container.width / 2
                    origin.y: container.height / 2
                    xScale: ImageService.flipH ? -1 : 1
                    yScale: ImageService.flipV ? -1 : 1
                }
            ]

            Behavior on rotation {
                enabled: !ImageService.resettingTransform
                NumberAnimation {
                    duration: Theme.shortDuration
                    easing.type: Theme.standardEasing
                }
            }

            AnimatedImage {
                id: imageElement
                anchors.centerIn: parent
                source: root.source
                playing: ImageService.isPlaying
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                cache: false

                onFrameCountChanged: {
                    ImageService.frameCount = frameCount;
                    ImageService.isAnimated = frameCount > 1;
                }

                onCurrentFrameChanged: {
                    ImageService.currentFrame = currentFrame;
                }

                onSourceChanged: {
                    ImageService.isPlaying = true;
                    currentFrame = 0;
                }

                // Scale up or down to fit viewport initially if needed
                property real fitScale: {
                    if (implicitWidth <= 0 || implicitHeight <= 0 || viewport.width <= 0 || viewport.height <= 0)
                        return 1.0;
                    const scaleX = (viewport.width - 64) / implicitWidth;
                    const scaleY = (viewport.height - 128) / implicitHeight;
                    return Math.min(1.0, Math.min(scaleX, scaleY));
                }

                onFitScaleChanged: {
                    ImageService.fitScale = fitScale;
                }

                width: implicitWidth > 0 ? implicitWidth * fitScale : 400
                height: implicitHeight > 0 ? implicitHeight * fitScale : 300
            }
        }


        // Pinch handler for trackpad gestures
        PinchHandler {
            target: null
            enabled: !ImageService.cropMode
            onScaleChanged: delta => {
                ImageService.zoom = Math.max(ImageService.minZoom, Math.min(ImageService.maxZoom, ImageService.zoom * delta));
            }
        }

        // Drag handler to pan when zoomed
        DragHandler {
            target: null
            enabled: !ImageService.cropMode
            onTranslationChanged: delta => {
                ImageService.panX += delta.x;
                ImageService.panY += delta.y;
            }
        }

        // MouseArea for double-click, drag, and mouse wheel zoom
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
            hoverEnabled: false
            enabled: !ImageService.cropMode

            onWheel: wheel => {
                const factor = wheel.angleDelta.y > 0 ? 1.25 : (1.0 / 1.25);
                ImageService.zoomAt(factor, wheel.x, wheel.y, viewport.width, viewport.height);
                wheel.accepted = true;
            }

            onDoubleClicked: {
                if (Math.abs(ImageService.zoom - 1.0) < 0.1) {
                    ImageService.zoom = 2.0;
                } else {
                    ImageService.resetZoom();
                }
            }
        }
    }

    // Empty State Browser View
    Item {
        id: emptyState
        anchors.fill: parent
        visible: !root.hasImage

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 88
                height: 88
                radius: 44
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.25)
                border.width: 1

                DankIcon {
                    anchors.centerIn: parent
                    name: "add_photo_alternate"
                    size: 44
                    color: Theme.primary
                }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 6

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "No Image Open"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeXLarge
                    font.weight: Font.DemiBold
                    color: Theme.surfaceText
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Drag and drop an image here, or browse files"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.surfaceVariantText
                }
            }

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: openBtnRow.implicitWidth + 36
                implicitHeight: 46
                radius: 23
                color: openBtnMouse.containsMouse
                    ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.85)
                    : Theme.primary

                RowLayout {
                    id: openBtnRow
                    anchors.centerIn: parent
                    spacing: 8

                    DankIcon {
                        name: "folder_open"
                        size: 20
                        color: Theme.primaryText
                    }

                    Text {
                        text: "Open Image (Ctrl+O)"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMedium
                        font.weight: Font.DemiBold
                        color: Theme.primaryText
                    }
                }

                MouseArea {
                    id: openBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ImageService.openFileDialog()
                }
            }
        }
    }

    // Previous / Next overlay edge buttons (hovering edges reveals subtle arrows)
    MouseArea {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 80
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        visible: root.hasImage && ImageService.fileList.length > 1
        onClicked: ImageService.prevImage()

        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            width: 44
            height: 44
            radius: 22
            color: parent.containsMouse ? Theme.surfaceContainerHigh : "transparent"
            opacity: parent.containsMouse ? 0.9 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.shorterDuration
                    easing.type: Theme.standardEasing
                }
            }

            DankIcon {
                anchors.centerIn: parent
                name: "chevron_left"
                size: 28
                color: Theme.surfaceText
            }
        }
    }

    MouseArea {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 80
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        visible: root.hasImage && ImageService.fileList.length > 1 && !ImageService.inspectorOpen
        onClicked: ImageService.nextImage()

        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            width: 44
            height: 44
            radius: 22
            color: parent.containsMouse ? Theme.surfaceContainerHigh : "transparent"
            opacity: parent.containsMouse ? 0.9 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.shorterDuration
                    easing.type: Theme.standardEasing
                }
            }

            DankIcon {
                anchors.centerIn: parent
                name: "chevron_right"
                size: 28
                color: Theme.surfaceText
            }
        }
    }
}
