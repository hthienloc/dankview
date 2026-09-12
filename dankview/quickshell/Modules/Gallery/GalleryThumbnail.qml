import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

Item {
    id: root

    property var flickable: null
    property var imageItem: null
    property real tileSize: 160

    width: tileSize
    height: tileSize

    readonly property bool isSelected: imageItem ? ImageService.isSelected(imageItem.path) : false
    readonly property bool isFav: imageItem ? ImageService.isFavorite(imageItem.path) : false

    // Viewport visibility calculation to avoid loading off-screen images in large galleries
    readonly property real itemContentY: flickable ? root.mapToItem(flickable.contentItem, 0, 0).y : 0
    readonly property bool inView: {
        if (!flickable) return true;
        const topBound = flickable.contentY - 600;
        const bottomBound = flickable.contentY + flickable.height + 600;
        return itemContentY + height >= topBound && itemContentY <= bottomBound;
    }

    property bool hasLoaded: false
    onInViewChanged: {
        if (inView && !hasLoaded) {
            hasLoaded = true;
        }
    }
    Component.onCompleted: {
        if (inView) {
            hasLoaded = true;
        }
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: 12
        clip: true
        color: Theme.surfaceContainerHigh
        border.color: root.isSelected ? Theme.primary : (thumbMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.4) : "transparent")
        border.width: root.isSelected ? 2 : 1

        scale: thumbMouse.containsMouse ? 1.02 : 1.0
        Behavior on scale { NumberAnimation { duration: 120; easing.type: Theme.standardEasing } }

        Image {
            id: thumbImg
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            source: {
                if (!root.imageItem || !root.hasLoaded) return "";
                if (root.imageItem.thumbnail) return "file://" + root.imageItem.thumbnail;
                return "file://" + root.imageItem.path;
            }
            sourceSize.width: 256
            sourceSize.height: 256
        }

        // Dark gradient overlay for icons visibility on light photos
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 44
            visible: thumbMouse.containsMouse || root.isSelected || root.isFav
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.55) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        // Selection Checkbox (Top-Left)
        Rectangle {
            id: selectBtn
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 8
            width: 24
            height: 24
            radius: 12
            visible: thumbMouse.containsMouse || root.isSelected
            color: root.isSelected ? Theme.primary : Qt.rgba(0, 0, 0, 0.35)
            border.color: root.isSelected ? Theme.primary : Qt.rgba(1, 1, 1, 0.8)
            border.width: root.isSelected ? 0 : 1.5

            DankIcon {
                anchors.centerIn: parent
                visible: root.isSelected
                name: "check"
                size: 16
                color: Theme.primaryText
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.imageItem) {
                        ImageService.toggleSelect(root.imageItem.path);
                    }
                }
            }
        }

        // Favorite Heart Button (Top-Right)
        Rectangle {
            id: favBtn
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 8
            width: 24
            height: 24
            radius: 12
            visible: thumbMouse.containsMouse || root.isFav
            color: Qt.rgba(0, 0, 0, 0.35)

            DankIcon {
                anchors.centerIn: parent
                name: "favorite"
                filled: root.isFav
                size: 16
                color: root.isFav ? Theme.error : Qt.rgba(1, 1, 1, 0.9)
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.imageItem) {
                        ImageService.toggleFavorite(root.imageItem.path);
                    }
                }
            }
        }

        // Body Click to Open in Viewer
        MouseArea {
            id: thumbMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            z: -1
            onClicked: {
                if (root.imageItem) {
                    ImageService.openImageFromGallery(root.imageItem.path, root.imageItem.thumbnail || "");
                }
            }
        }
    }
}
