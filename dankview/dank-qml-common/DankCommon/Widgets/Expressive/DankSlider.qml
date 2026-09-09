import QtQuick
import qs.DankCommon.Common
import qs.DankCommon.Widgets as Base

Item {
    id: slider

    function checkParentDisablesTransparency() {
        let p = parent;
        while (p) {
            if (p.disablePopupTransparency === true)
                return true;
            p = p.parent;
        }
        return false;
    }

    property int value: 50
    property int minimum: 0
    property int maximum: 100
    property int step: 1
    property string leftIcon: ""
    property string rightIcon: ""
    property string unit: "%"
    property bool showValue: true
    property bool isDragging: false
    property bool wheelEnabled: true
    property bool centerMinimum: false
    property real valueOverride: -1
    property int decimals: 0
    property bool alwaysShowValue: false
    property string size: "xs"
    readonly property bool containsMouse: sliderMouseArea.containsMouse

    property color thumbOutlineColor: Style.surfaceContainer
    property color trackColor: Style.secondaryContainer
    property bool usePopupTransparency: !checkParentDisablesTransparency()
    property real trackOpacity: usePopupTransparency ? Style.popupTransparency : 1.0

    signal sliderValueChanged(int newValue)
    signal sliderDragFinished(int finalValue)

    function formatValue(v) {
        if (decimals <= 0)
            return Math.round(v) + unit;
        return (v / Math.pow(10, decimals)).toFixed(decimals) + unit;
    }

    readonly property real ratio: {
        const range = maximum - minimum;
        const raw = range === 0 ? 0 : (value - minimum) / range;
        const clamped = Math.max(0, Math.min(1, raw));
        return centerMinimum ? (0.5 + clamped * 0.5) : clamped;
    }
    readonly property bool mirrored: I18n.isRtl
    readonly property real trackHeight: {
        switch (size) {
        case "s":
            return Style.sliderTrackHeightS;
        case "m":
            return Style.sliderTrackHeightM;
        case "l":
            return Style.sliderTrackHeightL;
        case "xl":
            return Style.sliderTrackHeightXL;
        default:
            return Style.sliderTrackHeight;
        }
    }
    readonly property real handleHeight: {
        switch (size) {
        case "s":
            return Style.sliderHandleHeightS;
        case "m":
            return Style.sliderHandleHeightM;
        case "l":
            return Style.sliderHandleHeightL;
        case "xl":
            return Style.sliderHandleHeightXL;
        default:
            return Style.sliderHandleHeight;
        }
    }
    readonly property real insideCorner: {
        switch (size) {
        case "l":
            return Style.cornerRadiusS;
        case "xl":
            return Style.cornerRadiusM;
        default:
            return Style.cornerRadiusXS;
        }
    }
    readonly property real visualRatio: mirrored ? 1 - ratio : ratio
    readonly property int tickCount: {
        if (step <= 1)
            return 0;
        const steps = Math.floor((maximum - minimum) / step);
        return steps >= 2 && steps <= 12 ? steps + 1 : 0;
    }
    readonly property int keyStep: step > 1 ? step : Math.max(1, Math.round((maximum - minimum) / 100))
    readonly property int pageSteps: Math.max(1, Math.min(10, Math.round((maximum - minimum) / keyStep / 10)))

    height: handleHeight + Style.spacingXS
    activeFocusOnTab: enabled
    readonly property int minimumValue: minimum
    readonly property int maximumValue: maximum
    readonly property int stepSize: keyStep
    Accessible.role: Accessible.Slider
    Accessible.focusable: enabled
    Accessible.onIncreaseAction: {
        if (enabled)
            stepBy(1);
    }
    Accessible.onDecreaseAction: {
        if (enabled)
            stepBy(-1);
    }

    function commit(newValue) {
        const clamped = Math.max(minimum, Math.min(maximum, newValue));
        if (clamped === value)
            return;
        value = clamped;
        sliderValueChanged(clamped);
    }

    function stepBy(direction) {
        let next = value + direction * keyStep;
        if (step > 1)
            next = minimum + Math.round((next - minimum) / step) * step;
        commit(Math.round(next));
        sliderDragFinished(value);
    }

    function updateValueFromPosition(x) {
        if (sliderTrack.width <= sliderHandle.width)
            return;
        let ratio = Math.max(0, Math.min(1, (x - sliderHandle.width / 2) / (sliderTrack.width - sliderHandle.width)));
        if (mirrored)
            ratio = 1 - ratio;
        if (centerMinimum)
            ratio = Math.max(0, (ratio - 0.5) * 2);
        let rawValue = minimum + ratio * (maximum - minimum);
        let newValue = step > 1 ? minimum + Math.round((rawValue - minimum) / step) * step : Math.round(rawValue);
        commit(newValue);
    }

    Keys.onPressed: event => {
        if (!enabled)
            return;
        const upKey = mirrored ? Qt.Key_Left : Qt.Key_Right;
        const downKey = mirrored ? Qt.Key_Right : Qt.Key_Left;
        switch (event.key) {
        case upKey:
        case Qt.Key_Up:
            stepBy(1);
            event.accepted = true;
            break;
        case downKey:
        case Qt.Key_Down:
            stepBy(-1);
            event.accepted = true;
            break;
        case Qt.Key_PageUp:
            stepBy(pageSteps);
            event.accepted = true;
            break;
        case Qt.Key_PageDown:
            stepBy(-pageSteps);
            event.accepted = true;
            break;
        case Qt.Key_Home:
            commit(minimum);
            sliderDragFinished(value);
            event.accepted = true;
            break;
        case Qt.Key_End:
            commit(maximum);
            sliderDragFinished(value);
            event.accepted = true;
            break;
        }
    }

    Row {
        anchors.centerIn: parent
        width: parent.width
        spacing: Style.spacingM
        LayoutMirroring.enabled: slider.mirrored

        Base.DankIcon {
            name: slider.leftIcon
            size: Style.iconSize
            color: slider.enabled ? Style.surfaceText : Style.onSurface_38
            anchors.verticalCenter: parent.verticalCenter
            visible: slider.leftIcon.length > 0
        }

        Item {
            id: sliderTrack

            property int leftIconWidth: slider.leftIcon.length > 0 ? Style.iconSize : 0
            property int rightIconWidth: slider.rightIcon.length > 0 ? Style.iconSize : 0
            readonly property real travel: width - sliderHandle.width
            readonly property real handleLeft: Math.max(0, Math.min(travel, travel * slider.visualRatio))
            readonly property real centerX: width / 2
            readonly property real gap: Style.sliderHandleGap
            readonly property real filledStart: slider.mirrored ? sliderHandle.x + sliderHandle.width + gap : 0
            readonly property real filledEnd: slider.mirrored ? width : sliderHandle.x - gap
            readonly property real emptyStart: slider.mirrored ? 0 : sliderHandle.x + sliderHandle.width + gap
            readonly property real emptyEnd: slider.mirrored ? sliderHandle.x - gap : width

            width: parent.width - (leftIconWidth + rightIconWidth + (slider.leftIcon.length > 0 ? Style.spacingM : 0) + (slider.rightIcon.length > 0 ? Style.spacingM : 0))
            height: slider.handleHeight
            anchors.verticalCenter: parent.verticalCenter

            Base.StyledRect {
                id: activeTrack
                readonly property real startX: slider.centerMinimum ? Math.min(sliderTrack.centerX, slider.mirrored ? sliderTrack.filledStart : sliderTrack.filledEnd) : sliderTrack.filledStart
                readonly property real endX: slider.centerMinimum ? Math.max(sliderTrack.centerX, slider.mirrored ? sliderTrack.filledStart : sliderTrack.filledEnd) : sliderTrack.filledEnd
                x: startX
                width: Math.max(0, endX - startX)
                height: slider.trackHeight
                anchors.verticalCenter: parent.verticalCenter
                topLeftRadius: slider.mirrored || slider.centerMinimum ? slider.insideCorner : height / 2
                bottomLeftRadius: topLeftRadius
                topRightRadius: slider.mirrored && !slider.centerMinimum ? height / 2 : slider.insideCorner
                bottomRightRadius: topRightRadius
                color: slider.enabled ? Style.primary : Style.onSurface_38
                visible: width > 0
            }

            Base.StyledRect {
                id: inactiveTrack
                x: sliderTrack.emptyStart
                width: Math.max(0, sliderTrack.emptyEnd - sliderTrack.emptyStart)
                height: slider.trackHeight
                anchors.verticalCenter: parent.verticalCenter
                topLeftRadius: slider.mirrored ? height / 2 : slider.insideCorner
                bottomLeftRadius: topLeftRadius
                topRightRadius: slider.mirrored ? slider.insideCorner : height / 2
                bottomRightRadius: topRightRadius
                color: slider.enabled ? Style.withAlpha(slider.trackColor, slider.trackOpacity) : Style.onSurface_12
                visible: width > 0

                Base.StyledRect {
                    width: Style.sliderStopSize
                    height: Style.sliderStopSize
                    radius: width / 2
                    x: slider.mirrored ? Style.sliderHandleGap : parent.width - Style.sliderHandleGap - width
                    anchors.verticalCenter: parent.verticalCenter
                    color: slider.enabled ? Style.primary : Style.onSurface_38
                    visible: parent.width > Style.sliderHandleGap * 2 + width
                }
            }

            Repeater {
                model: slider.tickCount

                Base.StyledRect {
                    required property int index
                    readonly property real tickX: Style.sliderHandleGap + (sliderTrack.width - Style.sliderHandleGap * 2) * index / Math.max(1, slider.tickCount - 1)
                    readonly property bool onFilled: slider.mirrored ? tickX > sliderHandle.x + sliderHandle.width : tickX < sliderHandle.x
                    width: Style.sliderTickSize
                    height: width
                    radius: width / 2
                    x: tickX - width / 2
                    anchors.verticalCenter: parent.verticalCenter
                    color: onFilled ? Style.onPrimary : Style.onSurfaceVariant
                    visible: index !== 0 && index !== slider.tickCount - 1 && Math.abs(tickX - sliderHandle.x - sliderHandle.width / 2) > Style.sliderHandleGap * 2
                }
            }

            Base.StyledRect {
                id: sliderHandle

                width: sliderMouseArea.pressed ? Style.sliderHandleWidth / 2 : Style.sliderHandleWidth
                height: slider.handleHeight
                radius: width / 2
                x: sliderTrack.handleLeft
                anchors.verticalCenter: parent.verticalCenter
                color: slider.enabled ? Style.primary : Style.onSurface_38
                border.width: 0
                border.color: slider.thumbOutlineColor

                Behavior on width {
                    enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
                    DankAnim {
                        duration: Style.expressiveDurations.expressiveEffects
                        easing.bezierCurve: Style.expressiveCurves.standard
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -Style.focusRingOffset
                    radius: parent.radius + Style.focusRingOffset
                    color: "transparent"
                    border.width: Style.focusRingWidth
                    border.color: Style.focusRingColor
                    visible: slider.activeFocus
                }
            }

            MouseArea {
                id: sliderMouseArea

                property bool isDragging: false

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                enabled: slider.enabled
                preventStealing: true
                acceptedButtons: Qt.LeftButton
                onWheel: wheelEvent => {
                    if (!slider.wheelEnabled) {
                        wheelEvent.accepted = false;
                        return;
                    }
                    slider.stepBy(wheelEvent.angleDelta.y > 0 ? 1 : -1);
                    wheelEvent.accepted = true;
                }
                onPressed: mouse => {
                    if (!slider.enabled)
                        return;
                    slider.forceActiveFocus();
                    slider.isDragging = true;
                    sliderMouseArea.isDragging = true;
                    updateValueFromPosition(mouse.x);
                }
                onReleased: {
                    if (!slider.enabled)
                        return;
                    slider.isDragging = false;
                    sliderMouseArea.isDragging = false;
                    slider.sliderDragFinished(slider.value);
                }
                onPositionChanged: mouse => {
                    if (pressed && slider.isDragging && slider.enabled)
                        updateValueFromPosition(mouse.x);
                }
                onClicked: mouse => {
                    if (slider.enabled && !slider.isDragging)
                        updateValueFromPosition(mouse.x);
                }
            }

            Base.StyledRect {
                id: valueTooltip

                width: tooltipText.reservedWidth + Style.spacingM * 2
                height: tooltipText.contentHeight + Style.spacingS * 2
                radius: height / 2
                color: Style.primary
                anchors.bottom: parent.top
                anchors.bottomMargin: -Style.spacingXS
                x: Math.max(0, Math.min(parent.width - width, sliderHandle.x + sliderHandle.width / 2 - width / 2))
                visible: opacity > 0
                opacity: slider.alwaysShowValue ? (slider.showValue ? 1 : 0) : (((sliderMouseArea.containsMouse && slider.showValue) || (slider.isDragging && slider.showValue)) ? 1 : 0)
                scale: opacity > 0 ? 1 : Style.popupEnterScale

                Base.NumericText {
                    id: tooltipText

                    text: slider.formatValue(slider.valueOverride >= 0 ? slider.valueOverride : slider.value)
                    reserveText: {
                        let widest = "";
                        const samples = [slider.minimum, slider.maximum];
                        if (slider.valueOverride >= 0)
                            samples.push(slider.valueOverride);
                        for (let i = 0; i < samples.length; i++) {
                            const candidate = slider.formatValue(samples[i]);
                            if (candidate.length > widest.length)
                                widest = candidate;
                        }
                        return widest;
                    }
                    font.pixelSize: Style.fontSizeSmall
                    color: Style.onPrimary
                    font.weight: Font.Medium
                    anchors.centerIn: parent
                    font.hintingPreference: Font.PreferFullHinting
                }

                Behavior on opacity {
                    enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
                    DankAnim {
                        duration: Style.expressiveDurations.expressiveEffects
                        easing.bezierCurve: Style.expressiveCurves.expressiveEffects
                    }
                }

                Behavior on scale {
                    enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
                    DankAnim {
                        duration: Style.expressiveDurations.expressiveFastSpatial
                        easing.bezierCurve: Style.expressiveCurves.expressiveFastSpatial
                    }
                }
            }
        }

        Base.DankIcon {
            name: slider.rightIcon
            size: Style.iconSize
            color: slider.enabled ? Style.surfaceText : Style.onSurface_38
            anchors.verticalCenter: parent.verticalCenter
            visible: slider.rightIcon.length > 0
        }
    }
}
