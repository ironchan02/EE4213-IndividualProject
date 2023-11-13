import QtQuick 6.0
import QtQuick.Controls.Basic

Button {
    property string mainColor
    property string iconPath
    property string buttonText
    property alias animatorRun: btnOA.running

    id: btn
    width: 300
    height: width
    hoverEnabled: true
    opacity: 0
    signal renderingDone
    OpacityAnimator {
        id: btnOA
        target: btn
        from: 0
        to: 1
        duration: 500
        running: false
        onRunningChanged: {
            if ( !running )
                btn.renderingDone()
        }
    }
    background: Rectangle {
        color: btn.hovered ? btn.pressed ? "#121212" : "#232323" : "#121212"
        border.width: 2
        border.color: mainColor
        radius: 50
        Image {
            id: icon
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 75
            width: 100
            height: width
            source: iconPath
            fillMode: Image.PreserveAspectFit
        }
        Text {
            text: buttonText
            font.pointSize: 25
            anchors.top: icon.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 20
            color: mainColor
            horizontalAlignment: Text.AlignHCenter
        }

    }

}