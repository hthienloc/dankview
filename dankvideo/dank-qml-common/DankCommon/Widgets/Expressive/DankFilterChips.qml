import QtQuick
import qs.DankCommon.Common
import qs.DankCommon.Widgets as Base

Flow {
    id: root

    property var model: []
    property int currentIndex: 0
    property bool multiSelect: false
    property var selectedValues: []
    property int chipHeight: Style.buttonHeightXS
    property int chipPadding: Style.spacingL
    property bool showCheck: true
    property bool showCounts: true

    signal selectionChanged(int index)
    signal selectionToggled(int index, bool selected)

    spacing: Style.spacingS
    width: parent ? parent.width : Style.smallBreakpoint
    activeFocusOnTab: enabled && !multiSelect

    Keys.onPressed: event => {
        const count = model?.length ?? 0;
        if (!enabled || count === 0 || multiSelect)
            return;
        const forwardKey = I18n.isRtl ? Qt.Key_Left : Qt.Key_Right;
        const backwardKey = I18n.isRtl ? Qt.Key_Right : Qt.Key_Left;
        let next = -1;
        if (event.key === forwardKey)
            next = (currentIndex + 1) % count;
        if (event.key === backwardKey)
            next = (currentIndex - 1 + count) % count;
        if (next < 0)
            return;
        currentIndex = next;
        selectionChanged(next);
        event.accepted = true;
    }

    Repeater {
        model: root.model

        Rectangle {
            id: chip
            required property var modelData
            required property int index

            property var value: typeof modelData === "string" ? modelData : (modelData.value !== undefined ? modelData.value : (modelData.label || ""))
            activeFocusOnTab: root.enabled && root.multiSelect
            Accessible.role: Accessible.CheckBox
            Accessible.name: label
            Accessible.checkable: true
            Accessible.checked: selected
            Accessible.onPressAction: activate()
            Accessible.onToggleAction: activate()

            function activate() {
                if (!root.enabled)
                    return;
                if (root.multiSelect) {
                    root.selectionToggled(index, !selected);
                    return;
                }
                root.currentIndex = index;
                root.selectionChanged(index);
            }

            Keys.onPressed: event => {
                switch (event.key) {
                case Qt.Key_Space:
                case Qt.Key_Return:
                case Qt.Key_Enter:
                    activate();
                    event.accepted = true;
                    break;
                }
            }

            property bool selected: root.multiSelect ? root.selectedValues.includes(value) : (index === root.currentIndex)
            property bool hovered: mouseArea.containsMouse
            property bool pressed: mouseArea.pressed
            property string label: typeof modelData === "string" ? modelData : (modelData.label || "")
            property int count: typeof modelData === "object" ? (modelData.count || 0) : 0
            property bool showCount: root.showCounts && count > 0
            readonly property color contentColor: selected ? Style.onSecondaryContainer : Style.onSurfaceVariant

            width: contentRow.implicitWidth + root.chipPadding * 2
            height: root.chipHeight
            radius: pressed ? Style.cornerRadiusS : (selected ? height / 2 : Style.cornerRadiusM)

            Behavior on radius {
                enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
                DankAnim {
                    duration: Style.expressiveDurations.expressiveFastSpatial
                    easing.bezierCurve: Style.expressiveCurves.standard
                }
            }

            color: selected ? Style.secondaryContainer : "transparent"
            border.width: selected ? 0 : Style.outlineWidth
            border.color: Style.outlineVariant

            Rectangle {
                anchors.fill: parent
                anchors.margins: -Style.focusRingOffset
                radius: chip.radius + Style.focusRingOffset
                color: "transparent"
                border.width: Style.focusRingWidth
                border.color: Style.focusRingColor
                visible: chip.activeFocus || (root.activeFocus && chip.selected) && !root.multiSelect
            }

            Behavior on color {
                enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
                DankColorAnim {
                    duration: Style.expressiveDurations.expressiveEffects
                    easing.bezierCurve: Style.expressiveCurves.expressiveEffects
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: {
                    if (pressed)
                        return Style.withAlpha(chip.contentColor, Style.stateLayerPressed);
                    if (hovered)
                        return Style.withAlpha(chip.contentColor, Style.stateLayerHover);
                    return "transparent";
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
                id: chipRipple
                cornerRadius: chip.radius
                rippleColor: chip.contentColor
            }

            Row {
                id: contentRow
                anchors.centerIn: parent
                spacing: Style.spacingXS

                Base.DankIcon {
                    name: "check"
                    size: Style.chipIconSize
                    anchors.verticalCenter: parent.verticalCenter
                    color: chip.contentColor
                    visible: root.showCheck && chip.selected
                }

                Base.StyledText {
                    text: chip.label + (chip.showCount ? " (" + chip.count + ")" : "")
                    font.pixelSize: Style.fontSizeSmall
                    font.weight: chip.selected ? Font.Medium : Font.Normal
                    color: chip.contentColor
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onPressed: mouse => chipRipple.trigger(mouse.x, mouse.y)
                onClicked: chip.activate()
            }
        }
    }
}
