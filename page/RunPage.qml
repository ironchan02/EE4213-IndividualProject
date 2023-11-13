import QtQuick 6.0
import QtQuick.Controls.Basic
import "../component"

Rectangle {
    id: runContainer
    color: "transparent"


    CustomBusyIndicator {
        id: runBusyIndicator
        anchors.centerIn: parent
    }

    Text {
        id: runLabel
        anchors.top: runBusyIndicator.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Running..."
        font.pointSize: 50
        color: "white"
        OpacityAnimator {
            id: runLabelOAShow
            target: runLabel
            from: 0
            to: 1
            duration: 750
            running: !runLabelOAHidden.running
        }
        OpacityAnimator {
            id: runLabelOAHidden
            target: runLabel
            from: 1
            to: 0
            duration: 750
            running: !runLabelOAShow.running
        }
    }

}