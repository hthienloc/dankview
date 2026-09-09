pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.DankCommon.Common

Singleton {
    id: root

    readonly property bool isLightMode: false

    property color primary: "#D0BCFF"
    property color primaryText: "#381E72"
    property color primaryContainer: "#4F378B"
    property color secondary: "#CCC2DC"
    property color surface: "#141218"
    property color surfaceText: "#E6E0E9"
    property color surfaceVariant: "#49454F"
    property color surfaceVariantText: "#CAC4D0"
    property color background: "#141218"
    property color outline: "#938F99"
    property color surfaceContainer: "#211F26"
    property color surfaceContainerHigh: "#2B2930"
    property color error: "#F2B8B5"
    property color tertiary: "#EFB8C8"
    property color surfaceContainerLowest: "#0F0D13"
    property color surfaceContainerLow: "#1D1B20"
    property color surfaceContainerHighest: "#36343B"
    property color surfaceBright: "#3B383E"
    property color surfaceDim: "#141218"
    property color outlineVariant: "#49454F"
    property color secondaryContainer: "#4A4458"
    property color tertiaryContainer: "#633B48"
    property color inverseSurface: "#E6E0E9"
    property color inverseOnSurface: "#322F35"
    property color onSurface
    property color onPrimary
    property color onSurfaceVariant
    property color onPrimaryContainer
    property color onSecondaryContainer
    property color onTertiaryContainer
    property color onSurfaceVariant_30: withAlpha(onSurfaceVariant, 0.3)
    readonly property list<QtObject> roleBindings: [
        Binding {
            target: root
            property: "onSurface"
            value: root.surfaceText
        },
        Binding {
            target: root
            property: "onPrimary"
            value: root.primaryText
        },
        Binding {
            target: root
            property: "onSurfaceVariant"
            value: root.surfaceVariantText
        },
        Binding {
            target: root
            property: "onPrimaryContainer"
            value: "#EADDFF"
        },
        Binding {
            target: root
            property: "onSecondaryContainer"
            value: "#E8DEF8"
        },
        Binding {
            target: root
            property: "onTertiaryContainer"
            value: "#FFD8E4"
        }
    ]
    readonly property real tonalTintAlpha: 0.16

    property color warning: "#FF9800"

    property color onSurface_12: withAlpha(onSurface, 0.12)
    property color onSurface_38: withAlpha(onSurface, 0.38)
    property color surfaceTint: primary
    property color surfaceLight: withAlpha(surfaceVariant, 0.1)

    property color primaryHover: withAlpha(primary, 0.12)
    property color primaryHoverLight: withAlpha(primary, 0.08)
    property color primaryPressed: withAlpha(primary, 0.16)
    property color primarySelected: withAlpha(primary, 0.3)
    property color errorHover: withAlpha(error, 0.12)
    property color errorSelected: withAlpha(error, 0.3)
    property color surfaceHover: withAlpha(surfaceVariant, 0.08)
    property color surfacePressed: withAlpha(surfaceVariant, 0.12)
    property color surfaceVariantAlpha: withAlpha(surfaceVariant, 0.2)
    property color surfaceTextHover: withAlpha(surfaceText, 0.08)
    property color surfaceTextMedium: withAlpha(surfaceText, 0.7)
    property color surfaceTextSecondary: withAlpha(surfaceText, 0.6)
    property color outlineButton: withAlpha(outline, 0.5)
    property color outlineMedium: withAlpha(outline, 0.12)
    property color outlineStrong: withAlpha(outline, 0.18)
    property color outlineHeavy: withAlpha(outline, 0.2)
    property color shadowStrong: Qt.rgba(0, 0, 0, 0.3)

    property color buttonBg: primary
    property color buttonText: primaryText
    property color buttonHover: primaryHover
    property color buttonPressed: withAlpha(primary, 0.16)

    property real popupTransparency: 1.0
    readonly property color floatingSurface: withAlpha(surfaceContainer, popupTransparency)
    readonly property color nestedSurface: withAlpha(surfaceContainerHigh, popupTransparency)

    property real floatingWindowTransparency: popupTransparency
    property color floatingWindowSurface: withAlpha(surfaceContainer, floatingWindowTransparency)
    property color floatingWindowNestedSurface: nestedSurface
    property color floatingWindowFieldColor: withAlpha(surfaceContainerHigh, floatingWindowTransparency)
    property color floatingWindowFieldBorderColor: withAlpha(outline, 0.16)
    property color floatingWindowFieldFocusedBorderColor: primary
    property color popupFieldColor: withAlpha(surfaceContainerHigh, popupTransparency)
    property color popupFieldBorderColor: withAlpha(outline, 0.16)
    property color popupFieldFocusedBorderColor: primary
    property bool blurLayersActive: true

    property color widgetBaseHoverColor: {
        const blended = blend(surfaceContainerHigh, primary, 0.1);
        return withAlpha(blended, Math.max(0.3, blended.a));
    }

    property real spacingXXS: 2
    property real spacingXS: 4
    property real spacingS: 8
    property real spacingM: 12
    property real spacingL: 16
    property real spacingXL: 24

    property real fontSizeSmall: 12
    property real fontSizeMedium: 14
    property real fontSizeLarge: 16
    property real fontSizeXLarge: 20
    property real fontSizeXXLarge: 28
    property real fontSizeDisplay: 36

    property real iconSizeSmall: 16
    property real iconSize: 24
    property real iconSizeLarge: 32

    property real cornerRadius: 12
    readonly property real shapeScale: Math.max(0, Math.min(cornerRadius / 16, 1.5))
    readonly property real cornerRadiusXS: Math.round(4 * shapeScale)
    readonly property real cornerRadiusS: Math.round(8 * shapeScale)
    readonly property real cornerRadiusM: Math.round(12 * shapeScale)
    readonly property real cornerRadiusL: cornerRadius
    readonly property real cornerRadiusXL: Math.round(28 * shapeScale)
    readonly property real cornerRadiusXXL: Math.round(48 * shapeScale)
    readonly property real cornerRadiusFull: 9999
    readonly property real cornerRadiusSmall: cornerRadiusS
    readonly property real cornerRadiusLarge: cornerRadiusL
    readonly property real groupedListGap: spacingXXS
    readonly property real groupedListInnerRadius: cornerRadiusXS
    readonly property real groupedListOuterRadius: cornerRadiusL
    readonly property real iconButtonSize: 40
    readonly property real listItemHeight: 56
    readonly property real listItemTwoLineHeight: 72
    readonly property real avatarSize: 36
    readonly property real sliderTrackHeight: 16
    readonly property real sliderHandleWidth: 4
    readonly property real sliderHandleHeight: 28
    readonly property real sliderHandleGap: 6
    readonly property real sliderTrackHeightS: 20
    readonly property real sliderHandleHeightS: 32
    readonly property real sliderTrackHeightM: 32
    readonly property real sliderHandleHeightM: 44
    readonly property real sliderTrackHeightL: 40
    readonly property real sliderHandleHeightL: 52
    readonly property real sliderTrackHeightXL: 56
    readonly property real sliderHandleHeightXL: 68
    readonly property real switchTrackWidth: 52
    readonly property real switchTrackHeight: 32
    readonly property real switchOutlineWidth: 2
    readonly property real switchThumbUnselected: 16
    readonly property real switchThumbSelected: 24
    readonly property real switchThumbPressed: 28
    readonly property real sliderStopSize: 4
    readonly property real sliderTickSize: 3
    readonly property real menuItemHeight: 40
    readonly property real outlineWidth: 1
    readonly property real outlineWidthFocused: 2
    readonly property real dividerWidth: 1
    readonly property real focusRingWidth: 2
    readonly property real focusRingOffset: 4
    readonly property color focusRingColor: primary
    readonly property real scrimAlpha: 0.55
    readonly property real buttonHeightXS: 32
    readonly property real buttonHeightS: 40
    readonly property real buttonHeightM: 56
    readonly property real buttonMinWidth: 58
    readonly property real pressScale: 0.98
    readonly property real iconEnterScale: 0.6
    readonly property real popupEnterScale: 0.92
    readonly property real pendingOpacity: 0.6
    readonly property real spinnerStrokeWidth: 2
    readonly property real tabMinWidth: 64
    readonly property real tabIndicatorHeight: 3
    readonly property real fieldDefaultWidth: 200
    readonly property real fieldHeight: Math.round(fontSizeMedium * 3)
    readonly property real fieldHeightLarge: 48
    readonly property real textEditHeight: Math.round(fontSizeMedium * 8)
    readonly property real tooltipMaxWidth: 500
    readonly property real menuMaxHeight: 400
    readonly property real clockFaceSize: 250
    readonly property real clockOuterRingRatio: 0.34
    readonly property real clockInnerRingRatio: 0.2
    readonly property real clockHandWidth: 2
    readonly property real clockHandleSize: 40
    readonly property real clockCenterSize: 8
    readonly property int clockSwitchDelay: 100
    readonly property real chipIconSize: 18
    readonly property real buttonGroupExpandRatio: 0.15
    readonly property real iconSizeMedium: 20
    readonly property int smallBreakpoint: 480
    readonly property int mediumBreakpoint: 768
    readonly property bool connectedSurfaceBlurEnabled: true
    readonly property string elevationLightDirection: "top"

    readonly property string defaultFontFamily: Fonts.sans
    readonly property string defaultMonoFontFamily: Fonts.mono
    property string fontFamily: defaultFontFamily
    property string monoFontFamily: defaultMonoFontFamily
    property int fontWeight: Font.Normal

    property int shorterDuration: 100
    property int shortDuration: 200
    property int mediumDuration: 350
    property int standardEasing: Easing.OutCubic
    property int emphasizedEasing: Easing.OutQuart

    readonly property int currentAnimationSpeed: SettingsData.animationSpeed
    readonly property int currentAnimationBaseDuration: 500
    readonly property bool elevationEnabled: true

    readonly property real stateLayerHover: 0.08
    readonly property real stateLayerFocus: 0.12
    readonly property real stateLayerPressed: 0.12
    readonly property real stateLayerDrag: 0.16

    readonly property var springSpecs: ({
            "expressive": [560, 37],
            "fast": [220, 23],
            "default": [100, 16]
        })
    readonly property var springDampingScales: [1.22, 1.0, 0.82]
    readonly property bool springMotionDisabled: currentAnimationBaseDuration <= 0

    function springPreset(name, baseDuration) {
        const spec = springSpecs[name] ?? springSpecs["default"];
        const f = Math.max(0.05, baseDuration / 500);
        const bounce = springDampingScales[Math.round(SettingsData.springBounce)] ?? 1;
        return {
            "stiffness": spec[0] / (f * f),
            "damping": spec[1] / f * bounce,
            "mass": 1
        };
    }

    readonly property var elevationLevel1: ({
            blurPx: 4,
            offsetX: 0,
            offsetY: 1,
            spreadPx: 0,
            alpha: 0.2
        })
    readonly property var elevationLevel3: ({
            blurPx: 12,
            offsetX: 0,
            offsetY: 6,
            spreadPx: 0,
            alpha: 0.3
        })

    readonly property var elevationLevel2: ({
            blurPx: 8,
            offsetX: 4,
            offsetY: 4,
            spreadPx: 0,
            alpha: 0.25
        })

    readonly property var expressiveCurves: ({
            "emphasized": [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1],
            "emphasizedAccel": [0.3, 0, 0.8, 0.15, 1, 1],
            "emphasizedDecel": [0.05, 0.7, 0.1, 1, 1, 1],
            "standard": [0.2, 0, 0, 1, 1, 1],
            "standardAccel": [0.3, 0, 1, 1, 1, 1],
            "standardDecel": [0, 0, 0, 1, 1, 1],
            "expressiveFastSpatial": [0.42, 1.67, 0.21, 0.9, 1, 1],
            "expressiveDefaultSpatial": [0.38, 1.21, 0.22, 1, 1, 1],
            "expressiveEffects": [0.34, 0.8, 0.34, 1, 1, 1]
        })

    readonly property var expressiveDurations: ({
            "fast": 200,
            "normal": 400,
            "large": 600,
            "extraLarge": 1000,
            "expressiveFastSpatial": 350,
            "expressiveDefaultSpatial": 500,
            "expressiveEffects": 200
        })

    function withAlpha(c, a) {
        if (!c || c.r === undefined)
            return Qt.rgba(0, 0, 0, 0);
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    function blendAlpha(c, a) {
        if (!c || c.r === undefined)
            return Qt.rgba(0, 0, 0, 0);
        return Qt.rgba(c.r, c.g, c.b, c.a * a);
    }

    function blend(c1, c2, r) {
        return Qt.rgba(c1.r * (1 - r) + c2.r * r, c1.g * (1 - r) + c2.g * r, c1.b * (1 - r) + c2.b * r, c1.a * (1 - r) + c2.a * r);
    }
}
