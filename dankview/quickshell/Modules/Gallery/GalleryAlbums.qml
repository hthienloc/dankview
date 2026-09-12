import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

Item {
    id: root

    readonly property var allAlbums: (ImageService.galleryData && ImageService.galleryData.albums) ? ImageService.galleryData.albums : []
    readonly property var pinnedAlbums: allAlbums.filter(a => a.isPinned)
    readonly property var customAlbums: allAlbums.filter(a => !a.isPinned)

    DankFlickable {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.bottomMargin: 80
        contentHeight: albumsCol.implicitHeight + 40
        clip: true

        ColumnLayout {
            id: albumsCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 28

            // Pinned Categories
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 14
                visible: root.pinnedAlbums.length > 0

                Text {
                    text: "Pinned Categories"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium + 1
                    font.weight: Font.DemiBold
                    color: Theme.surfaceText
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 16

                    Repeater {
                        model: root.pinnedAlbums

                        delegate: AlbumCard {
                            album: modelData
                            cardWidth: 176
                            previewHeight: 176
                        }
                    }
                }
            }

            // Custom Categories
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 14
                visible: root.customAlbums.length > 0

                Text {
                    text: "Custom Categories"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium + 1
                    font.weight: Font.DemiBold
                    color: Theme.surfaceText
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 16

                    Repeater {
                        model: root.customAlbums

                        delegate: AlbumCard {
                            album: modelData
                            cardWidth: 176
                            previewHeight: 176
                        }
                    }
                }
            }

            // Empty state if no albums
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 160
                visible: root.allAlbums.length === 0

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12
                    DankIcon {
                        Layout.alignment: Qt.AlignHCenter
                        name: "folder_open"
                        size: 40
                        color: Theme.surfaceVariantText
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "No albums found"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMedium
                        font.weight: Font.DemiBold
                        color: Theme.surfaceText
                    }
                }
            }
        }
    }
}
