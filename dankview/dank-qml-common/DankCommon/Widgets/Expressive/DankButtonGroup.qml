import QtQuick
import QtQuick.Window
import Quickshell
import qs.DankCommon.Common
import qs.DankCommon.Widgets as Base

Row {
    id: root

    function checkParentDisablesTransparency() {
        let p = parent;
        while (p) {
            if (p.disablePopupTransparency === true)
                return true;
            p = p.parent;
        }
        return false;
    }

    property var model: []
    property int currentIndex: -1
    property string selectionMode: "single"
    property bool multiSelect: selectionMode === "multi"
    property var initialSelection: []
    property var currentSelection: initialSelection
    property bool checkEnabled: true
    property string size: "medium"
    property int buttonHeight: size === "small" ? Style.buttonHeightXS : Style.buttonHeightS
    property bool compactLayout: root.Window.window ? root.Window.window.width < Style.smallBreakpoint : false
    property int minButtonWidth: size === "small" ? (compactLayout ? 40 : 56) : (compactLayout ? 44 : 64)
    property int buttonPadding: (size === "small" || compactLayout) ? Style.spacingM : Style.spacingL
    property int checkIconSize: Style.iconSizeSmall
    property int textSize: size === "small" ? Style.fontSizeSmall : Style.fontSizeMedium
    property bool userInteracted: false
    property bool usePopupTransparency: !checkParentDisablesTransparency()
    property real maximumWidth: -1
    readonly property real _segmentCap: {
        const count = model?.length ?? 0;
        if (maximumWidth <= 0 || count === 0)
            return -1;
        return (maximumWidth - spacing * (count - 1)) / count - Style.spacingXS;
    }
    readonly property real outerRadius: buttonHeight / 2
    readonly property real innerRadius: Math.min(Style.cornerRadiusS, outerRadius)
    readonly property real pressedInnerRadius: Math.min(Style.cornerRadiusXS, outerRadius)

    signal selectionChanged(int index, bool selected)
    signal animationCompleted

    spacing: Style.groupedListGap
    activeFocusOnTab: enabled
    LayoutMirroring.enabled: I18n.isRtl
    LayoutMirroring.childrenInherit: true

    Timer {
        id: animationTimer
        interval: Style.shortDuration
        onTriggered: {
            root.userInteracted = false;
            root.animationCompleted();
        }
    }

    readonly property int focusIndex: currentIndex >= 0 ? currentIndex : 0

    Keys.onPressed: event => {
        if (!enabled || (model?.length ?? 0) === 0)
            return;
        const count = model.length;
        const forwardKey = I18n.isRtl ? Qt.Key_Left : Qt.Key_Right;
        const backwardKey = I18n.isRtl ? Qt.Key_Right : Qt.Key_Left;
        switch (event.key) {
        case Qt.Key_Space:
        case Qt.Key_Return:
        case Qt.Key_Enter:
            selectItem(focusIndex);
            event.accepted = true;
            return;
        }
        if (event.key === forwardKey) {
            selectItem((focusIndex + 1) % count);
            event.accepted = true;
            return;
        }
        if (event.key === backwardKey) {
            selectItem((focusIndex - 1 + count) % count);
            event.accepted = true;
        }
    }

    function isSelected(index) {
        if (multiSelect) {
            return repeater.itemAt(index)?.selected || false;
        }
        return index === currentIndex;
    }

    function selectItem(index) {
        userInteracted = true;
        if (multiSelect) {
            const modelValue = model[index];
            let newSelection = [...currentSelection];
            const isCurrentlySelected = newSelection.includes(modelValue);

            if (isCurrentlySelected) {
                newSelection = newSelection.filter(item => item !== modelValue);
            } else {
                newSelection.push(modelValue);
            }

            currentSelection = newSelection;
            selectionChanged(index, !isCurrentlySelected);
            animationTimer.restart();
        } else {
            const oldIndex = currentIndex;
            selectionChanged(index, true);
            if (oldIndex !== index && oldIndex >= 0) {
                selectionChanged(oldIndex, false);
            }
            animationTimer.restart();
        }
    }

    Repeater {
        id: repeater
        model: ScriptModel {
            values: root.model
        }

        delegate: Rectangle {
            id: segment

            Accessible.role: root.multiSelect ? Accessible.CheckBox : Accessible.RadioButton
            Accessible.name: buttonText.text
            Accessible.checkable: true
            Accessible.checked: selected
            Accessible.onPressAction: {
                if (root.enabled)
                    root.selectItem(index);
            }
            Accessible.onToggleAction: {
                if (root.enabled)
                    root.selectItem(index);
            }

            property bool selected: multiSelect ? root.currentSelection.includes(modelData) : (index === root.currentIndex)
            property bool hovered: mouseArea.containsMouse
            property bool pressed: mouseArea.pressed
            property bool visualFirst: index === 0
            property bool visualLast: index === repeater.count - 1
            property bool prevSelected: index > 0 ? root.isSelected(index - 1) : false
            property bool nextSelected: index < repeater.count - 1 ? root.isSelected(index + 1) : false
            readonly property real leftRadius: (visualFirst || selected) ? root.outerRadius : (pressed ? root.pressedInnerRadius : root.innerRadius)
            readonly property real rightRadius: (visualLast || selected) ? root.outerRadius : (pressed ? root.pressedInnerRadius : root.innerRadius)
            readonly property color contentColor: !root.enabled ? Style.onSurface_38 : (selected ? Style.buttonText : Style.onSecondaryContainer)

            readonly property real contentNaturalWidth: (checkIcon.visible ? checkIcon.width + contentRow.spacing : 0) + buttonText.implicitWidth

            readonly property real baseWidth: {
                const natural = Math.max(contentNaturalWidth + root.buttonPadding * 2, root.minButtonWidth);
                return root._segmentCap > 0 ? Math.min(natural, Math.max(root._segmentCap, root.minButtonWidth)) : natural;
            }
            readonly property real expansion: baseWidth * Style.buttonGroupExpandRatio
            readonly property bool prevPressed: index > 0 ? (repeater.itemAt(index - 1)?.pressed ?? false) : false
            readonly property bool nextPressed: index < repeater.count - 1 ? (repeater.itemAt(index + 1)?.pressed ?? false) : false
            readonly property int pressedNeighbours: (prevPressed ? 1 : 0) + (nextPressed ? 1 : 0)
            readonly property int neighbourCount: (index > 0 ? 1 : 0) + (index < repeater.count - 1 ? 1 : 0)

            width: {
                if (pressed)
                    return baseWidth + expansion;
                if (pressedNeighbours === 0)
                    return baseWidth;
                const neighbour = prevPressed ? repeater.itemAt(index - 1) : repeater.itemAt(index + 1);
                const share = neighbour?.neighbourCount > 0 ? neighbour.expansion / neighbour.neighbourCount : 0;
                return Math.max(root.minButtonWidth * Style.buttonGroupExpandRatio, baseWidth - share * pressedNeighbours);
            }
            height: root.buttonHeight

            color: !root.enabled ? Style.onSurface_12 : (selected ? Style.buttonBg : (root.usePopupTransparency ? Style.withAlpha(Style.secondaryContainer, Style.popupTransparency) : Style.secondaryContainer))
            border.color: "transparent"
            border.width: 0

            topLeftRadius: leftRadius
            bottomLeftRadius: leftRadius
            topRightRadius: rightRadius
            bottomRightRadius: rightRadius

            Behavior on width {
                enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
                DankAnim {
                    duration: Style.expressiveDurations.expressiveFastSpatial
                    easing.bezierCurve: Style.expressiveCurves.expressiveFastSpatial
                }
            }

            Behavior on topLeftRadius {
                enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
                DankAnim {
                    duration: Style.expressiveDurations.expressiveFastSpatial
                    easing.bezierCurve: Style.expressiveCurves.standard
                }
            }

            Behavior on topRightRadius {
                enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
                DankAnim {
                    duration: Style.expressiveDurations.expressiveFastSpatial
                    easing.bezierCurve: Style.expressiveCurves.standard
                }
            }

            Behavior on bottomLeftRadius {
                enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
                DankAnim {
                    duration: Style.expressiveDurations.expressiveFastSpatial
                    easing.bezierCurve: Style.expressiveCurves.standard
                }
            }

            Behavior on bottomRightRadius {
                enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
                DankAnim {
                    duration: Style.expressiveDurations.expressiveFastSpatial
                    easing.bezierCurve: Style.expressiveCurves.standard
                }
            }

            Behavior on color {
                enabled: root.userInteracted && Style.currentAnimationSpeed !== Style.AnimationSpeed.None
                DankColorAnim {
                    duration: Style.expressiveDurations.expressiveEffects
                    easing.bezierCurve: Style.expressiveCurves.expressiveEffects
                }
            }

            Rectangle {
                id: stateLayer
                anchors.fill: parent
                topLeftRadius: parent.topLeftRadius
                bottomLeftRadius: parent.bottomLeftRadius
                topRightRadius: parent.topRightRadius
                bottomRightRadius: parent.bottomRightRadius
                color: {
                    if (pressed)
                        return Style.withAlpha(segment.contentColor, Style.stateLayerPressed);
                    if (hovered)
                        return Style.withAlpha(segment.contentColor, Style.stateLayerHover);
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
                id: segmentRipple
                cornerRadius: root.outerRadius
                rippleColor: segment.contentColor
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: -Style.focusRingOffset
                radius: root.outerRadius + Style.focusRingOffset
                color: "transparent"
                border.width: Style.focusRingWidth
                border.color: Style.focusRingColor
                visible: root.activeFocus && index === root.focusIndex
            }

            Item {
                id: contentItem
                anchors.centerIn: parent
                implicitWidth: contentRow.implicitWidth
                implicitHeight: contentRow.implicitHeight

                Row {
                    id: contentRow
                    spacing: Style.spacingS

                    Base.DankIcon {
                        id: checkIcon
                        name: "check"
                        size: root.checkIconSize
                        color: segment.contentColor
                        visible: root.checkEnabled && segment.selected
                        opacity: segment.selected ? 1 : 0
                        scale: segment.selected ? 1 : Style.iconEnterScale
                        anchors.verticalCenter: parent.verticalCenter

                        Behavior on opacity {
                            enabled: root.userInteracted && Style.currentAnimationSpeed !== Style.AnimationSpeed.None
                            DankAnim {
                                duration: Style.expressiveDurations.expressiveEffects
                                easing.bezierCurve: Style.expressiveCurves.expressiveEffects
                            }
                        }

                        Behavior on scale {
                            enabled: root.userInteracted && Style.currentAnimationSpeed !== Style.AnimationSpeed.None
                            DankAnim {
                                duration: Style.expressiveDurations.expressiveFastSpatial
                                easing.bezierCurve: Style.expressiveCurves.expressiveFastSpatial
                            }
                        }
                    }

                    Base.StyledText {
                        id: buttonText

                        readonly property real capAvailable: {
                            if (root._segmentCap <= 0)
                                return -1;
                            const cap = Math.max(root._segmentCap, root.minButtonWidth);
                            return Math.max(0, cap - root.buttonPadding * 2 - (checkIcon.visible ? checkIcon.width + contentRow.spacing : 0));
                        }

                        text: typeof modelData === "string" ? modelData : modelData.text || ""
                        font.pixelSize: root.textSize
                        font.weight: segment.selected ? Font.Medium : Font.Normal
                        color: segment.contentColor
                        anchors.verticalCenter: parent.verticalCenter
                        width: capAvailable < 0 ? implicitWidth : Math.min(implicitWidth, capAvailable)
                        maximumLineCount: 1
                    }
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                enabled: root.enabled
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onPressed: mouse => segmentRipple.trigger(mouse.x, mouse.y)
                onClicked: root.selectItem(index)
            }
        }
    }
}
