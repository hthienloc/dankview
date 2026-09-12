import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

Item {
    id: root

    implicitHeight: ImageService.galleryTab === "gallery" ? 76 : 32
    Behavior on implicitHeight { NumberAnimation { duration: 150; easing.type: Theme.standardEasing } }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // Grab Handle at the top center
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 18

            Rectangle {
                anchors.centerIn: parent
                width: 38
                height: 4
                radius: 2
                color: Qt.rgba(1, 1, 1, 0.35)
            }
        }

        // Category Filter Chips (Gallery tab only)
        Flickable {
            id: chipFlick
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            visible: ImageService.galleryTab === "gallery"
            opacity: visible ? 1.0 : 0.0
            contentWidth: chipRow.implicitWidth
            boundsBehavior: Flickable.StopAtBounds
            clip: true

            Behavior on opacity { NumberAnimation { duration: 150 } }

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
}
