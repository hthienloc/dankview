import QtQuick
import qs.DankCommon.Widgets

DankActionButton {
    id: root

    property bool busy: false

    iconName: busy ? "" : "refresh"
    enabled: !busy

    DankSpinner {
        anchors.centerIn: parent
        size: root.iconSize
        strokeWidth: 2
        color: root.iconColor
        running: root.busy
        visible: root.busy
    }
}
