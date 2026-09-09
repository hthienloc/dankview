import QtQuick
import QtQuick.Layouts
import qs.DankCommon.Common
import qs.DankCommon.Widgets as Base

ColumnLayout {
    id: root

    required property string title
    property string description: ""
    property bool expanded: false
    property bool showBackground: false
    property alias headerColor: headerRect.color

    function toggle() {
        if (!enabled)
            return;
        toggleRequested();
        expanded = !expanded;
    }

    signal toggleRequested

    spacing: Style.groupedListGap
    Layout.fillWidth: true

    Rectangle {
        id: headerRect
        activeFocusOnTab: root.enabled
        Accessible.role: Accessible.Button
        Accessible.name: root.title
        Accessible.description: root.description
        Accessible.onPressAction: root.toggle()

        Keys.onPressed: event => {
            switch (event.key) {
            case Qt.Key_Space:
            case Qt.Key_Return:
            case Qt.Key_Enter:
                root.toggle();
                event.accepted = true;
                break;
            }
        }

        Base.FocusRing {
            radius: Style.groupedListOuterRadius + Style.focusRingOffset
        }
        Layout.fillWidth: true
        Layout.preferredHeight: Math.max(titleRow.implicitHeight + Style.spacingM * 2, Style.listItemHeight)
        topLeftRadius: Style.groupedListOuterRadius
        topRightRadius: Style.groupedListOuterRadius
        bottomLeftRadius: root.expanded ? Style.groupedListInnerRadius : Style.groupedListOuterRadius
        bottomRightRadius: root.expanded ? Style.groupedListInnerRadius : Style.groupedListOuterRadius
        color: Style.surfaceContainerLow

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

        RowLayout {
            id: titleRow
            anchors.fill: parent
            anchors.leftMargin: Style.spacingL
            anchors.rightMargin: Style.spacingL
            spacing: Style.spacingM

            Base.StyledText {
                text: root.title
                font.pixelSize: Style.fontSizeMedium
                font.weight: Font.Medium
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }

            Base.DankIcon {
                name: "expand_more"
                size: Style.iconSize
                color: Style.onSurfaceVariant
                rotation: root.expanded ? 180 : 0

                Behavior on rotation {
                    enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
                    DankAnim {
                        duration: Style.expressiveDurations.expressiveFastSpatial
                        easing.bezierCurve: Style.expressiveCurves.expressiveDefaultSpatial
                    }
                }
            }
        }

        Base.StateLayer {
            anchors.fill: parent
            cornerRadius: Style.groupedListOuterRadius
            disabled: !root.enabled
            onClicked: root.toggle()
        }
    }

    default property alias content: contentColumn.data

    Item {
        id: contentWrapper
        visible: root.expanded || height > 0
        enabled: root.expanded
        Layout.fillWidth: true
        Layout.preferredHeight: root.expanded ? (contentColumn.implicitHeight + Style.spacingM * 2) : 0
        clip: true

        Behavior on Layout.preferredHeight {
            enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
            DankAnim {
                duration: Style.expressiveDurations.expressiveDefaultSpatial
                easing.bezierCurve: Style.expressiveCurves.standard
            }
        }

        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            topLeftRadius: Style.groupedListInnerRadius
            topRightRadius: Style.groupedListInnerRadius
            bottomLeftRadius: Style.groupedListOuterRadius
            bottomRightRadius: Style.groupedListOuterRadius
            color: Style.surfaceContainerLow
            opacity: root.showBackground && root.expanded ? 1.0 : 0.0
            visible: root.showBackground

            Behavior on opacity {
                enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
                DankAnim {
                    duration: Style.expressiveDurations.expressiveEffects
                    easing.bezierCurve: Style.expressiveCurves.expressiveEffects
                }
            }
        }

        ColumnLayout {
            id: contentColumn
            anchors.left: parent.left
            anchors.right: parent.right
            y: Style.spacingM
            anchors.leftMargin: Style.spacingL
            anchors.rightMargin: Style.spacingL
            spacing: Style.spacingS
            opacity: root.expanded ? 1.0 : 0.0

            Behavior on opacity {
                enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
                DankAnim {
                    duration: Style.expressiveDurations.expressiveEffects
                    easing.bezierCurve: Style.expressiveCurves.expressiveEffects
                }
            }

            Base.StyledText {
                id: descriptionText
                Layout.fillWidth: true
                Layout.topMargin: root.description !== "" ? Style.spacingXS : 0
                Layout.bottomMargin: root.description !== "" ? Style.spacingS : 0
                visible: root.description !== ""
                text: root.description
                color: Style.onSurfaceVariant
                font.pixelSize: Style.fontSizeSmall
                wrapMode: Text.Wrap
            }
        }
    }
}
