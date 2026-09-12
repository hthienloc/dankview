import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

Rectangle {
    id: root

    implicitHeight: 46
    implicitWidth: navRow.implicitWidth + 12
    radius: 23
    color: Qt.rgba(Theme.surfaceContainerHigh.r, Theme.surfaceContainerHigh.g, Theme.surfaceContainerHigh.b, 0.95)
    border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.28)
    border.width: 1

    RowLayout {
        id: navRow
        anchors.centerIn: parent
        spacing: 4

        // Gallery Tab Button
        Rectangle {
            id: galleryTabBtn
            readonly property bool isActive: ImageService.galleryTab === "gallery"
            implicitHeight: 38
            implicitWidth: isActive ? (galleryInner.implicitWidth + 24) : 42
            radius: 19
            color: isActive ? Theme.primaryContainer : (gMouse.containsMouse ? Theme.surfaceContainerHighest : "transparent")

            Behavior on implicitWidth { NumberAnimation { duration: 180; easing.type: Theme.standardEasing } }
            Behavior on color { ColorAnimation { duration: 120 } }

            RowLayout {
                id: galleryInner
                anchors.centerIn: parent
                spacing: 6

                DankIcon {
                    name: "photo_library"
                    size: 20
                    color: galleryTabBtn.isActive ? Theme.primary : Theme.surfaceText
                }

                Text {
                    visible: galleryTabBtn.isActive
                    text: "Gallery"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall + 1
                    font.weight: Font.DemiBold
                    color: Theme.primary
                }
            }

            MouseArea {
                id: gMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: ImageService.galleryTab = "gallery"
            }
        }

        // Albums Tab Button
        Rectangle {
            id: albumsTabBtn
            readonly property bool isActive: ImageService.galleryTab === "albums"
            implicitHeight: 38
            implicitWidth: isActive ? (albumsInner.implicitWidth + 24) : 42
            radius: 19
            color: isActive ? Theme.primaryContainer : (aMouse.containsMouse ? Theme.surfaceContainerHighest : "transparent")

            Behavior on implicitWidth { NumberAnimation { duration: 180; easing.type: Theme.standardEasing } }
            Behavior on color { ColorAnimation { duration: 120 } }

            RowLayout {
                id: albumsInner
                anchors.centerIn: parent
                spacing: 6

                DankIcon {
                    name: "collections_bookmark"
                    size: 20
                    color: albumsTabBtn.isActive ? Theme.primary : Theme.surfaceText
                }

                Text {
                    visible: albumsTabBtn.isActive
                    text: "Albums"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall + 1
                    font.weight: Font.DemiBold
                    color: Theme.primary
                }
            }

            MouseArea {
                id: aMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: ImageService.galleryTab = "albums"
            }
        }
    }
}
