import QtQuick
import Quickshell.Widgets
import qs.DankCommon.Common
import qs.DankCommon.Widgets as Base

Rectangle {
    id: card

    LayoutMirroring.enabled: I18n.isRtl
    LayoutMirroring.childrenInherit: true

    property int pad: Style.spacingM
    property bool clickable: false
    property bool interactive: true
    property string title: ""
    property string tone: ""
    default property alias content: contentItem.data

    signal clicked

    readonly property bool acceptsInput: clickable && interactive && enabled
    readonly property bool tinted: tone === "primary" || tone === "secondary" || tone === "tertiary"
    readonly property color containerColor: {
        switch (tone) {
        case "primary":
            return Style.primaryContainer;
        case "secondary":
            return Style.secondaryContainer;
        case "tertiary":
            return Style.tertiaryContainer;
        }
        return Style.surfaceContainerHigh;
    }
    readonly property color contentColor: {
        switch (tone) {
        case "primary":
            return Style.onPrimaryContainer;
        case "secondary":
            return Style.onSecondaryContainer;
        case "tertiary":
            return Style.onTertiaryContainer;
        }
        return Style.surfaceText;
    }
    readonly property color accentColor: tinted ? contentColor : Style.primary
    readonly property color onAccentColor: tinted ? containerColor : Style.onPrimary
    readonly property color mutedColor: tinted ? Style.withAlpha(contentColor, 0.72) : Style.onSurfaceVariant
    readonly property color chipColor: tinted ? Style.withAlpha(contentColor, Style.stateLayerFocus) : Style.withAlpha(Style.surfaceContainerHighest, Style.popupTransparency)
    readonly property color surfaceColor: Style.withAlpha(containerColor, Style.popupTransparency)
    property real restRadius: Style.cornerRadiusXL
    property real bodyRadius: layer.pressed ? Style.cornerRadiusM : restRadius

    radius: bodyRadius
    color: surfaceColor
    activeFocusOnTab: acceptsInput
    Accessible.role: clickable ? Accessible.Button : Accessible.Pane
    Accessible.name: title

    Keys.onPressed: event => {
        if (!acceptsInput)
            return;
        switch (event.key) {
        case Qt.Key_Space:
        case Qt.Key_Return:
        case Qt.Key_Enter:
            card.clicked();
            event.accepted = true;
            break;
        }
    }

    Behavior on bodyRadius {
        enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
        NumberAnimation {
            duration: Style.expressiveDurations.expressiveFastSpatial
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Style.expressiveCurves.expressiveFastSpatial
        }
    }

    Base.StateLayer {
        id: layer
        visible: card.acceptsInput
        disabled: !card.acceptsInput
        stateColor: card.accentColor
        cornerRadius: card.bodyRadius
        onClicked: card.clicked()
    }

    Base.FocusRing {}

    Base.StyledText {
        id: titleLabel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: card.pad
        text: card.title
        font.pixelSize: Style.fontSizeMedium
        font.weight: Font.Medium
        color: card.accentColor
        elide: Text.ElideRight
        visible: text !== ""
    }

    ClippingRectangle {
        anchors.fill: parent
        radius: card.bodyRadius
        color: "transparent"
        opacity: card.interactive ? 1 : 0.45
        scale: card.interactive ? 1 : 0.92
        transformOrigin: Item.Center

        Item {
            id: contentItem
            anchors.fill: parent
            anchors.margins: card.pad
            anchors.topMargin: card.pad + (titleLabel.visible ? titleLabel.height + Style.spacingXS : 0)
        }

        Behavior on opacity {
            enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
            NumberAnimation {
                duration: Style.expressiveDurations.expressiveEffects
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Style.expressiveCurves.expressiveEffects
            }
        }

        Behavior on scale {
            enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
            NumberAnimation {
                duration: Style.expressiveDurations.expressiveFastSpatial
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Style.expressiveCurves.expressiveFastSpatial
            }
        }
    }
}
