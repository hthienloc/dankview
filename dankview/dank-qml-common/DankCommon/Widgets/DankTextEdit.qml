import QtQuick
import qs.DankCommon.Common
import qs.DankCommon.Widgets

StyledRect {
    id: root

    LayoutMirroring.enabled: I18n.isRtl
    LayoutMirroring.childrenInherit: true

    function checkParentDisablesTransparency() {
        let p = parent;
        while (p) {
            if (p.disablePopupTransparency === true)
                return true;
            p = p.parent;
        }
        return false;
    }

    property alias text: textEdit.text
    property alias cursorPosition: textEdit.cursorPosition
    property alias font: textEdit.font
    property alias textColor: textEdit.color
    property alias wrapMode: textEdit.wrapMode
    property alias readOnly: textEdit.readOnly
    property string placeholderText: ""
    property string leftIconName: ""
    property int leftIconSize: Style.iconSize
    property color leftIconColor: Style.surfaceVariantText
    property color leftIconFocusedColor: Style.primary
    property bool usePopupTransparency: !checkParentDisablesTransparency()
    property color backgroundColor: usePopupTransparency ? Style.popupFieldColor : Style.floatingWindowFieldColor
    property color focusedBorderColor: usePopupTransparency ? Style.popupFieldFocusedBorderColor : Style.floatingWindowFieldFocusedBorderColor
    property color normalBorderColor: usePopupTransparency ? Style.popupFieldBorderColor : Style.floatingWindowFieldBorderColor
    property color placeholderColor: Style.outlineButton
    property bool hidePlaceholderOnFocus: true
    property real borderWidth: 1
    property real focusedBorderWidth: 2
    property real cornerRadius: Style.cornerRadius
    property real topPadding: Style.spacingS
    property real bottomPadding: Style.spacingS
    property var keyForwardTargets: []

    readonly property bool placeholderVisible: textEdit.text.length === 0 && !textEdit.inputMethodComposing && (!hidePlaceholderOnFocus || !textEdit.activeFocus)

    signal textEdited
    signal editingFinished
    signal focusStateChanged(bool hasFocus)

    function getActiveFocus() {
        return textEdit.activeFocus;
    }
    function setFocus(value) {
        textEdit.focus = value;
    }
    function forceActiveFocus() {
        textEdit.forceActiveFocus();
    }
    function selectAll() {
        textEdit.selectAll();
    }
    function clear() {
        textEdit.clear();
    }
    function insertText(str) {
        textEdit.insert(textEdit.cursorPosition, str);
    }

    width: 200
    height: Math.round(Style.fontSizeMedium * 8)
    radius: cornerRadius
    color: backgroundColor
    border.color: textEdit.activeFocus ? focusedBorderColor : normalBorderColor
    border.width: textEdit.activeFocus ? focusedBorderWidth : borderWidth

    DankIcon {
        id: leftIcon

        anchors.left: parent.left
        anchors.leftMargin: Style.spacingM
        anchors.top: parent.top
        anchors.topMargin: Style.spacingM
        name: leftIconName
        size: leftIconSize
        color: textEdit.activeFocus ? leftIconFocusedColor : leftIconColor
        visible: leftIconName !== ""
    }

    DankFlickable {
        id: scroll

        function ensureCursorVisible() {
            if (height <= 0)
                return;
            const r = textEdit.cursorRectangle;
            if (r.y < contentY) {
                contentY = r.y;
                return;
            }
            if (r.y + r.height > contentY + height)
                contentY = r.y + r.height - height;
        }

        anchors.left: leftIcon.visible ? leftIcon.right : parent.left
        anchors.leftMargin: leftIcon.visible ? Style.spacingS : Style.spacingM
        anchors.right: parent.right
        anchors.rightMargin: Style.spacingM
        anchors.top: parent.top
        anchors.topMargin: root.topPadding
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.bottomPadding
        clip: true
        contentWidth: width
        contentHeight: textEdit.height

        TextEdit {
            id: textEdit

            width: scroll.width
            height: Math.max(scroll.height, contentHeight)
            font.pixelSize: Style.fontSizeMedium
            font.family: Style.fontFamily
            color: Style.surfaceText
            selectionColor: Style.primaryContainer
            selectedTextColor: Style.primary
            wrapMode: TextEdit.Wrap
            selectByMouse: true
            cursorDelegate: DankTextCursor {
                id: editCursor

                color: textEdit.color
                x: textEdit.cursorRectangle.x
                y: textEdit.cursorRectangle.y
                height: textEdit.cursorRectangle.height
                shown: textEdit.cursorVisible

                Connections {
                    target: textEdit

                    function onCursorPositionChanged() {
                        editCursor.resetBlink();
                    }

                    function onTextChanged() {
                        editCursor.resetBlink();
                    }
                }
            }
            onTextChanged: root.textEdited()
            onEditingFinished: root.editingFinished()
            onActiveFocusChanged: root.focusStateChanged(activeFocus)
            onCursorRectangleChanged: scroll.ensureCursorVisible()
            Keys.forwardTo: root.keyForwardTargets

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.IBeamCursor
                acceptedButtons: Qt.NoButton
            }
        }
    }

    StyledText {
        id: placeholderLabel

        anchors.fill: scroll
        text: root.placeholderText
        font: textEdit.font
        color: placeholderColor
        wrapMode: Text.WordWrap
        visible: root.placeholderVisible
    }

    Behavior on border.color {
        ColorAnimation {
            duration: Style.shortDuration
            easing.type: Style.standardEasing
        }
    }

    Behavior on border.width {
        NumberAnimation {
            duration: Style.shortDuration
            easing.type: Style.standardEasing
        }
    }
}
