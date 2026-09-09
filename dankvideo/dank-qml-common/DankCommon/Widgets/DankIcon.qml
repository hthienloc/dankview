import QtQuick
import qs.DankCommon.Common

Item {
    id: root

    property alias name: icon.text
    property alias size: icon.font.pixelSize
    property alias color: icon.color
    property bool filled: false
    property real fill: filled ? 1.0 : 0.0
    property int grade: Style.isLightMode ? 0 : -25
    property int weight: filled ? 500 : 400
    property real weightAnim: weight
    readonly property int weightStep: Math.round(weightAnim / 25) * 25
    readonly property real fillStep: Math.round(fill * 4) / 4
    property bool smoothTransform: false

    implicitWidth: Math.round(size)
    implicitHeight: Math.round(size)

    signal rotationCompleted

    StyledText {
        id: icon

        anchors.fill: parent

        font.family: Fonts.icons
        font.pixelSize: Math.round(Style.fontSizeMedium)
        font.weight: root.weightStep
        font.hintingPreference: Font.PreferNoHinting
        color: Style.surfaceText
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        renderType: root.smoothTransform ? Text.QtRendering : Text.NativeRendering

        font.variableAxes: {
            "FILL": root.fillStep,
            "GRAD": root.grade,
            "opsz": 24,
            "wght": root.weightStep
        }
    }

    Behavior on weightAnim {
        NumberAnimation {
            duration: Style.shortDuration
            easing.type: Style.standardEasing
        }
    }

    Behavior on fill {
        NumberAnimation {
            duration: Style.shortDuration
            easing.type: Style.standardEasing
        }
    }

    Timer {
        id: rotationTimer
        interval: 16
        repeat: false
        onTriggered: root.rotationCompleted()
    }

    onRotationChanged: {
        rotationTimer.restart();
    }
}
