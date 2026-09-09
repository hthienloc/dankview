import QtQuick
import qs.DankCommon.Common
import qs.DankCommon.Widgets as Base

Base.StyledRect {
    id: root

    property string iconName: ""
    property int iconSize: Style.iconSizeMedium
    property color iconColor: Style.onSurfaceVariant
    property color backgroundColor: "transparent"
    property bool circular: true
    property int buttonSize: Style.buttonHeightXS
    property var tooltipText: null
    property string tooltipSide: "bottom"
    readonly property alias pressed: stateLayer.pressed

    signal clicked
    signal entered
    signal exited

    width: buttonSize
    height: buttonSize
    radius: pressed ? Math.min(Style.cornerRadiusS, height / 2) : (circular ? height / 2 : Style.cornerRadiusM)
    color: backgroundColor
    activeFocusOnTab: enabled
    Accessible.role: Accessible.Button
    Accessible.name: tooltipText || iconName
    Accessible.onPressAction: {
        if (enabled)
            clicked();
    }

    Behavior on radius {
        enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
        DankAnim {
            duration: Style.expressiveDurations.expressiveEffects
            easing.bezierCurve: Style.expressiveCurves.standard
        }
    }

    Keys.onPressed: event => {
        if (!root.enabled)
            return;
        switch (event.key) {
        case Qt.Key_Space:
        case Qt.Key_Return:
        case Qt.Key_Enter:
            root.clicked();
            event.accepted = true;
            break;
        }
    }

    Base.FocusRing {}

    Base.DankIcon {
        anchors.centerIn: parent
        name: root.iconName
        size: root.iconSize
        color: root.enabled ? root.iconColor : Style.onSurface_38
    }

    Base.StateLayer {
        id: stateLayer
        disabled: !root.enabled
        stateColor: Style.primary
        cornerRadius: root.radius
        onClicked: root.clicked()
        onEntered: root.entered()
        onExited: root.exited()
        tooltipText: root.tooltipText
        tooltipSide: root.tooltipSide
    }
}
