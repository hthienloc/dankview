import QtQuick
import qs.DankCommon.Common
import qs.DankCommon.Widgets as Base

Column {
    id: root
    property string text: ""
    property var incrementTooltipText: ""
    property var decrementTooltipText: ""
    property var onIncrement: undefined
    property var onDecrement: undefined
    property string incrementIconName: "keyboard_arrow_up"
    property string decrementIconName: "keyboard_arrow_down"

    property bool incrementEnabled: true
    property bool decrementEnabled: true

    property color textColor: Style.surfaceText
    property color iconColor: Style.onSurfaceVariant
    property color backgroundColor: Style.primary

    property int textSize: Style.fontSizeSmall
    property var iconSize: Style.iconSizeSmall
    property int buttonSize: Style.iconSizeMedium
    property int horizontalPadding: Style.spacingL

    readonly property bool effectiveIncrementEnabled: root.onIncrement ? root.incrementEnabled : false
    readonly property bool effectiveDecrementEnabled: root.onDecrement ? root.decrementEnabled : false

    width: Math.max(buttonSize * 2, root.implicitWidth + horizontalPadding * 2)
    spacing: Style.spacingXS

    DankActionButton {
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: root.effectiveIncrementEnabled
        iconColor: root.iconColor
        iconSize: root.iconSize
        buttonSize: root.buttonSize
        iconName: root.incrementIconName
        onClicked: if (typeof root.onIncrement === 'function')
            root.onIncrement()
        tooltipText: root.incrementTooltipText
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Style.spacingXS

        Base.StyledText {
            isMonospace: true
            text: root.text
            font.pixelSize: root.textSize
            color: root.textColor
        }
    }

    DankActionButton {
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: root.effectiveDecrementEnabled
        iconColor: root.iconColor
        iconSize: root.iconSize
        buttonSize: root.buttonSize
        iconName: root.decrementIconName
        onClicked: if (typeof root.onDecrement === 'function')
            root.onDecrement()
        tooltipText: root.decrementTooltipText
    }
}
