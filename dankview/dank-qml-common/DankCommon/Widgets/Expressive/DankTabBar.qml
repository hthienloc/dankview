import QtQuick
import "../../Common/TabNavigation.js" as TabNavigation
import qs.DankCommon.Common
import qs.DankCommon.Widgets as Base

FocusScope {
    id: tabBar

    property alias model: tabRepeater.model
    property int currentIndex: 0
    property int spacing: Style.spacingL
    property int tabHeight: Style.buttonHeightM
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
                Accessible.role: isAction ? Accessible.Button : Accessible.PageTab
                Accessible.name: modelData?.text ?? ""
                Accessible.selected: isActive
                Accessible.onPressAction: {
                    if (!tabBar.enabled)
                        return;
                    if (isAction) {
                        tabBar.actionTriggered(index);
                        return;
                    }
                    tabBar.tabClicked(index);
                }
                readonly property real contentWidth: contentCol.implicitWidth

                width: tabBar.equalWidthTabs ? (tabBar.width - tabBar.spacing * Math.max(0, tabRepeater.count - 1)) / Math.max(1, tabRepeater.count) : Math.max(contentCol.implicitWidth + Style.spacingXL, Style.tabMinWidth)
                height: tabBar.tabHeight

                Column {
                    id: contentCol
                    onImplicitWidthChanged: Qt.callLater(tabBar.updateIndicator)
                    anchors.centerIn: parent
                    spacing: Style.spacingXS

                    Base.DankIcon {
                        name: modelData.icon || ""
                        anchors.horizontalCenter: parent.horizontalCenter
                        size: Style.iconSize
                        color: tabItem.isActive ? Style.primary : Style.onSurfaceVariant
                        filled: tabItem.isActive
                        visible: hasIcon

                        Behavior on color {
                            enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
                            DankColorAnim {
                                duration: Style.expressiveDurations.expressiveEffects
                                easing.bezierCurve: Style.expressiveCurves.expressiveEffects
                            }
                        }
                    }

                    Base.StyledText {
                        text: modelData.text || ""
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Style.fontSizeMedium
                        color: tabItem.isActive ? Style.primary : Style.onSurfaceVariant
                        font.weight: Font.Medium
                        visible: hasText

                        Behavior on color {
                            enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
                            DankColorAnim {
                                duration: Style.expressiveDurations.expressiveEffects
                                easing.bezierCurve: Style.expressiveCurves.expressiveEffects
                            }
                        }
                    }
                }

                Rectangle {
                    id: stateLayer
                    anchors.fill: parent
                    color: Style.primary
                    opacity: tabArea.pressed ? Style.stateLayerPressed : (tabArea.containsMouse ? Style.stateLayerHover : 0)
                    visible: opacity > 0
                    radius: Style.cornerRadiusM
                    Behavior on opacity {
                        enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
                        DankAnim {
                            duration: Style.expressiveDurations.expressiveEffects
                            easing.bezierCurve: Style.expressiveCurves.expressiveEffects
                        }
                    }
                }

                Base.DankRipple {
                    id: tabRipple
                    cornerRadius: Style.cornerRadiusM
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -Style.focusRingOffset
                    radius: Style.cornerRadiusM + Style.focusRingOffset
                    color: "transparent"
                    border.width: Style.focusRingWidth
                    border.color: Style.focusRingColor
                    visible: tabBar.activeFocus && tabItem.isActive
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

        property bool animationEnabled: false
        property bool initialSetupComplete: false
        property bool movingRight: true
        property real leftX: 0
        property real rightX: 0

        y: parent.height + Style.spacingS
        height: Style.tabIndicatorHeight
        x: leftX
        width: Math.max(0, rightX - leftX)
        radius: height / 2
        color: Style.primary
        visible: false

        Behavior on leftX {
            enabled: indicator.animationEnabled && Style.currentAnimationSpeed !== Style.AnimationSpeed.None
            DankAnim {
                duration: indicator.movingRight ? Style.expressiveDurations.expressiveDefaultSpatial : Style.expressiveDurations.expressiveFastSpatial
                easing.bezierCurve: indicator.movingRight ? Style.expressiveCurves.standard : Style.expressiveCurves.expressiveDefaultSpatial
            }
        }

        Behavior on rightX {
            enabled: indicator.animationEnabled && Style.currentAnimationSpeed !== Style.AnimationSpeed.None
            DankAnim {
                duration: indicator.movingRight ? Style.expressiveDurations.expressiveFastSpatial : Style.expressiveDurations.expressiveDefaultSpatial
                easing.bezierCurve: indicator.movingRight ? Style.expressiveCurves.expressiveDefaultSpatial : Style.expressiveCurves.standard
            }
        }
    }

    Rectangle {
        width: parent.width
        height: Style.dividerWidth
        y: parent.height + Style.spacingS + Style.tabIndicatorHeight
        color: Style.outlineVariant
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
        const indicatorWidth = Math.max(Style.spacingXL, Math.min(item.width, item.contentWidth + Style.spacingS * 2));
        const targetLeft = tabCenterX - indicatorWidth / 2;
        const targetRight = tabCenterX + indicatorWidth / 2;

        indicator.movingRight = targetLeft >= indicator.leftX;
        if (!indicator.initialSetupComplete) {
            indicator.animationEnabled = false;
            indicator.leftX = targetLeft;
            indicator.rightX = targetRight;
            indicator.visible = true;
            indicator.initialSetupComplete = true;
            indicator.animationEnabled = true;
            return;
        }
        indicator.leftX = targetLeft;
        indicator.rightX = targetRight;
        indicator.visible = true;
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
