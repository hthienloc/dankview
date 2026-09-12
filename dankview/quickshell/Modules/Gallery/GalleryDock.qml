import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

Rectangle {
    id: root

    implicitHeight: 46
    implicitWidth: 240
    radius: 23
    color: Qt.rgba(Theme.surfaceContainerHigh.r, Theme.surfaceContainerHigh.g, Theme.surfaceContainerHigh.b, 0.95)
    border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.28)
    border.width: 1

    RowLayout {
        id: navRow
        anchors.centerIn: parent
        spacing: 6

        // Gallery Tab Button
        Rectangle {
            id: galleryTabBtn
            readonly property bool isActive: ImageService.galleryTab === "gallery"
            implicitHeight: 38
            implicitWidth: 110
            radius: 19
            color: isActive ? Theme.primaryContainer : (gMouse.containsMouse ? Theme.surfaceContainerHighest : "transparent")

            Behavior on color { ColorAnimation { duration: 120 } }

            RowLayout {
                anchors.centerIn: parent
                spacing: 6

                DankIcon {
                    name: "photo_library"
                    size: 20
                    color: galleryTabBtn.isActive ? Theme.primary : Theme.surfaceText
                }

                Text {
                    text: "Gallery"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall + 1
                    font.weight: galleryTabBtn.isActive ? Font.DemiBold : Font.Normal
                    color: galleryTabBtn.isActive ? Theme.primary : Theme.surfaceText
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
            implicitWidth: 110
            radius: 19
            color: isActive ? Theme.primaryContainer : (aMouse.containsMouse ? Theme.surfaceContainerHighest : "transparent")

            Behavior on color { ColorAnimation { duration: 120 } }

            RowLayout {
                anchors.centerIn: parent
                spacing: 6

                DankIcon {
                    name: "collections_bookmark"
                    size: 20
                    color: albumsTabBtn.isActive ? Theme.primary : Theme.surfaceText
                }

                Text {
                    text: "Albums"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall + 1
                    font.weight: albumsTabBtn.isActive ? Font.DemiBold : Font.Normal
                    color: albumsTabBtn.isActive ? Theme.primary : Theme.surfaceText
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
