import QtQuick
import qs.DankCommon.Common
import qs.DankCommon.Widgets as Base

FocusScope {
    id: root

    property int hour: 7
    property int minute: 0
    property bool is24Hour: false
    property string title: I18n.tr("Select time")
    property real faceSize: Style.clockFaceSize

    signal accepted(int hour, int minute)
    signal rejected

    readonly property bool opened: _opened
    property bool _opened: false
    property int _hour: 7
    property int _minute: 0
    property bool _minuteMode: false
    property bool _dragging: false

    readonly property bool animationsEnabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
    readonly property real digitHeight: Style.iconButtonSize + Style.spacingXL
    readonly property real digitWidth: digitHeight + Style.spacingM
    readonly property real outerRingRadius: faceSize * Style.clockOuterRingRatio
    readonly property real innerRingRadius: faceSize * Style.clockInnerRingRatio
    readonly property real numberSize: Style.clockHandleSize
    readonly property bool isPm: _hour >= 12
    readonly property int displayHour: is24Hour ? _hour : ((_hour % 12) === 0 ? 12 : _hour % 12)
    readonly property real handAngle: _minuteMode ? _minute * 6 : (_hour % 12) * 30
    readonly property real handLength: (!_minuteMode && is24Hour && (_hour === 0 || _hour > 12)) ? innerRingRadius : outerRingRadius

    function pad(v) {
        return (v < 10 ? "0" : "") + v;
    }

    function open() {
        _hour = Math.max(0, Math.min(23, hour));
        _minute = Math.max(0, Math.min(59, minute));
        _minuteMode = false;
        _opened = true;
        forceActiveFocus();
    }

    function close() {
        _opened = false;
    }

    function setPeriod(pm) {
        const base = _hour % 12;
        _hour = pm ? base + 12 : base;
    }

    function selectHour(h) {
        _hour = h;
        advanceTimer.restart();
    }

    function selectMinute(m) {
        _minute = m;
    }

    function angleFromPoint(x, y) {
        const dx = x - faceSize / 2;
        const dy = y - faceSize / 2;
        return (Math.atan2(dy, dx) * 180 / Math.PI + 90 + 360) % 360;
    }

    function distanceFromCenter(x, y) {
        const dx = x - faceSize / 2;
        const dy = y - faceSize / 2;
        return Math.sqrt(dx * dx + dy * dy);
    }

    function applyPoint(x, y) {
        const angle = angleFromPoint(x, y);
        if (_minuteMode) {
            _minute = Math.round(angle / 30) * 5 % 60;
            return;
        }
        const step = Math.round(angle / 30) % 12;
        if (!is24Hour) {
            _hour = isPm ? (step === 0 ? 12 : step + 12) : (step === 0 ? 0 : step);
            return;
        }
        const inner = distanceFromCenter(x, y) < (outerRingRadius + innerRingRadius) / 2;
        _hour = inner ? (step === 0 ? 0 : step + 12) : (step === 0 ? 12 : step);
    }

    anchors.fill: parent
    visible: opacity > 0
    opacity: _opened ? 1 : 0
    z: 1000

    Behavior on opacity {
        enabled: root.animationsEnabled
        DankAnim {
            duration: Style.expressiveDurations.expressiveEffects
            easing.bezierCurve: Style.expressiveCurves.expressiveEffects
        }
    }

    Keys.onPressed: event => {
        switch (event.key) {
        case Qt.Key_Escape:
            root.rejected();
            root.close();
            break;
        case Qt.Key_Return:
        case Qt.Key_Enter:
            root.accepted(root._hour, root._minute);
            root.close();
            break;
        case Qt.Key_Tab:
        case Qt.Key_Backtab:
            root._minuteMode = !root._minuteMode;
            break;
        case Qt.Key_Up:
        case Qt.Key_Right:
            root.nudge(1);
            break;
        case Qt.Key_Down:
        case Qt.Key_Left:
            root.nudge(-1);
            break;
        case Qt.Key_A:
            root.setPeriod(false);
            break;
        case Qt.Key_P:
            root.setPeriod(true);
            break;
        default:
            return;
        }
        event.accepted = true;
    }

    function nudge(direction) {
        if (_minuteMode) {
            _minute = (_minute + direction * 5 + 60) % 60;
            return;
        }
        _hour = (_hour + direction + 24) % 24;
    }

    Timer {
        id: advanceTimer
        interval: Style.clockSwitchDelay
        onTriggered: root._minuteMode = true
    }

    Rectangle {
        anchors.fill: parent
        color: Style.withAlpha(Style.shadowStrong, Style.scrimAlpha)

        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.rejected();
                root.close();
            }
        }
    }

    Rectangle {
        id: card

        width: root.faceSize + Style.spacingXL * 2 + Style.spacingXL
        height: cardColumn.implicitHeight + Style.spacingXL * 2
        anchors.centerIn: parent
        radius: Style.cornerRadiusXL
        color: Style.surfaceContainerHigh
        scale: root._opened ? 1 : Style.popupEnterScale

        Behavior on scale {
            enabled: root.animationsEnabled
            DankAnim {
                duration: Style.expressiveDurations.expressiveDefaultSpatial
                easing.bezierCurve: Style.expressiveCurves.expressiveDefaultSpatial
            }
        }

        MouseArea {
            anchors.fill: parent
        }

        ElevationShadow {
            anchors.fill: parent
            z: -1
            level: Style.elevationLevel3
            fallbackOffset: Style.spacingS
            targetRadius: card.radius
            targetColor: card.color
            shadowEnabled: Style.elevationEnabled
        }

        Column {
            id: cardColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Style.spacingXL
            spacing: Style.spacingL

            Base.StyledText {
                text: root.title
                font.pixelSize: Style.fontSizeMedium
                font.weight: Font.Medium
                color: Style.onSurfaceVariant
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Style.spacingS

                Rectangle {
                    id: hourDigit
                    width: root.digitWidth
                    height: root.digitHeight
                    radius: Style.cornerRadiusM
                    color: root._minuteMode ? Style.surfaceContainerHighest : Style.primaryContainer
                    border.width: root._minuteMode ? 0 : Style.outlineWidthFocused
                    border.color: Style.primary

                    Behavior on color {
                        enabled: root.animationsEnabled
                        DankColorAnim {
                            duration: Style.expressiveDurations.expressiveEffects
                            easing.bezierCurve: Style.expressiveCurves.expressiveEffects
                        }
                    }

                    Base.NumericText {
                        anchors.centerIn: parent
                        text: root.pad(root.displayHour)
                        reserveText: "00"
                        font.pixelSize: Style.fontSizeDisplay
                        font.weight: Font.Medium
                        color: root._minuteMode ? Style.surfaceText : Style.onPrimaryContainer
                    }

                    Base.StateLayer {
                        stateColor: Style.primary
                        cornerRadius: parent.radius
                        onClicked: root._minuteMode = false
                    }
                }

                Base.StyledText {
                    text: ":"
                    font.pixelSize: Style.fontSizeDisplay
                    font.weight: Font.DemiBold
                    color: Style.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    id: minuteDigit
                    width: root.digitWidth
                    height: root.digitHeight
                    radius: Style.cornerRadiusM
                    color: root._minuteMode ? Style.primaryContainer : Style.surfaceContainerHighest
                    border.width: root._minuteMode ? Style.outlineWidthFocused : 0
                    border.color: Style.primary

                    Behavior on color {
                        enabled: root.animationsEnabled
                        DankColorAnim {
                            duration: Style.expressiveDurations.expressiveEffects
                            easing.bezierCurve: Style.expressiveCurves.expressiveEffects
                        }
                    }

                    Base.NumericText {
                        anchors.centerIn: parent
                        text: root.pad(root._minute)
                        reserveText: "00"
                        font.pixelSize: Style.fontSizeDisplay
                        font.weight: Font.Medium
                        color: root._minuteMode ? Style.onPrimaryContainer : Style.surfaceText
                    }

                    Base.StateLayer {
                        stateColor: Style.primary
                        cornerRadius: parent.radius
                        onClicked: root._minuteMode = true
                    }
                }

                Item {
                    width: Style.spacingXS
                    height: parent.height
                    visible: !root.is24Hour
                }

                Rectangle {
                    id: periodColumn
                    width: Style.iconButtonSize + Style.spacingXS
                    height: root.digitHeight
                    radius: Style.cornerRadiusS
                    color: "transparent"
                    border.width: Style.outlineWidth
                    border.color: Style.outlineVariant
                    visible: !root.is24Hour
                    clip: true

                    Column {
                        anchors.fill: parent

                        Rectangle {
                            width: parent.width
                            height: parent.height / 2
                            topLeftRadius: periodColumn.radius
                            topRightRadius: periodColumn.radius
                            color: root.isPm ? "transparent" : Style.primaryContainer

                            Base.StyledText {
                                anchors.centerIn: parent
                                text: I18n.tr("AM")
                                font.pixelSize: Style.fontSizeSmall
                                font.weight: Font.DemiBold
                                color: root.isPm ? Style.onSurfaceVariant : Style.onPrimaryContainer
                            }

                            Base.StateLayer {
                                cornerRadius: 0
                                onClicked: root.setPeriod(false)
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: Style.dividerWidth
                            color: Style.outlineVariant
                        }

                        Rectangle {
                            width: parent.width
                            height: parent.height / 2 - Style.dividerWidth
                            bottomLeftRadius: periodColumn.radius
                            bottomRightRadius: periodColumn.radius
                            color: root.isPm ? Style.primaryContainer : "transparent"

                            Base.StyledText {
                                anchors.centerIn: parent
                                text: I18n.tr("PM")
                                font.pixelSize: Style.fontSizeSmall
                                font.weight: Font.DemiBold
                                color: root.isPm ? Style.onPrimaryContainer : Style.onSurfaceVariant
                            }

                            Base.StateLayer {
                                cornerRadius: 0
                                onClicked: root.setPeriod(true)
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: face

                width: root.faceSize
                height: root.faceSize
                anchors.horizontalCenter: parent.horizontalCenter
                radius: width / 2
                color: faceArea.containsMouse ? Style.surfaceContainerHigh : Style.surfaceContainerHighest
                border.width: Style.outlineWidth
                border.color: Style.outlineVariant

                Behavior on color {
                    enabled: root.animationsEnabled
                    DankColorAnim {
                        duration: Style.expressiveDurations.expressiveEffects
                        easing.bezierCurve: Style.expressiveCurves.expressiveEffects
                    }
                }

                Item {
                    id: hand
                    x: root.faceSize / 2 - 1
                    y: root.faceSize / 2
                    width: Style.clockHandWidth
                    height: root.handLength
                    transformOrigin: Item.Top
                    rotation: root.handAngle + 180

                    Behavior on rotation {
                        enabled: root.animationsEnabled && !root._dragging
                        RotationAnimation {
                            direction: RotationAnimation.Shortest
                            duration: Style.expressiveDurations.expressiveFastSpatial
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Style.expressiveCurves.expressiveDefaultSpatial
                        }
                    }

                    Behavior on height {
                        enabled: root.animationsEnabled && !root._dragging
                        DankAnim {
                            duration: Style.expressiveDurations.expressiveFastSpatial
                            easing.bezierCurve: Style.expressiveCurves.standard
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: Style.primary
                        radius: width / 2
                    }

                    Rectangle {
                        width: root.numberSize
                        height: root.numberSize
                        radius: width / 2
                        color: Style.primary
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.bottom
                    }
                }

                Rectangle {
                    width: Style.clockCenterSize
                    height: Style.clockCenterSize
                    radius: width / 2
                    anchors.centerIn: parent
                    color: Style.primary
                }

                Repeater {
                    model: root._minuteMode ? 12 : (root.is24Hour ? 24 : 12)

                    Item {
                        required property int index
                        readonly property bool innerRing: !root._minuteMode && root.is24Hour && index >= 12
                        readonly property int step: index % 12
                        readonly property int value: root._minuteMode ? step * 5 : (innerRing ? (step === 0 ? 0 : step + 12) : (step === 0 ? 12 : step))
                        readonly property bool selected: root._minuteMode ? (root._minute === value) : (root.is24Hour ? root._hour === value : (root._hour % 12) === (value % 12))
                        readonly property real ringRadius: innerRing ? root.innerRingRadius : root.outerRingRadius
                        readonly property real angle: (step * 30 - 90) * Math.PI / 180

                        width: root.numberSize
                        height: root.numberSize
                        x: root.faceSize / 2 + ringRadius * Math.cos(angle) - width / 2
                        y: root.faceSize / 2 + ringRadius * Math.sin(angle) - height / 2

                        Base.NumericText {
                            anchors.centerIn: parent
                            text: root._minuteMode || parent.innerRing ? root.pad(parent.value) : parent.value
                            reserveText: "00"
                            font.pixelSize: parent.innerRing ? Style.fontSizeSmall : Style.fontSizeMedium
                            font.weight: parent.selected ? Font.DemiBold : Font.Medium
                            color: parent.selected ? Style.onPrimary : Style.surfaceText
                        }
                    }
                }

                MouseArea {
                    id: faceArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPressed: mouse => {
                        root._dragging = true;
                        root.applyPoint(mouse.x, mouse.y);
                    }
                    onPositionChanged: mouse => {
                        if (!pressed)
                            return;
                        root.applyPoint(mouse.x, mouse.y);
                    }
                    onReleased: {
                        root._dragging = false;
                        if (root._minuteMode)
                            return;
                        advanceTimer.restart();
                    }
                }
            }

            Row {
                anchors.right: parent.right
                spacing: Style.spacingS

                DankButton {
                    text: I18n.tr("Cancel")
                    backgroundColor: "transparent"
                    textColor: Style.primary
                    onClicked: {
                        root.rejected();
                        root.close();
                    }
                }

                DankButton {
                    text: I18n.tr("OK")
                    backgroundColor: Style.primary
                    textColor: Style.onPrimary
                    onClicked: {
                        root.accepted(root._hour, root._minute);
                        root.close();
                    }
                }
            }
        }
    }
}
