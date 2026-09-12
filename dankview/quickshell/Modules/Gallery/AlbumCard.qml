import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

Item {
    id: root

    property var album: null
    property real cardWidth: 176
    property real previewHeight: 176

    width: cardWidth
    height: previewHeight + 36

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        Rectangle {
            id: previewBox
            Layout.fillWidth: true
            Layout.preferredHeight: root.previewHeight
            radius: 16
            clip: true
            color: Theme.surfaceContainerHigh
            border.color: cardMouse.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.5) : Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.25)
            border.width: 1

            scale: cardMouse.containsMouse ? 1.02 : 1.0
            Behavior on scale { NumberAnimation { duration: 120; easing.type: Theme.standardEasing } }

            // 2x2 Grid of Previews
            Grid {
                anchors.fill: parent
                anchors.margins: 4
                columns: 2
                rows: 2
                spacing: 3

                readonly property real cellW: Math.floor((width - 3) / 2)
                readonly property real cellH: Math.floor((height - 3) / 2)

                Repeater {
                    model: 4
                    delegate: Rectangle {
                        width: parent.cellW
                        height: parent.cellH
                        radius: 8
                        clip: true
                        color: Theme.surfaceContainerLowest || "#181818"

                        readonly property string imgPath: {
                            if (!root.album || !root.album.previews || root.album.previews.length === 0) return "";
                            if (index < root.album.previews.length) {
                                return root.album.previews[index];
                            }
                            // Fallback repeat first preview if fewer than 4
                            return root.album.previews[0] || "";
                        }

                        Image {
                            anchors.fill: parent
                            visible: parent.imgPath !== ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            source: parent.imgPath !== "" ? ("file://" + parent.imgPath) : ""
                            sourceSize.width: 180
                            sourceSize.height: 180
                        }

                        DankIcon {
                            anchors.centerIn: parent
                            visible: parent.imgPath === ""
                            name: "image"
                            size: 24
                            color: Theme.surfaceVariantText
                        }
                    }
                }
            }

            MouseArea {
                id: cardMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.album) {
                        ImageService.selectedCategory = root.album.name;
                        ImageService.galleryTab = "gallery";
                    }
                }
            }
        }

        // Album Title & Count
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.album ? root.album.name : ""
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall + 1
                font.weight: Font.DemiBold
                color: Theme.surfaceText
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.album ? (root.album.totalCount + " photos") : ""
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall - 1
                color: Theme.surfaceVariantText
                elide: Text.ElideRight
            }
        }
    }
}
