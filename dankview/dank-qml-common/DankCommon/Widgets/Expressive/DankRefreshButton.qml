import QtQuick
import qs.DankCommon.Common
import qs.DankCommon.Widgets as Base

DankActionButton {
    id: root

    property bool busy: false

    iconName: busy ? "" : "refresh"
    enabled: !busy

    Base.DankSpinner {
        anchors.centerIn: parent
        size: root.iconSize
        strokeWidth: Style.spinnerStrokeWidth
        color: root.iconColor
        running: root.busy
        visible: root.busy
    }
}
