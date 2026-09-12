import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

Item {
    id: root

    property var windowControls: null
    property var targetWindow: null

    GalleryHeader {
        id: header
        windowControls: root.windowControls
        targetWindow: root.targetWindow
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        z: 20
    }

    Item {
        id: contentContainer
        anchors.top: header.bottom
        anchors.topMargin: 10
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        GalleryTimeline {
            anchors.fill: parent
            visible: ImageService.galleryTab === "gallery"
        }

        GalleryAlbums {
            anchors.fill: parent
            visible: ImageService.galleryTab === "albums"
        }
    }

    // Floating Bottom Navigation Dock
    GalleryDock {
        id: dock
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        z: 30
    }
}
