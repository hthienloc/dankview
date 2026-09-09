import QtQuick
import qs.DankCommon.Common
import qs.DankCommon.Widgets

Rectangle {
    id: root

    property alias text: label.text
    property alias reserveText: label.reserveText
    property alias textColor: label.color

    readonly property real bevelDepth: 2

    implicitWidth: Math.max(Math.ceil(label.reservedWidth) + Style.spacingS * 2, implicitHeight)
    implicitHeight: Math.round(label.font.pixelSize * 2)
    radius: Style.spacingXS + 1
    color: Style.outline

    Rectangle {
        anchors.fill: parent
        anchors.bottomMargin: root.bevelDepth
        radius: root.radius
        color: Style.surfaceContainerHigh
        border.width: 1
        border.color: Style.outline

        NumericText {
            id: label
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Style.fontSizeSmall - 1
            font.weight: Font.Medium
            color: Style.secondary
        }
    }
}
