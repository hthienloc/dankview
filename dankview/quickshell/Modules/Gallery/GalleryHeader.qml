import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

Item {
    id: root

    implicitHeight: ImageService.galleryTab === "gallery" ? 44 : 0
    visible: ImageService.galleryTab === "gallery"

    Behavior on implicitHeight { NumberAnimation { duration: 150; easing.type: Theme.standardEasing } }

    // Category Filter Chips (Gallery tab only)
    Flickable {
        id: chipFlick
        anchors.fill: parent
        anchors.topMargin: 4
        anchors.bottomMargin: 6
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        contentWidth: chipRow.implicitWidth
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        RowLayout {
            id: chipRow
                spacing: 8

                Repeater {
                    model: (ImageService.galleryData && ImageService.galleryData.categories) ? ImageService.galleryData.categories : ["All"]

                    delegate: Rectangle {
                        readonly property bool isSelected: ImageService.selectedCategory === modelData
                        implicitHeight: 32
                        implicitWidth: chipLabel.implicitWidth + 24
                        radius: 8
                        color: isSelected
                            ? Theme.primaryContainer
                            : (chipMouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh)
                        border.color: isSelected
                            ? Theme.primary
                            : Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.28)
                        border.width: 1

                        Text {
                            id: chipLabel
                            anchors.centerIn: parent
                            text: modelData
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: isSelected ? Font.DemiBold : Font.Medium
                            color: isSelected ? Theme.primary : Theme.surfaceText
                        }

                        MouseArea {
                            id: chipMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ImageService.selectedCategory = modelData
                        }
                    }
                }
            }
        }
    }
