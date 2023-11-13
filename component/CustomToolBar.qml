import QtQuick 6.0
import QtQuick.Controls.Basic

Rectangle {
    id: titleBar

    Text {
        id: title
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: 5
        text: "EE4316 Individual Project"
        font.pointSize: 20
        color: "white"
        verticalAlignment: Text.AlignVCenter
    }

    Button {
        id: closeButton
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height * 0.75
        width: height
        text: String.fromCodePoint(0x002716)
        font.pointSize: 18
        hoverEnabled: true
        background: Rectangle {
            width: closeButton.width
            height: width
            radius: width / 2
            color: closeButton.hovered ? "#800000" : "#FF0000"
        }
        onClicked: mainWindow.close()
    }

}