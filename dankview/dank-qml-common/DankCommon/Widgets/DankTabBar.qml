import QtQuick
import "../Common/TabNavigation.js" as TabNavigation
import qs.DankCommon.Common
import qs.DankCommon.Widgets

FocusScope {
    id: tabBar

    property alias model: tabRepeater.model
    property int currentIndex: 0
    property int spacing: Style.spacingL
    property int tabHeight: 56
    property bool showIcons: true
    property bool equalWidthTabs: true
    property bool enableArrowNavigation: true
    property bool cycleOnTab: false
    property Item nextFocusTarget: null
    property Item previousFocusTarget: null

    signal tabClicked(int index)
    signal actionTriggered(int index)

    focus: false
    activeFocusOnTab: true
    height: tabHeight

    Keys.onPressed: event => {
        event.accepted = TabNavigation.handleKeyEvent(event, tabBar, tabRepeater, I18n.isRtl);
    }

    Row {
        id: tabRow
        anchors.fill: parent
        spacing: tabBar.spacing

        Repeater {
            id: tabRepeater

            onItemAdded: Qt.callLater(tabBar.updateIndicator)
            onItemRemoved: Qt.callLater(tabBar.updateIndicator)

            Item {
                id: tabItem
                property bool isAction: modelData && modelData.isAction === true
                property bool isActive: !isAction && tabBar.currentIndex === index
                property bool hasIcon: tabBar.showIcons && modelData && modelData.icon && modelData.icon.length > 0
                property bool hasText: modelData && modelData.text && modelData.text.length > 0

                width: tabBar.equalWidthTabs ? (tabBar.width - tabBar.spacing * Math.max(0, tabRepeater.count - 1)) / Math.max(1, tabRepeater.count) : Math.max(contentCol.implicitWidth + Style.spacingXL, 64)
                height: tabBar.tabHeight

                Column {
                    id: contentCol
                    onImplicitWidthChanged: Qt.callLater(tabBar.updateIndicator)
                    anchors.centerIn: parent
                    spacing: Style.spacingXS

                    DankIcon {
                        name: modelData.icon || ""
                        anchors.horizontalCenter: parent.horizontalCenter
                        size: Style.iconSize
                        color: tabItem.isActive ? Style.primary : Style.surfaceText
                        visible: hasIcon
                    }

                    StyledText {
                        text: modelData.text || ""
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Style.fontSizeMedium
                        color: tabItem.isActive ? Style.primary : Style.surfaceText
                        font.weight: Font.Medium
                        visible: hasText
                    }
                }

                Rectangle {
                    id: stateLayer
                    anchors.fill: parent
                    color: Style.surfaceTint
                    opacity: tabArea.pressed ? 0.12 : (tabArea.containsMouse ? 0.08 : 0)
                    visible: opacity > 0
                    radius: Style.cornerRadius
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Style.shortDuration
                            easing.type: Style.standardEasing
                        }
                    }
                }

                DankRipple {
                    id: tabRipple
                    cornerRadius: Style.cornerRadius
                }

                MouseArea {
                    id: tabArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPressed: mouse => tabRipple.trigger(mouse.x, mouse.y)
                    onClicked: {
                        if (tabItem.isAction) {
                            tabBar.actionTriggered(index);
                        } else {
                            tabBar.tabClicked(index);
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: indicator
        y: parent.height + 7
        height: 3
        width: 60
        topLeftRadius: Style.cornerRadius
        topRightRadius: Style.cornerRadius
        bottomLeftRadius: 0
        bottomRightRadius: 0
        color: Style.primary
        visible: false

        property bool animationEnabled: false
        property bool initialSetupComplete: false

        Behavior on x {
            enabled: indicator.animationEnabled
            NumberAnimation {
                duration: Style.mediumDuration
                easing.type: Style.standardEasing
            }
        }

        Behavior on width {
            enabled: indicator.animationEnabled
            NumberAnimation {
                duration: Style.mediumDuration
                easing.type: Style.standardEasing
            }
        }
    }

    Rectangle {
        width: parent.width
        height: 1
        y: parent.height + 10
        color: Style.outlineStrong
    }

    function updateIndicator() {
        if (tabRepeater.count === 0 || currentIndex < 0 || currentIndex >= tabRepeater.count) {
            indicator.visible = false;
            indicator.initialSetupComplete = false;
            return;
        }

        const item = tabRepeater.itemAt(currentIndex);
        if (!item || item.isAction) {
            return;
        }

        tabRow.forceLayout();
        const tabPos = item.mapToItem(tabBar, 0, 0);
        const tabCenterX = tabPos.x + item.width / 2;
        const indicatorWidth = 60;

        if (!indicator.initialSetupComplete) {
            indicator.animationEnabled = false;
            indicator.width = indicatorWidth;
            indicator.x = tabCenterX - indicatorWidth / 2;
            indicator.visible = true;
            indicator.initialSetupComplete = true;
            indicator.animationEnabled = true;
        } else {
            indicator.width = indicatorWidth;
            indicator.x = tabCenterX - indicatorWidth / 2;
            indicator.visible = true;
        }
    }

    function snapIndicator() {
        indicator.initialSetupComplete = false;
        updateIndicator();
    }

    onCurrentIndexChanged: {
        Qt.callLater(updateIndicator);
    }
    onWidthChanged: Qt.callLater(updateIndicator)
    onSpacingChanged: Qt.callLater(updateIndicator)
    onEqualWidthTabsChanged: Qt.callLater(updateIndicator)
    Component.onCompleted: Qt.callLater(updateIndicator)
}
