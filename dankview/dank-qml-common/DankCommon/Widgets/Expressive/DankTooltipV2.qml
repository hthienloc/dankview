import QtQuick
import QtQuick.Controls
import qs.DankCommon.Common

Item {
    id: root

    property string text: ""

    function show(text, item, offsetX, offsetY, preferredSide) {
        if (!item)
            return;

        let windowContentItem = item.Window?.window?.contentItem;
        if (!windowContentItem) {
            let current = item;
            while (current) {
                if (current.Window?.window?.contentItem) {
                    windowContentItem = current.Window.window.contentItem;
                    break;
                }
                current = current.parent;
            }
        }
        if (!windowContentItem)
            return;

        tooltip.parent = windowContentItem;
        tooltip.text = text;

        const itemPos = item.mapToItem(windowContentItem, 0, 0);
        const parentWidth = windowContentItem.width;
        const parentHeight = windowContentItem.height;
        const tooltipWidth = tooltip.implicitWidth;
        const tooltipHeight = tooltip.implicitHeight;
        const gap = Style.spacingS;

        const side = preferredSide || _determineBestSide(itemPos, item, parentWidth, parentHeight, tooltipWidth, tooltipHeight);

        let targetX = 0;
        let targetY = 0;

        switch (side) {
        case "left":
            targetX = itemPos.x - tooltipWidth - gap;
            targetY = itemPos.y + (item.height - tooltipHeight) / 2;
            break;
        case "right":
            targetX = itemPos.x + item.width + gap;
            targetY = itemPos.y + (item.height - tooltipHeight) / 2;
            break;
        case "top":
            targetX = itemPos.x + (item.width - tooltipWidth) / 2;
            targetY = itemPos.y - tooltipHeight - gap;
            break;
        case "bottom":
        default:
            targetX = itemPos.x + (item.width - tooltipWidth) / 2;
            targetY = itemPos.y + item.height + gap;
            break;
        }

        tooltip.x = Math.max(Style.spacingXS, Math.min(parentWidth - tooltipWidth - Style.spacingXS, targetX + (offsetX || 0)));
        tooltip.y = Math.max(Style.spacingXS, Math.min(parentHeight - tooltipHeight - Style.spacingXS, targetY + (offsetY || 0)));

        tooltip.open();
    }

    function _determineBestSide(itemPos, item, parentWidth, parentHeight, tooltipWidth, tooltipHeight) {
        const itemCenterX = itemPos.x + item.width / 2;
        const margin = Style.spacingL;

        const spaceLeft = itemPos.x;
        const spaceRight = parentWidth - (itemPos.x + item.width);
        const spaceTop = itemPos.y;
        const spaceBottom = parentHeight - (itemPos.y + item.height);

        if (spaceRight >= tooltipWidth + margin)
            return "right";
        if (spaceLeft >= tooltipWidth + margin)
            return "left";
        if (spaceBottom >= tooltipHeight + margin)
            return "bottom";
        if (spaceTop >= tooltipHeight + margin)
            return "top";
        if (itemCenterX > parentWidth / 2)
            return "left";
        return "right";
    }

    function hide() {
        tooltip.close();
    }

    Popup {
        id: tooltip

        property string text: ""

        leftPadding: Style.spacingM
        rightPadding: Style.spacingM
        topPadding: Style.spacingS
        bottomPadding: Style.spacingS
        closePolicy: Popup.NoAutoClose
        modal: false
        dim: false

        background: Rectangle {
            color: Style.inverseSurface
            radius: Style.cornerRadiusXS
        }

        contentItem: Text {
            id: textContent

            width: Math.min(implicitWidth, Style.tooltipMaxWidth)
            text: tooltip.text
            font.pixelSize: Style.fontSizeSmall
            font.family: Style.fontFamily
            color: Style.inverseOnSurface
            wrapMode: Text.NoWrap
            maximumLineCount: 1
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        enter: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: Style.expressiveDurations.expressiveEffects
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Style.expressiveCurves.expressiveEffects
            }
        }

        exit: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: Style.shorterDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Style.expressiveCurves.expressiveEffects
            }
        }
    }
}
