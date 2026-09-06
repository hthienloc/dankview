import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

Item {
    id: root

    clip: true

    readonly property string source: ImageService.currentFilePath ? "file://" + ImageService.currentFilePath : ""
    readonly property bool hasImage: ImageService.currentFilePath !== ""

    // Contrast background + checkerboard for transparent images
    Rectangle {
        anchors.fill: parent
        color: Theme.surfaceContainerLowest

        Canvas {
            id: checkerCanvas
            anchors.fill: parent
            opacity: 0.5
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
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                cache: true

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
            onScaleChanged: delta => {
                ImageService.zoom = Math.max(0.05, Math.min(30.0, ImageService.zoom * delta));
            }
        }

        // Drag handler to pan when zoomed
        DragHandler {
            target: null
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

    // Previous / Next overlay edge buttons (hovering edges reveals subtle arrows)
    MouseArea {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 80
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        visible: ImageService.fileList.length > 1
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
        visible: ImageService.fileList.length > 1 && !ImageService.inspectorOpen
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
