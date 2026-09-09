import QtQuick
import qs.DankCommon.Common
import qs.DankCommon.Widgets as Base

Item {
    id: root

    property string hours: "00"
    property string minutes: "00"
    property string seconds: ""
    property string dateText: ""
    property string dayText: ""
    property bool stacked: false
    property color color: Style.primary
    property color supportingColor: Style.onSurfaceVariant

    readonly property bool tall: height > Style.buttonHeightM * 2
    readonly property bool vertical: tall && (stacked || width < height)
    readonly property real displaySize: Math.min(Style.fontSizeDisplay * 2.5, height * (vertical ? 0.34 : 0.48))
    readonly property string timeText: hours + ":" + minutes + (seconds !== "" ? ":" + seconds : "")

    implicitWidth: Style.fontSizeDisplay * 6
    implicitHeight: Style.fontSizeDisplay * 4

    Column {
        anchors.centerIn: parent
        width: parent.width
        spacing: root.tall ? Style.spacingS : 0

        Base.StyledText {
            width: parent.width
            text: root.dateText
            color: root.supportingColor
            font.pixelSize: Style.fontSizeMedium
            font.weight: Font.Medium
            horizontalAlignment: Text.AlignHCenter
            visible: root.tall && text !== ""
        }

        Column {
            width: parent.width
            spacing: -Style.spacingS

            Digits {
                text: root.vertical ? root.hours : root.timeText
            }

            Digits {
                text: root.minutes
                visible: root.vertical
            }
        }

        Base.StyledText {
            width: parent.width
            text: root.dayText + (root.vertical && root.seconds !== "" ? " · " + root.seconds : "")
            color: root.supportingColor
            font.pixelSize: Style.fontSizeMedium
            font.weight: Font.Medium
            horizontalAlignment: Text.AlignHCenter
            visible: text !== "" && root.tall
        }
    }

    component Digits: Base.StyledText {
        width: parent.width
        height: font.pixelSize * 1.05
        color: root.color
        font.pixelSize: root.tall ? root.displaySize : Math.min(Style.fontSizeDisplay * 1.5, root.height)
        font.weight: Font.Bold
        font.features: ({
                "tnum": 1
            })
        font.variableAxes: ({
                "ROND": 100,
                "wght": 750,
                "opsz": root.displaySize
            })
        minimumPixelSize: Style.fontSizeLarge
        fontSizeMode: Text.Fit
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.NoWrap
        elide: Text.ElideNone
        LayoutMirroring.enabled: false
    }
}
