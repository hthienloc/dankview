pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    enum AnimationSpeed {
        None,
        Short,
        Medium,
        Long,
        Custom
    }

    enum TextRenderType {
        Qt,
        Native,
        Curve
    }

    enum TextRenderQuality {
        Default,
        Low,
        Normal,
        High,
        VeryHigh
    }

    property var theme: null
    property var settings: null

    readonly property bool isLightMode: theme?.isLightMode ?? false

    readonly property color primary: theme?.primary ?? "#D0BCFF"
    readonly property color primaryText: theme?.primaryText ?? "#381E72"
    readonly property color primaryContainer: theme?.primaryContainer ?? "#4F378B"
    readonly property color secondary: theme?.secondary ?? "#CCC2DC"
    readonly property color surface: theme?.surface ?? "#141218"
    readonly property color surfaceText: theme?.surfaceText ?? "#e6e0e9"
    readonly property color surfaceVariant: theme?.surfaceVariant ?? "#49454e"
    readonly property color surfaceVariantText: theme?.surfaceVariantText ?? "#cac4cf"
    readonly property color surfaceTint: theme?.surfaceTint ?? "#D0BCFF"
    readonly property color background: theme?.background ?? "#141218"
    readonly property color outline: theme?.outline ?? "#948f99"
    readonly property color surfaceContainer: theme?.surfaceContainer ?? "#211f24"
    readonly property color surfaceContainerHigh: theme?.surfaceContainerHigh ?? "#2b292f"
    readonly property color error: theme?.error ?? "#F2B8B5"
    readonly property color warning: theme?.warning ?? "#FF9800"
    readonly property color tertiary: theme?.tertiary ?? "#EFB8C8"
    readonly property color surfaceContainerLowest: theme?.surfaceContainerLowest ?? "#0f0d13"
    readonly property color surfaceContainerLow: theme?.surfaceContainerLow ?? "#1d1b20"
    readonly property color surfaceContainerHighest: theme?.surfaceContainerHighest ?? "#36343b"
    readonly property color surfaceBright: theme?.surfaceBright ?? "#3b383e"
    readonly property color surfaceDim: theme?.surfaceDim ?? "#141218"
    readonly property color outlineVariant: theme?.outlineVariant ?? "#49454f"
    readonly property color secondaryContainer: theme?.secondaryContainer ?? "#4a4458"
    readonly property color tertiaryContainer: theme?.tertiaryContainer ?? "#633b48"
    readonly property color inverseSurface: theme?.inverseSurface ?? "#E6E0E9"
    readonly property color inverseOnSurface: theme?.inverseOnSurface ?? "#322F35"

    // on<Role> next to a <role> property parses as a signal handler; only Binding elements assign them.
    property color onSurface
    property color onPrimary
    property color onSurfaceVariant
    property color onPrimaryContainer
    property color onSecondaryContainer
    property color onTertiaryContainer
    readonly property color onSurface_12: theme?.onSurface_12 ?? withAlpha(onSurface, 0.12)
    readonly property color onSurface_38: theme?.onSurface_38 ?? withAlpha(onSurface, 0.38)
    readonly property color onSurfaceVariant_30: theme?.onSurfaceVariant_30 ?? withAlpha(onSurfaceVariant, 0.3)
    readonly property list<QtObject> roleBindings: [
        Binding {
            target: root
            property: "onSurface"
            value: root.theme?.onSurface ?? root.surfaceText
        },
        Binding {
            target: root
            property: "onPrimary"
            value: root.theme?.onPrimary ?? root.primaryText
        },
        Binding {
            target: root
            property: "onSurfaceVariant"
            value: root.theme?.onSurfaceVariant ?? root.surfaceVariantText
        },
        Binding {
            target: root
            property: "onPrimaryContainer"
            value: root.theme?.onPrimaryContainer ?? "#EADDFF"
        },
        Binding {
            target: root
            property: "onSecondaryContainer"
            value: root.theme?.onSecondaryContainer ?? "#E8DEF8"
        },
        Binding {
            target: root
            property: "onTertiaryContainer"
            value: root.theme?.onTertiaryContainer ?? "#FFD8E4"
        }
    ]
    readonly property real tonalTintAlpha: theme?.tonalTintAlpha ?? 0.16

    readonly property color primaryHover: theme?.primaryHover ?? withAlpha(primary, 0.12)
    readonly property color primaryHoverLight: theme?.primaryHoverLight ?? withAlpha(primary, 0.08)
    readonly property color primaryPressed: theme?.primaryPressed ?? withAlpha(primary, 0.16)
    readonly property color primarySelected: theme?.primarySelected ?? withAlpha(primary, 0.3)

    readonly property color surfaceHover: theme?.surfaceHover ?? withAlpha(surfaceVariant, 0.08)
    readonly property color surfacePressed: theme?.surfacePressed ?? withAlpha(surfaceVariant, 0.12)
    readonly property color surfaceLight: theme?.surfaceLight ?? withAlpha(surfaceVariant, 0.1)
    readonly property color surfaceVariantAlpha: theme?.surfaceVariantAlpha ?? withAlpha(surfaceVariant, 0.2)

    readonly property color surfaceTextHover: theme?.surfaceTextHover ?? withAlpha(surfaceText, 0.08)
    readonly property color surfaceTextSecondary: theme?.surfaceTextSecondary ?? withAlpha(surfaceText, 0.6)
    readonly property color surfaceTextMedium: theme?.surfaceTextMedium ?? withAlpha(surfaceText, 0.7)

    readonly property color outlineButton: theme?.outlineButton ?? withAlpha(outline, 0.5)
    readonly property color outlineMedium: theme?.outlineMedium ?? withAlpha(outline, 0.12)
    readonly property color outlineStrong: theme?.outlineStrong ?? withAlpha(outline, 0.18)
    readonly property color outlineHeavy: theme?.outlineHeavy ?? withAlpha(outline, 0.2)

    readonly property color errorHover: theme?.errorHover ?? withAlpha(error, 0.12)
    readonly property color errorSelected: theme?.errorSelected ?? withAlpha(error, 0.3)

    readonly property color floatingSurface: theme?.floatingSurface ?? withAlpha(surfaceContainer, popupTransparency)
    readonly property color nestedSurface: theme?.nestedSurface ?? withAlpha(surfaceContainerHigh, popupTransparency)
    readonly property real floatingWindowTransparency: theme?.floatingWindowTransparency ?? popupTransparency
    readonly property color floatingWindowSurface: theme?.floatingWindowSurface ?? withAlpha(surfaceContainer, floatingWindowTransparency)
    readonly property color floatingWindowNestedSurface: theme?.floatingWindowNestedSurface ?? nestedSurface
    readonly property color floatingWindowFieldColor: theme?.floatingWindowFieldColor ?? withAlpha(surfaceContainerHigh, floatingWindowTransparency)
    readonly property color floatingWindowFieldBorderColor: theme?.floatingWindowFieldBorderColor ?? withAlpha(outline, 0.16)
    readonly property color floatingWindowFieldFocusedBorderColor: theme?.floatingWindowFieldFocusedBorderColor ?? primary
    readonly property color popupFieldColor: theme?.popupFieldColor ?? withAlpha(surfaceContainerHigh, popupTransparency)
    readonly property color popupFieldBorderColor: theme?.popupFieldBorderColor ?? withAlpha(outline, 0.16)
    readonly property color popupFieldFocusedBorderColor: theme?.popupFieldFocusedBorderColor ?? primary
    readonly property color shadowStrong: theme?.shadowStrong ?? Qt.rgba(0, 0, 0, 0.3)

    readonly property color buttonBg: theme?.buttonBg ?? primary
    readonly property color buttonText: theme?.buttonText ?? primaryText
    readonly property color buttonHover: theme?.buttonHover ?? primaryHover
    readonly property color buttonPressed: theme?.buttonPressed ?? primaryPressed
    readonly property color widgetBaseHoverColor: theme?.widgetBaseHoverColor ?? _blend(surfaceContainer, primary, 0.1)

    readonly property int smallBreakpoint: theme?.smallBreakpoint ?? 480
    readonly property int mediumBreakpoint: theme?.mediumBreakpoint ?? 768

    readonly property real cornerRadius: theme?.cornerRadius ?? 12
    readonly property real shapeScale: theme?.shapeScale ?? Math.max(0, Math.min(cornerRadius / 16, 1.5))
    readonly property real cornerRadiusXS: theme?.cornerRadiusXS ?? Math.round(4 * shapeScale)
    readonly property real cornerRadiusS: theme?.cornerRadiusS ?? Math.round(8 * shapeScale)
    readonly property real cornerRadiusM: theme?.cornerRadiusM ?? Math.round(12 * shapeScale)
    readonly property real cornerRadiusL: theme?.cornerRadiusL ?? cornerRadius
    readonly property real cornerRadiusXL: theme?.cornerRadiusXL ?? Math.round(28 * shapeScale)
    readonly property real cornerRadiusXXL: theme?.cornerRadiusXXL ?? Math.round(48 * shapeScale)
    readonly property real cornerRadiusFull: theme?.cornerRadiusFull ?? 9999
    readonly property real cornerRadiusSmall: cornerRadiusS
    readonly property real cornerRadiusLarge: cornerRadiusL
    readonly property real groupedListGap: theme?.groupedListGap ?? spacingXXS
    readonly property real groupedListInnerRadius: theme?.groupedListInnerRadius ?? cornerRadiusXS
    readonly property real groupedListOuterRadius: theme?.groupedListOuterRadius ?? cornerRadiusL
    readonly property real spacingXXS: theme?.spacingXXS ?? 2
    readonly property real spacingXS: theme?.spacingXS ?? 4
    readonly property real spacingS: theme?.spacingS ?? 8
    readonly property real spacingM: theme?.spacingM ?? 12
    readonly property real spacingL: theme?.spacingL ?? 16
    readonly property real spacingXL: theme?.spacingXL ?? 24
    readonly property real fontSizeSmall: theme?.fontSizeSmall ?? 12
    readonly property real fontSizeMedium: theme?.fontSizeMedium ?? 14
    readonly property real fontSizeLarge: theme?.fontSizeLarge ?? 16
    readonly property real fontSizeXLarge: theme?.fontSizeXLarge ?? 20
    readonly property real fontSizeXXLarge: theme?.fontSizeXXLarge ?? 28
    readonly property real fontSizeDisplay: theme?.fontSizeDisplay ?? 36
    readonly property real iconSize: theme?.iconSize ?? 24
    readonly property real iconSizeSmall: theme?.iconSizeSmall ?? 16
    readonly property real iconSizeMedium: theme?.iconSizeMedium ?? 20
    readonly property real iconSizeLarge: theme?.iconSizeLarge ?? 32
    readonly property real iconButtonSize: theme?.iconButtonSize ?? 40
    readonly property real listItemHeight: theme?.listItemHeight ?? 56
    readonly property real listItemTwoLineHeight: theme?.listItemTwoLineHeight ?? 72
    readonly property real avatarSize: theme?.avatarSize ?? 36
    readonly property real sliderTrackHeight: theme?.sliderTrackHeight ?? 16
    readonly property real sliderHandleWidth: theme?.sliderHandleWidth ?? 4
    readonly property real sliderHandleHeight: theme?.sliderHandleHeight ?? 28
    readonly property real sliderHandleGap: theme?.sliderHandleGap ?? 6
    readonly property real sliderTrackHeightS: theme?.sliderTrackHeightS ?? 20
    readonly property real sliderHandleHeightS: theme?.sliderHandleHeightS ?? 32
    readonly property real sliderTrackHeightM: theme?.sliderTrackHeightM ?? 32
    readonly property real sliderHandleHeightM: theme?.sliderHandleHeightM ?? 44
    readonly property real sliderTrackHeightL: theme?.sliderTrackHeightL ?? 40
    readonly property real sliderHandleHeightL: theme?.sliderHandleHeightL ?? 52
    readonly property real sliderTrackHeightXL: theme?.sliderTrackHeightXL ?? 56
    readonly property real sliderHandleHeightXL: theme?.sliderHandleHeightXL ?? 68
    readonly property real switchTrackWidth: theme?.switchTrackWidth ?? 52
    readonly property real switchTrackHeight: theme?.switchTrackHeight ?? 32
    readonly property real switchOutlineWidth: theme?.switchOutlineWidth ?? 2
    readonly property real switchThumbUnselected: theme?.switchThumbUnselected ?? 16
    readonly property real switchThumbSelected: theme?.switchThumbSelected ?? 24
    readonly property real switchThumbPressed: theme?.switchThumbPressed ?? 28
    readonly property real sliderStopSize: theme?.sliderStopSize ?? 4
    readonly property real sliderTickSize: theme?.sliderTickSize ?? 3
    readonly property real menuItemHeight: theme?.menuItemHeight ?? 40
    readonly property real outlineWidth: theme?.outlineWidth ?? 1
    readonly property real outlineWidthFocused: theme?.outlineWidthFocused ?? 2
    readonly property real dividerWidth: theme?.dividerWidth ?? 1
    readonly property real focusRingWidth: theme?.focusRingWidth ?? 2
    readonly property real focusRingOffset: theme?.focusRingOffset ?? 4
    readonly property color focusRingColor: theme?.focusRingColor ?? primary
    readonly property real scrimAlpha: theme?.scrimAlpha ?? 0.55
    readonly property real buttonHeightXS: theme?.buttonHeightXS ?? 32
    readonly property real buttonHeightS: theme?.buttonHeightS ?? 40
    readonly property real buttonHeightM: theme?.buttonHeightM ?? 56
    readonly property real buttonMinWidth: theme?.buttonMinWidth ?? 58
    readonly property real pressScale: theme?.pressScale ?? 0.98
    readonly property real iconEnterScale: theme?.iconEnterScale ?? 0.6
    readonly property real popupEnterScale: theme?.popupEnterScale ?? 0.92
    readonly property real pendingOpacity: theme?.pendingOpacity ?? 0.6
    readonly property real spinnerStrokeWidth: theme?.spinnerStrokeWidth ?? 2
    readonly property real tabMinWidth: theme?.tabMinWidth ?? 64
    readonly property real tabIndicatorHeight: theme?.tabIndicatorHeight ?? 3
    readonly property real fieldDefaultWidth: theme?.fieldDefaultWidth ?? 200
    readonly property real fieldHeight: theme?.fieldHeight ?? Math.round(fontSizeMedium * 3)
    readonly property real fieldHeightLarge: theme?.fieldHeightLarge ?? 48
    readonly property real textEditHeight: theme?.textEditHeight ?? Math.round(fontSizeMedium * 8)
    readonly property real tooltipMaxWidth: theme?.tooltipMaxWidth ?? 500
    readonly property real menuMaxHeight: theme?.menuMaxHeight ?? 400
    readonly property real clockFaceSize: theme?.clockFaceSize ?? 250
    readonly property real clockOuterRingRatio: theme?.clockOuterRingRatio ?? 0.34
    readonly property real clockInnerRingRatio: theme?.clockInnerRingRatio ?? 0.2
    readonly property real clockHandWidth: theme?.clockHandWidth ?? 2
    readonly property real clockHandleSize: theme?.clockHandleSize ?? 40
    readonly property real clockCenterSize: theme?.clockCenterSize ?? 8
    readonly property int clockSwitchDelay: theme?.clockSwitchDelay ?? 100
    readonly property real chipIconSize: theme?.chipIconSize ?? 18
    readonly property real buttonGroupExpandRatio: theme?.buttonGroupExpandRatio ?? 0.15
    readonly property string fontFamily: theme?.fontFamily ?? Fonts.sans
    readonly property string monoFontFamily: theme?.monoFontFamily ?? Fonts.mono
    readonly property int fontWeight: theme?.fontWeight ?? Font.Normal
    readonly property real popupTransparency: theme?.popupTransparency ?? 1.0

    readonly property int currentAnimationSpeed: theme?.currentAnimationSpeed ?? Style.AnimationSpeed.Short
    readonly property int currentAnimationBaseDuration: theme?.currentAnimationBaseDuration ?? 500
    readonly property int shorterDuration: theme?.shorterDuration ?? 50
    readonly property int shortDuration: theme?.shortDuration ?? 75
    readonly property int mediumDuration: theme?.mediumDuration ?? 150
    readonly property int standardEasing: theme?.standardEasing ?? Easing.OutCubic
    readonly property int emphasizedEasing: theme?.emphasizedEasing ?? Easing.OutQuart

    readonly property var expressiveCurves: theme?.expressiveCurves ?? ({
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

    readonly property var expressiveDurations: theme?.expressiveDurations ?? ({
            "fast": 200,
            "normal": 400,
            "large": 600,
            "extraLarge": 1000,
            "expressiveFastSpatial": 350,
            "expressiveDefaultSpatial": 500,
            "expressiveEffects": 200
        })

    readonly property bool elevationEnabled: theme?.elevationEnabled ?? true
    readonly property string elevationLightDirection: theme?.elevationLightDirection ?? "top"
    readonly property var elevationLevel2: theme?.elevationLevel2 ?? ({
            blurPx: 8,
            offsetX: 0,
            offsetY: 4,
            spreadPx: 0,
            alpha: 0.25
        })

    readonly property var elevationLevel1: theme?.elevationLevel1 ?? ({
            blurPx: 4,
            offsetX: 0,
            offsetY: 1,
            spreadPx: 0,
            alpha: 0.2
        })
    readonly property var elevationLevel3: theme?.elevationLevel3 ?? ({
            blurPx: 12,
            offsetX: 0,
            offsetY: 6,
            spreadPx: 0,
            alpha: 0.3
        })

    readonly property real stateLayerHover: theme?.stateLayerHover ?? 0.08
    readonly property real stateLayerFocus: theme?.stateLayerFocus ?? 0.12
    readonly property real stateLayerPressed: theme?.stateLayerPressed ?? 0.12
    readonly property real stateLayerDrag: theme?.stateLayerDrag ?? 0.16

    readonly property var springSpecs: theme?.springSpecs ?? ({
            "expressive": [560, 37],
            "fast": [220, 23],
            "default": [100, 16]
        })
    readonly property var springDampingScales: theme?.springDampingScales ?? [1.22, 1.0, 0.82]
    readonly property bool springMotionDisabled: theme?.springMotionDisabled ?? (currentAnimationBaseDuration <= 0)

    readonly property bool blurLayersActive: theme?.blurLayersActive ?? true
    readonly property bool connectedSurfaceBlurEnabled: theme?.connectedSurfaceBlurEnabled ?? true
    readonly property color blurBorderColor: {
        if (!(settings?.blurBorderEnabled ?? true))
            return "transparent";
        const opacity = settings?.blurBorderOpacity ?? 0.35;
        switch (settings?.blurBorderColor ?? "outline") {
        case "primary":
            return withAlpha(primary, opacity);
        case "secondary":
            return withAlpha(secondary, opacity);
        case "surfaceText":
            return withAlpha(surfaceText, opacity);
        case "custom":
            return withAlpha(Qt.color(settings?.blurBorderCustomColor ?? "#ffffff"), opacity);
        default:
            return withAlpha(outline, opacity);
        }
    }
    readonly property int blurBorderWidth: (settings?.blurBorderEnabled ?? true) ? 1 : 0

    readonly property bool enableRippleEffects: settings?.enableRippleEffects ?? true
    readonly property bool popoutElevationEnabled: settings?.popoutElevationEnabled ?? true
    readonly property int textRenderType: settings?.textRenderType ?? Style.TextRenderType.Qt
    readonly property int textRenderQuality: settings?.textRenderQuality ?? Style.TextRenderQuality.Default
    readonly property bool powerActionConfirm: settings?.powerActionConfirm ?? true
    readonly property real powerActionHoldDuration: settings?.powerActionHoldDuration ?? 0.5
    readonly property var powerMenuActions: settings?.powerMenuActions ?? ["reboot", "logout", "poweroff", "lock", "suspend", "restart"]
    readonly property string powerMenuDefaultAction: settings?.powerMenuDefaultAction ?? "logout"
    readonly property bool powerMenuGridLayout: settings?.powerMenuGridLayout ?? false
    readonly property bool reduceMotion: settings?.reduceMotion ?? false
    readonly property int springBounce: settings?.springBounce ?? 1

    function springPreset(name, baseDuration) {
        if (theme && typeof theme.springPreset === "function")
            return theme.springPreset(name, baseDuration);
        const spec = springSpecs[name] ?? springSpecs["default"];
        const f = Math.max(0.05, baseDuration / 500);
        const bounce = springBounce >= 0 && springBounce < springDampingScales.length ? springDampingScales[Math.round(springBounce)] : 1;
        return {
            "stiffness": spec[0] / (f * f),
            "damping": spec[1] / f * bounce,
            "mass": 1
        };
    }

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

    function _blend(c1, c2, r) {
        return Qt.rgba(c1.r * (1 - r) + c2.r * r, c1.g * (1 - r) + c2.g * r, c1.b * (1 - r) + c2.b * r, c1.a * (1 - r) + c2.a * r);
    }

    function elevationOffsetXFor(level, direction, fallback) {
        if (typeof theme?.elevationOffsetXFor === "function")
            return theme.elevationOffsetXFor(level, direction, fallback);
        return level?.offsetX ?? 0;
    }

    function elevationOffsetYFor(level, direction, fallback) {
        if (typeof theme?.elevationOffsetYFor === "function")
            return theme.elevationOffsetYFor(level, direction, fallback);
        return level?.offsetY ?? (fallback ?? 0);
    }

    function elevationShadowColor(level) {
        if (typeof theme?.elevationShadowColor === "function")
            return theme.elevationShadowColor(level);
        return Qt.rgba(0, 0, 0, level?.alpha ?? 0.3);
    }

    function elevationAmbient(level) {
        if (typeof theme?.elevationAmbient === "function")
            return theme.elevationAmbient(level);
        return {
            blurPx: (level?.blurPx ?? 0) * 1.75,
            spreadPx: 1,
            alpha: (level?.alpha ?? 0.3) * 0.5
        };
    }
}
