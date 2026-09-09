import "../../Common/fzf.js" as Fzf
import "../ScrollConstants.js" as Scroll
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.DankCommon.Common
import qs.DankCommon.Widgets as Base

Item {
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

    property string text: ""
    property string description: ""
    property string currentValue: ""
    property var options: []
    property var optionIcons: []
    property bool enableFuzzySearch: false
    property var optionIconMap: ({})
    property var optionColorMap: ({})

    function rebuildIconMap() {
        const map = {};
        for (let i = 0; i < options.length; i++) {
            if (optionIcons.length > i)
                map[options[i]] = optionIcons[i];
        }
        optionIconMap = map;
    }

    onOptionsChanged: rebuildIconMap()
    onOptionIconsChanged: rebuildIconMap()

    property int popupWidthOffset: 0
    property int maxPopupHeight: Style.menuMaxHeight
    property bool openUpwards: false
    property int popupWidth: 0
    property bool alignPopupRight: false
    property int dropdownWidth: 200
    property bool compactMode: text === "" && description === ""
    property bool showTrigger: true
    property Item popupAnchorItem: null
    property bool addHorizontalPadding: false
    property string emptyText: ""
    property bool usePopupTransparency: !checkParentDisablesTransparency()
    property color backgroundColor: usePopupTransparency ? Style.withAlpha(Style.surfaceContainer, Style.popupTransparency) : Style.surfaceContainer
    property color hoverBackgroundColor: usePopupTransparency ? Style.withAlpha(Style.surfaceContainerHigh, Style.popupTransparency) : Style.surfaceContainerHigh
    property color menuBackgroundColor: usePopupTransparency ? Style.floatingSurface : Style.surfaceContainer
    property color normalBorderColor: Style.outlineVariant
    property color focusedBorderColor: Style.primary
    property var transientSurfaceTracker: null
    property bool menuBlurEnabled: true

    signal valueChanged(string value)

    property bool menuOpen: false

    onMenuOpenChanged: transientSurfaceTracker?.setActive(root, menuOpen, menuOpen ? dropdownMenu : null)

    readonly property int triggerHeight: Style.iconButtonSize
    readonly property int menuItemHeight: Style.menuItemHeight
    readonly property int menuPadding: Style.spacingS
    readonly property int menuSpacing: Style.spacingXXS

    readonly property int menuWidth: {
        if (root.popupWidth > 0)
            return root.popupWidth;
        return Math.max(1, dropdown.width + root.popupWidthOffset);
    }

    readonly property int menuHeight: {
        let h = root.enableFuzzySearch ? searchContainer.height + Style.spacingXS : 0;
        if (root.options.length === 0 && root.emptyText !== "")
            h += menuItemHeight;
        else
            h += Math.min(dropdownMenu.filteredOptions.length, 10) * (menuItemHeight + menuSpacing);
        return Math.min(root.maxPopupHeight, h + menuPadding * 2);
    }

    function positionMenuInHost() {
        const qsWin = root.QsWindow.window;
        const anchorItem = root.popupAnchorItem || dropdown;
        if (!qsWin || !anchorItem)
            return false;

        dropdownMenu.anchor.window = qsWin;
        dropdownMenu.anchor.rect.x = 0;
        dropdownMenu.anchor.rect.y = 0;
        dropdownMenu.anchor.edges = Edges.Top | Edges.Left;
        dropdownMenu.anchor.gravity = Edges.Bottom | Edges.Right;
        dropdownMenu.anchor.margins.top = 0;
        dropdownMenu.anchor.margins.bottom = 0;
        dropdownMenu.anchor.adjustment = PopupAdjustment.None;
        dropdownMenu.width = qsWin.width;
        dropdownMenu.height = qsWin.height;

        const pos = root.QsWindow.itemPosition(anchorItem);
        const menuW = root.menuWidth;
        const menuH = root.menuHeight;
        const gap = Style.spacingXS;
        let x = root.alignPopupRight ? pos.x + anchorItem.width - menuW : pos.x;
        let goUp = root.openUpwards;
        if (!goUp && pos.y + anchorItem.height + menuH + gap > qsWin.height)
            goUp = true;
        if (goUp && pos.y - menuH - gap < 0)
            goUp = false;
        let y = goUp ? pos.y - menuH - gap : pos.y + anchorItem.height + gap;
        dropdownMenu.menuX = Math.max(0, Math.min(qsWin.width - menuW, x));
        dropdownMenu.menuY = Math.max(0, Math.min(qsWin.height - menuH, y));
        dropdownMenu.opensUpwards = goUp;
        dropdownMenu.anchor.updateAnchor();
        return true;
    }

    function closeDropdownMenu() {
        if (!root.menuOpen && !dropdownMenu.visible)
            return;
        root.menuOpen = false;
        dropdownMenu.closing = true;
        closeTimer.restart();
    }

    function showDropdownMenu() {
        if (root.options.length === 0)
            return;
        if (root.menuOpen)
            return;
        if (!positionMenuInHost())
            return;

        root.menuOpen = true;
        closeTimer.stop();
        dropdownMenu.closing = false;
        dropdownMenu.visible = true;
        const currentIndex = root.options.indexOf(root.currentValue);
        listView.positionViewAtIndex(currentIndex >= 0 ? currentIndex : 0, ListView.Beginning);
        if (searchField.text.length > 0) {
            dropdownMenu.initFinder();
            dropdownMenu.searchQuery = searchField.text;
        } else {
            dropdownMenu.fzfFinder = null;
            dropdownMenu.searchQuery = "";
        }
        dropdownMenu.selectedIndex = dropdownMenu.filteredOptions.indexOf(root.currentValue);

        Qt.callLater(() => {
            if (root.enableFuzzySearch)
                searchField.forceActiveFocus();
            else
                menuKeyHandler.forceActiveFocus();
        });
    }

    function openDropdownMenu() {
        if (root.menuOpen) {
            closeDropdownMenu();
            return;
        }
        showDropdownMenu();
    }

    function resetSearch() {
        searchField.text = "";
        dropdownMenu.fzfFinder = null;
        dropdownMenu.searchQuery = "";
        dropdownMenu.selectedIndex = -1;
    }

    width: !showTrigger ? 0 : (compactMode ? dropdownWidth : parent.width)
    implicitHeight: !showTrigger ? 0 : (compactMode ? triggerHeight : Math.max(Style.listItemHeight + Style.spacingXS, labelColumn.implicitHeight + Style.spacingM))
    activeFocusOnTab: showTrigger && enabled
    Accessible.role: Accessible.ComboBox
    Accessible.name: text || currentValue
    Accessible.description: description
    Accessible.onPressAction: {
        if (enabled)
            openDropdownMenu();
    }

    Keys.onPressed: event => {
        if (!root.enabled)
            return;
        switch (event.key) {
        case Qt.Key_Space:
        case Qt.Key_Return:
        case Qt.Key_Enter:
        case Qt.Key_Down:
            root.showDropdownMenu();
            event.accepted = true;
            break;
        }
    }

    Component.onDestruction: {
        transientSurfaceTracker?.unregister(root);
        if (root.menuOpen || dropdownMenu.visible)
            dropdownMenu.visible = false;
    }

    Connections {
        target: root.transientSurfaceTracker
        ignoreUnknownSignals: true

        function onCloseRequested() {
            root.closeDropdownMenu();
        }
    }

    Column {
        id: labelColumn

        anchors.left: parent.left
        anchors.right: dropdown.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: root.addHorizontalPadding ? Style.spacingM : 0
        anchors.rightMargin: Style.spacingL
        spacing: Style.spacingXS
        visible: !root.compactMode && root.showTrigger

        Base.StyledText {
            text: root.text
            font.pixelSize: Style.fontSizeMedium
            color: Style.surfaceText
            font.weight: Font.Medium
            width: parent.width
            horizontalAlignment: Text.AlignLeft
        }

        Base.StyledText {
            text: root.description
            font.pixelSize: Style.fontSizeSmall
            color: Style.onSurfaceVariant
            visible: description.length > 0
            wrapMode: Text.WordWrap
            width: parent.width
            horizontalAlignment: Text.AlignLeft
        }
    }

    Rectangle {
        id: dropdown

        readonly property bool active: dropdownMenu.visible || root.activeFocus

        visible: root.showTrigger
        width: root.compactMode ? parent.width : (root.popupWidth === -1 ? undefined : (root.popupWidth > 0 ? root.popupWidth : root.dropdownWidth))
        height: root.triggerHeight
        anchors.right: parent.right
        anchors.rightMargin: root.addHorizontalPadding && !root.compactMode ? Style.spacingM : 0
        anchors.verticalCenter: parent.verticalCenter
        radius: Style.cornerRadiusM
        color: !root.enabled ? Style.onSurface_12 : (dropdownArea.containsMouse || dropdownMenu.visible ? root.hoverBackgroundColor : root.backgroundColor)
        border.color: !root.enabled ? "transparent" : (active || dropdownArea.containsMouse ? root.focusedBorderColor : root.normalBorderColor)
        border.width: active ? Style.outlineWidthFocused : Style.outlineWidth

        Behavior on color {
            enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
            DankColorAnim {
                duration: Style.expressiveDurations.expressiveEffects
                easing.bezierCurve: Style.expressiveCurves.expressiveEffects
            }
        }

        Behavior on border.color {
            enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
            DankColorAnim {
                duration: Style.expressiveDurations.expressiveEffects
                easing.bezierCurve: Style.expressiveCurves.expressiveEffects
            }
        }

        MouseArea {
            id: dropdownArea

            anchors.fill: parent
            enabled: root.enabled
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.openDropdownMenu()
        }

        Row {
            id: contentRow

            anchors.left: parent.left
            anchors.right: expandIcon.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: Style.spacingL
            anchors.rightMargin: Style.spacingS
            spacing: Style.spacingS

            Base.DankColorSwatch {
                id: triggerSwatch

                width: Style.iconSizeSmall
                height: Style.iconSizeSmall
                anchors.verticalCenter: parent.verticalCenter
                visible: root.optionColorMap[root.currentValue] !== undefined
                swatchColor: visible ? root.optionColorMap[root.currentValue] : "transparent"
            }

            Base.DankIcon {
                id: triggerIcon

                name: root.optionIconMap[root.currentValue] ?? ""
                size: Style.iconSizeMedium
                color: root.enabled ? Style.surfaceText : Style.onSurface_38
                anchors.verticalCenter: parent.verticalCenter
                visible: name !== ""
            }

            Base.StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: root.currentValue !== "" ? root.currentValue : root.emptyText
                font.pixelSize: Style.fontSizeMedium
                color: !root.enabled ? Style.onSurface_38 : (root.currentValue !== "" ? Style.surfaceText : Style.onSurfaceVariant)
                width: contentRow.width - (triggerSwatch.visible ? triggerSwatch.width + contentRow.spacing : 0) - (triggerIcon.visible ? triggerIcon.width + contentRow.spacing : 0)
                elide: Text.ElideRight
                wrapMode: Text.NoWrap
                horizontalAlignment: Text.AlignLeft
            }
        }

        Base.DankIcon {
            id: expandIcon

            name: "arrow_drop_down"
            size: Style.iconSize
            color: root.enabled ? Style.onSurfaceVariant : Style.onSurface_38
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: Style.spacingS
            rotation: dropdownMenu.visible ? 180 : 0

            Behavior on rotation {
                enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
                DankAnim {
                    duration: Style.expressiveDurations.expressiveFastSpatial
                    easing.bezierCurve: Style.expressiveCurves.expressiveDefaultSpatial
                }
            }
        }
    }

    PopupWindow {
        id: dropdownMenu

        grabFocus: true

        property string searchQuery: ""
        property var filteredOptions: {
            if (!root.enableFuzzySearch || searchQuery.length === 0)
                return root.options;
            if (!fzfFinder)
                return root.options;
            return fzfFinder.find(searchQuery).map(r => r.item);
        }
        property int selectedIndex: -1
        property var fzfFinder: null
        property real menuX: 0
        property real menuY: 0
        property bool closing: false
        property bool opensUpwards: false

        function initFinder() {
            fzfFinder = new Fzf.Finder(root.options, {
                "selector": option => option,
                "limit": 50,
                "casing": "case-insensitive",
                "sort": true,
                "tiebreakers": [(a, b, selector) => selector(a.item).length - selector(b.item).length]
            });
        }

        function selectNext() {
            if (filteredOptions.length === 0)
                return;
            selectedIndex = (selectedIndex + 1) % filteredOptions.length;
            listView.positionViewAtIndex(selectedIndex, ListView.Contain);
        }

        function selectPrevious() {
            if (filteredOptions.length === 0)
                return;
            selectedIndex = selectedIndex <= 0 ? filteredOptions.length - 1 : selectedIndex - 1;
            listView.positionViewAtIndex(selectedIndex, ListView.Contain);
        }

        function selectCurrent() {
            if (selectedIndex < 0 || selectedIndex >= filteredOptions.length)
                return;
            root.currentValue = filteredOptions[selectedIndex];
            root.valueChanged(filteredOptions[selectedIndex]);
            root.closeDropdownMenu();
        }

        color: "transparent"
        visible: false

        onVisibleChanged: {
            if (!visible && root.menuOpen)
                root.menuOpen = false;
            if (!visible && root.activeFocusOnTab)
                root.forceActiveFocus();
            if (visible)
                Qt.callLater(() => menuKeyHandler.forceActiveFocus());
        }

        Timer {
            id: closeTimer

            interval: Style.expressiveDurations.expressiveEffects
            onTriggered: {
                dropdownMenu.closing = false;
                dropdownMenu.visible = false;
            }
        }

        BackgroundEffect.blurRegion: (visible && !closing && root.menuBlurEnabled && !!(Style.theme?.blurLayersActive ?? true)) ? menuBlurRegion : null

        Region {
            id: menuBlurRegion
            x: menuContainer.x
            y: menuContainer.y
            width: menuContainer.width
            height: menuContainer.height
            radius: Style.cornerRadiusM
        }

        MouseArea {
            anchors.fill: parent
            z: -1
            enabled: dropdownMenu.visible
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            onClicked: root.closeDropdownMenu()
        }

        FocusScope {
            id: menuKeyHandler
            anchors.fill: parent
            focus: dropdownMenu.visible
            z: 0

            Keys.onPressed: event => {
                switch (event.key) {
                case Qt.Key_Escape:
                    root.closeDropdownMenu();
                    event.accepted = true;
                    return;
                case Qt.Key_Down:
                    dropdownMenu.selectNext();
                    event.accepted = true;
                    return;
                case Qt.Key_Up:
                    dropdownMenu.selectPrevious();
                    event.accepted = true;
                    return;
                case Qt.Key_Return:
                case Qt.Key_Enter:
                    dropdownMenu.selectCurrent();
                    event.accepted = true;
                    return;
                }
            }
        }

        Item {
            id: menuContainer
            x: dropdownMenu.menuX
            y: dropdownMenu.menuY
            width: root.menuWidth
            height: root.menuHeight
            z: 1

            Rectangle {
                id: contentSurface

                readonly property bool shown: dropdownMenu.visible && !dropdownMenu.closing

                anchors.fill: parent
                LayoutMirroring.enabled: I18n.isRtl
                LayoutMirroring.childrenInherit: true
                color: "transparent"
                border.color: "transparent"
                border.width: 0
                radius: Style.cornerRadiusM
                opacity: shown ? 1 : 0
                scale: shown ? 1 : Style.popupEnterScale
                transformOrigin: dropdownMenu.opensUpwards ? Item.Bottom : Item.Top

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
                        easing.bezierCurve: Style.expressiveCurves.expressiveDefaultSpatial
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    z: -1
                    acceptedButtons: Qt.AllButtons
                    onPressed: mouse => mouse.accepted = true
                    onClicked: mouse => mouse.accepted = true
                }

                ElevationShadow {
                    id: shadowLayer
                    anchors.fill: parent
                    z: -1
                    level: Style.elevationLevel2
                    fallbackOffset: Style.spacingXS
                    targetRadius: contentSurface.radius
                    targetColor: root.menuBackgroundColor
                    borderColor: root.normalBorderColor
                    borderWidth: Style.outlineWidth
                    shadowEnabled: Style.elevationEnabled && Style.popoutElevationEnabled
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: root.menuPadding

                    Rectangle {
                        id: searchContainer

                        width: parent.width
                        height: root.triggerHeight
                        visible: root.enableFuzzySearch
                        radius: Style.cornerRadiusM
                        color: "transparent"

                        DankTextField {
                            id: searchField

                            anchors.fill: parent
                            placeholderText: I18n.tr("Search...")
                            backgroundColor: root.backgroundColor
                            normalBorderColor: root.normalBorderColor
                            focusedBorderColor: root.focusedBorderColor
                            topPadding: Style.spacingS
                            bottomPadding: Style.spacingS
                            onTextChanged: searchDebounce.restart()
                            Keys.onDownPressed: dropdownMenu.selectNext()
                            Keys.onUpPressed: dropdownMenu.selectPrevious()
                            Keys.onReturnPressed: dropdownMenu.selectCurrent()
                            Keys.onEnterPressed: dropdownMenu.selectCurrent()
                            Keys.onEscapePressed: event => {
                                root.closeDropdownMenu();
                                event.accepted = true;
                            }
                            Keys.onPressed: event => {
                                if (!(event.modifiers & Qt.ControlModifier))
                                    return;
                                switch (event.key) {
                                case Qt.Key_N:
                                case Qt.Key_J:
                                    dropdownMenu.selectNext();
                                    event.accepted = true;
                                    break;
                                case Qt.Key_P:
                                case Qt.Key_K:
                                    dropdownMenu.selectPrevious();
                                    event.accepted = true;
                                    break;
                                }
                            }

                            Timer {
                                id: searchDebounce
                                interval: 50
                                onTriggered: {
                                    if (!dropdownMenu.fzfFinder)
                                        dropdownMenu.initFinder();
                                    dropdownMenu.searchQuery = searchField.text;
                                    dropdownMenu.selectedIndex = -1;
                                }
                            }
                        }
                    }

                    Item {
                        width: parent.width
                        height: Style.spacingXS
                        visible: root.enableFuzzySearch
                    }

                    Item {
                        width: parent.width
                        height: root.menuItemHeight
                        visible: root.options.length === 0 && root.emptyText !== ""

                        Base.StyledText {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: Style.spacingM
                            anchors.rightMargin: Style.spacingM
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.emptyText
                            font.pixelSize: Style.fontSizeMedium
                            color: Style.onSurfaceVariant
                            horizontalAlignment: Text.AlignLeft
                        }
                    }

                    Base.DankListView {
                        id: listView

                        width: parent.width
                        height: parent.height - (root.enableFuzzySearch ? searchContainer.height + Style.spacingXS : 0) - (root.options.length === 0 && root.emptyText !== "" ? root.menuItemHeight : 0)
                        clip: true
                        visible: root.options.length > 0
                        model: ScriptModel {
                            values: dropdownMenu.filteredOptions
                        }
                        spacing: root.menuSpacing

                        interactive: true
                        flickDeceleration: Scroll.flickDeceleration
                        maximumFlickVelocity: Scroll.maximumFlickVelocity
                        boundsBehavior: Flickable.DragAndOvershootBounds
                        boundsMovement: Flickable.FollowBoundsBehavior
                        pressDelay: 0
                        flickableDirection: Flickable.VerticalFlick

                        delegate: Rectangle {
                            id: delegateRoot

                            required property var modelData
                            required property int index
                            property bool isSelected: dropdownMenu.selectedIndex === index
                            property bool isCurrentValue: root.currentValue === modelData
                            property string iconName: root.optionIconMap[modelData] ?? ""
                            property var swatchColor: root.optionColorMap[modelData]
                            readonly property color contentColor: isCurrentValue ? Style.onPrimaryContainer : Style.surfaceText

                            width: ListView.view.width
                            height: root.menuItemHeight
                            radius: Style.cornerRadiusS
                            color: {
                                if (isCurrentValue)
                                    return Style.primaryContainer;
                                if (isSelected)
                                    return Style.withAlpha(Style.onSurface, Style.stateLayerFocus);
                                if (optionArea.containsMouse)
                                    return Style.withAlpha(Style.onSurface, Style.stateLayerHover);
                                return Style.withAlpha(Style.onSurface, 0);
                            }

                            Behavior on color {
                                enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
                                DankColorAnim {
                                    duration: Style.expressiveDurations.expressiveEffects
                                    easing.bezierCurve: Style.expressiveCurves.expressiveEffects
                                }
                            }

                            Row {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: Style.spacingM
                                anchors.rightMargin: Style.spacingM
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Style.spacingS

                                Base.DankColorSwatch {
                                    id: optionSwatch

                                    width: Style.iconSizeSmall
                                    height: Style.iconSizeSmall
                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: delegateRoot.swatchColor !== undefined
                                    swatchColor: visible ? delegateRoot.swatchColor : Style.withAlpha(delegateRoot.swatchColor, 0)
                                    ringColor: delegateRoot.isCurrentValue ? Style.primary : Style.outline
                                }

                                Base.DankIcon {
                                    name: delegateRoot.iconName
                                    size: Style.iconSizeMedium
                                    color: delegateRoot.contentColor
                                    visible: name !== ""
                                }

                                Base.StyledText {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: delegateRoot.modelData
                                    font.pixelSize: Style.fontSizeMedium
                                    color: delegateRoot.contentColor
                                    font.weight: delegateRoot.isCurrentValue ? Font.Medium : Font.Normal
                                    width: root.popupWidth > 0 ? undefined : (delegateRoot.width - parent.x - Style.spacingM * 2 - (optionSwatch.visible ? optionSwatch.width + parent.spacing : 0))
                                    elide: root.popupWidth > 0 ? Text.ElideNone : Text.ElideRight
                                    wrapMode: Text.NoWrap
                                    horizontalAlignment: Text.AlignLeft
                                }
                            }

                            MouseArea {
                                id: optionArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.currentValue = delegateRoot.modelData;
                                    root.valueChanged(delegateRoot.modelData);
                                    root.closeDropdownMenu();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
