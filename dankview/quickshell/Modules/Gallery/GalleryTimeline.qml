import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

Item {
    id: root

    readonly property var rawGroups: (ImageService.galleryData && ImageService.galleryData.groups) ? ImageService.galleryData.groups : []

    // Filter groups and images according to selectedCategory
    readonly property var filteredGroups: {
        const cat = ImageService.selectedCategory;
        if (!cat || cat === "All") return rawGroups;

        const result = [];
        for (let i = 0; i < rawGroups.length; i++) {
            const grp = rawGroups[i];
            const imgs = grp.images.filter(img => img.category === cat);
            if (imgs.length > 0) {
                result.push({
                    dateGroup: grp.dateGroup,
                    images: imgs
                });
            }
        }
        return result;
    }

    readonly property int columns: Math.max(3, Math.min(6, Math.floor((width - 40) / 168)))
    readonly property real tileWidth: Math.floor((width - 40 - (columns - 1) * 10) / columns)

    DankFlickable {
        id: flick
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.bottomMargin: 80
        contentHeight: timelineCol.implicitHeight + 40
        clip: true

        ColumnLayout {
            id: timelineCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 24

            // Loading indicator
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                visible: ImageService.isGalleryLoading && root.filteredGroups.length === 0

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12
                    DankIcon {
                        Layout.alignment: Qt.AlignHCenter
                        name: "sync"
                        size: 32
                        color: Theme.primary
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Scanning pictures..."
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.surfaceVariantText
                    }
                }
            }

            // Empty state
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 160
                visible: !ImageService.isGalleryLoading && root.filteredGroups.length === 0

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12
                    DankIcon {
                        Layout.alignment: Qt.AlignHCenter
                        name: "image_not_supported"
                        size: 40
                        color: Theme.surfaceVariantText
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "No images found"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMedium
                        font.weight: Font.DemiBold
                        color: Theme.surfaceText
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Add images to your Pictures folder or choose another category"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                    }
                }
            }

            // Date Groups Repeater
            Repeater {
                model: root.filteredGroups

                delegate: ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    // Date Header
                    Text {
                        text: modelData.dateGroup
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMedium + 1
                        font.weight: Font.DemiBold
                        color: Theme.surfaceText
                    }

                    // Grid of Thumbnails
                    Flow {
                        Layout.fillWidth: true
                        spacing: 10

                        Repeater {
                            model: modelData.images

                            delegate: GalleryThumbnail {
                                flickable: flick
                                imageItem: modelData
                                tileSize: root.tileWidth
                            }
                        }
                    }
                }
            }
        }
    }
}
