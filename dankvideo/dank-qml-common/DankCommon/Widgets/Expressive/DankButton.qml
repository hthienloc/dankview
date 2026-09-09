import QtQuick
import qs.DankCommon.Common
import qs.DankCommon.Widgets as Base

Rectangle {
    id: root

    property string text: ""
    property string iconName: ""
    property int iconSize: Style.iconSizeMedium
    property bool hovered: mouseArea.containsMouse
    property bool pressed: mouseArea.pressed
    property color backgroundColor: Style.buttonBg
    property color textColor: Style.buttonText
    property int buttonHeight: Style.buttonHeightS
    property int horizontalPadding: buttonHeight >= Style.buttonHeightM ? Style.spacingXL : Style.spacingL
    property bool enableScaleAnimation: false
    property bool enableRipple: Style.enableRippleEffects

    signal clicked

    width: Math.max(contentRow.implicitWidth + horizontalPadding * 2, Style.buttonMinWidth)
    height: buttonHeight
    readonly property color contentColor: enabled ? textColor : Style.onSurface_38
    readonly property real pressedRadius: buttonHeight >= Style.buttonHeightM ? Style.cornerRadiusM : Style.cornerRadiusS

    radius: pressed ? pressedRadius : height / 2
    color: enabled ? backgroundColor : Style.onSurface_12
    scale: (enableScaleAnimation && pressed) ? Style.pressScale : 1.0
    activeFocusOnTab: enabled
    Accessible.role: Accessible.Button
    Accessible.name: text
    Accessible.onPressAction: {
        if (enabled)
            clicked();
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

    Behavior on radius {
        enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
        DankAnim {
            duration: Style.expressiveDurations.expressiveEffects
            easing.bezierCurve: Style.expressiveCurves.standard
        }
    }

    Behavior on scale {
        enabled: enableScaleAnimation && Style.currentAnimationSpeed !== Style.AnimationSpeed.None
        DankAnim {
            duration: Style.expressiveDurations.expressiveFastSpatial
            easing.bezierCurve: Style.expressiveCurves.expressiveFastSpatial
        }
    }

    Rectangle {
        id: stateLayer
        anchors.fill: parent
        radius: parent.radius
        color: {
            if (pressed)
                return Style.withAlpha(root.textColor, Style.stateLayerPressed);
            if (hovered)
                return Style.withAlpha(root.textColor, Style.stateLayerHover);
            return Style.withAlpha(root.textColor, 0);
        }

        Behavior on color {
            enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
            DankColorAnim {
                duration: Style.expressiveDurations.expressiveEffects
                easing.bezierCurve: Style.expressiveCurves.expressiveEffects
            }
        }
    }

    Base.DankRipple {
        id: rippleLayer
        rippleColor: root.textColor
        cornerRadius: root.radius
        enableRipple: root.enableRipple
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: Style.spacingS

        Base.DankIcon {
            name: root.iconName
            size: root.iconSize
            color: root.contentColor
            visible: root.iconName !== ""
            anchors.verticalCenter: parent.verticalCenter
        }

        Base.StyledText {
            text: root.text
            font.pixelSize: Style.fontSizeMedium
            font.weight: Font.Medium
            color: root.contentColor
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: root.enabled
        onPressed: mouse => {
            if (root.enableRipple)
                rippleLayer.trigger(mouse.x, mouse.y);
        }
        onClicked: root.clicked()
    }
}
