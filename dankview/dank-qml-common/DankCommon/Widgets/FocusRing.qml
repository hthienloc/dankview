import QtQuick
import qs.DankCommon.Common

Rectangle {
    anchors.fill: parent
    anchors.margins: -Style.focusRingOffset
    radius: parent.radius + Style.focusRingOffset
    color: "transparent"
    border.width: Style.focusRingWidth
    border.color: Style.focusRingColor
    visible: parent.activeFocus
}
