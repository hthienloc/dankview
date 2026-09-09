import QtQuick
import qs.DankCommon.Common
import qs.DankCommon.Widgets as Base

Base.StyledRect {
    id: root

    LayoutMirroring.enabled: I18n.isRtl
    LayoutMirroring.childrenInherit: true

    KeyNavigation.tab: keyNavigationTab
    KeyNavigation.backtab: keyNavigationBacktab

    function checkParentDisablesTransparency() {
        let p = parent;
        while (p) {
            if (p.disablePopupTransparency === true)
                return true;
            p = p.parent;
        }
        return false;
    }

    property alias text: textInput.text
    property alias cursorPosition: textInput.cursorPosition
    property string placeholderText: ""
    property string labelText: ""
    property alias font: textInput.font
    property alias textColor: textInput.color
    property int echoMode: TextInput.Normal
    property alias validator: textInput.validator
    property alias maximumLength: textInput.maximumLength
    property string leftIconName: ""
    property int leftIconSize: Style.iconSize
    property color leftIconColor: Style.onSurfaceVariant
    property color leftIconFocusedColor: Style.primary
    property bool showClearButton: false
    property bool showPasswordToggle: false
    property real rightAccessoryWidth: 0
    property bool passwordVisible: false
    property bool usePopupTransparency: !checkParentDisablesTransparency()
    property color backgroundColor: usePopupTransparency ? Style.popupFieldColor : Style.floatingWindowFieldColor
    property color focusedBorderColor: Style.primary
    property color normalBorderColor: Style.outlineVariant
    property color placeholderColor: Style.onSurfaceVariant
    property bool hidePlaceholderOnFocus: true
    property real borderWidth: Style.outlineWidth
    property real focusedBorderWidth: Style.outlineWidthFocused
    property real cornerRadius: Style.cornerRadiusM

    readonly property real accessorySize: Style.buttonHeightXS
    readonly property real leftPadding: Style.spacingM + (leftIconName ? leftIconSize + Style.spacingM : 0)
    readonly property real rightPadding: {
        let p = Style.spacingS + rightAccessoryWidth;
        if (showPasswordToggle)
            p += accessorySize + Style.spacingXS;
        if (showClearButton && text.length > 0)
            p += accessorySize + Style.spacingXS;
        return p;
    }
    property real topPadding: Style.spacingS
    property real bottomPadding: Style.spacingS
    property bool ignoreLeftRightKeys: false
    property bool ignoreUpDownKeys: false
    property bool ignoreTabKeys: false
    property var keyForwardTargets: []
    property Item keyNavigationTab: null
    property Item keyNavigationBacktab: null

    signal textEdited
    signal editingFinished
    signal accepted
    signal focusStateChanged(bool hasFocus)

    function getActiveFocus() {
        return textInput.activeFocus;
    }
    function setFocus(value) {
        textInput.focus = value;
    }
    function forceActiveFocus() {
        textInput.forceActiveFocus();
    }
    function selectAll() {
        textInput.selectAll();
    }
    function clear() {
        textInput.clear();
    }
    function insertText(str) {
        textInput.insert(textInput.cursorPosition, str);
    }

    readonly property real labelBandHeight: Math.round(Style.fontSizeSmall * 1.4) + Style.spacingXS * 2
    readonly property bool placeholderVisible: textInput.text.length === 0 && !textInput.inputMethodComposing && (!hidePlaceholderOnFocus || !textInput.activeFocus)

    width: Style.fieldDefaultWidth
    height: labelText !== "" ? Style.fieldHeight + labelBandHeight : Style.fieldHeight
    radius: cornerRadius
    color: backgroundColor
    border.color: textInput.activeFocus ? focusedBorderColor : normalBorderColor
    border.width: textInput.activeFocus ? focusedBorderWidth : borderWidth

    Base.DankIcon {
        id: leftIcon

        anchors.left: parent.left
        anchors.leftMargin: Style.spacingM
        anchors.verticalCenter: textInput.verticalCenter
        name: leftIconName
        size: leftIconSize
        color: textInput.activeFocus ? leftIconFocusedColor : leftIconColor
        visible: leftIconName !== ""
    }

    Base.StyledText {
        id: fieldLabel

        anchors.left: textInput.left
        anchors.right: textInput.right
        anchors.top: parent.top
        anchors.topMargin: Style.spacingXS
        text: root.labelText
        visible: root.labelText !== ""
        font.pixelSize: Style.fontSizeSmall
        color: textInput.activeFocus ? Style.primary : Style.onSurfaceVariant
        elide: Text.ElideRight
    }

    TextInput {
        id: textInput

        anchors.left: leftIcon.visible ? leftIcon.right : parent.left
        anchors.leftMargin: Style.spacingM
        anchors.right: rightButtonsRow.left
        anchors.rightMargin: rightButtonsRow.visible ? Style.spacingS : Style.spacingM
        anchors.top: parent.top
        anchors.topMargin: root.labelText !== "" ? root.labelBandHeight : root.topPadding
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.bottomPadding
        font.pixelSize: Style.fontSizeMedium
        font.family: Style.fontFamily
        color: Style.surfaceText
        selectionColor: Style.primaryContainer
        selectedTextColor: Style.onPrimaryContainer
        horizontalAlignment: TextInput.AlignLeft
        verticalAlignment: TextInput.AlignVCenter
        selectByMouse: !root.ignoreLeftRightKeys
        echoMode: root.passwordVisible && root.echoMode === TextInput.Password ? TextInput.Normal : root.echoMode
        clip: true
        activeFocusOnTab: root.enabled
        Accessible.name: root.Accessible.name || root.labelText || root.placeholderText
        Accessible.description: root.Accessible.description
        cursorDelegate: Base.DankTextCursor {
            id: fieldCursor

            color: textInput.color
            x: textInput.cursorRectangle.x
            y: textInput.cursorRectangle.y
            height: textInput.cursorRectangle.height
            shown: textInput.cursorVisible

            Connections {
                target: textInput

                function onCursorPositionChanged() {
                    fieldCursor.resetBlink();
                }

                function onTextChanged() {
                    fieldCursor.resetBlink();
                }
            }
        }
        KeyNavigation.tab: root.keyNavigationTab
        KeyNavigation.backtab: root.keyNavigationBacktab
        onTextChanged: root.textEdited()
        onEditingFinished: root.editingFinished()
        onAccepted: root.accepted()
        onActiveFocusChanged: root.focusStateChanged(activeFocus)
        Keys.forwardTo: root.keyForwardTargets
        Keys.onLeftPressed: event => {
            event.accepted = root.ignoreLeftRightKeys;
        }
        Keys.onRightPressed: event => {
            event.accepted = root.ignoreLeftRightKeys;
        }
        Keys.onPressed: event => {
            if (root.ignoreTabKeys && (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab)) {
                event.accepted = false;
                for (var i = 0; i < root.keyForwardTargets.length; i++) {
                    if (root.keyForwardTargets[i])
                        root.keyForwardTargets[i].Keys.pressed(event);
                }
                return;
            }
            if (root.ignoreUpDownKeys && (event.key === Qt.Key_Up || event.key === Qt.Key_Down)) {
                event.accepted = false;
                for (var i = 0; i < root.keyForwardTargets.length; i++) {
                    if (root.keyForwardTargets[i])
                        root.keyForwardTargets[i].Keys.pressed(event);
                }
                return;
            }
            if ((event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier)) && root.keyForwardTargets.length > 0) {
                for (var i = 0; i < root.keyForwardTargets.length; i++) {
                    if (root.keyForwardTargets[i])
                        root.keyForwardTargets[i].Keys.pressed(event);
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.IBeamCursor
            acceptedButtons: Qt.NoButton
        }
    }

    Row {
        id: rightButtonsRow

        anchors.right: parent.right
        anchors.rightMargin: Style.spacingS + root.rightAccessoryWidth
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.spacingXS
        visible: showPasswordToggle || (showClearButton && text.length > 0)

        DankActionButton {
            buttonSize: root.accessorySize
            iconName: passwordVisible ? "visibility_off" : "visibility"
            iconSize: Style.iconSizeSmall
            iconColor: Style.onSurfaceVariant
            visible: showPasswordToggle
            onClicked: passwordVisible = !passwordVisible
        }

        DankActionButton {
            buttonSize: root.accessorySize
            iconName: "close"
            iconSize: Style.iconSizeSmall
            iconColor: Style.onSurfaceVariant
            visible: showClearButton && text.length > 0
            onClicked: textInput.text = ""
        }
    }

    Base.StyledText {
        id: placeholderLabel

        anchors.fill: textInput
        text: root.placeholderText
        font: textInput.font
        color: placeholderColor
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: textInput.verticalAlignment
        visible: root.placeholderVisible
        elide: I18n.isRtl ? Text.ElideLeft : Text.ElideRight
    }

    Behavior on border.color {
        enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
        DankColorAnim {
            duration: Style.expressiveDurations.expressiveEffects
            easing.bezierCurve: Style.expressiveCurves.expressiveEffects
        }
    }

    Behavior on border.width {
        enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
        DankAnim {
            duration: Style.expressiveDurations.expressiveEffects
            easing.bezierCurve: Style.expressiveCurves.expressiveEffects
        }
    }
}
