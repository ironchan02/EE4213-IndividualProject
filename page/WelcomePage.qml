import QtQuick 6.0
import QtQuick.Controls.Basic
import "../component"


Rectangle {
    id: welcomeContainer
    color: "transparent"

    Text {
        id: welcomeText
        text: "Welcome!"
        font.pointSize: 50
        color: "white"
        anchors.top: parent.top
        anchors.topMargin: 200
        anchors.horizontalCenter: parent.horizontalCenter
        OpacityAnimator {
            id: welcomeTextOA
            target: welcomeText
            from: 0
            to: 1
            duration: 500
            running: true
        }
    }

    Rectangle {
        id: buttonContainer
        width: childrenRect.width
        height: childrenRect.height
        anchors.top: welcomeText.bottom
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"

        PageButton {
            id: crawlerButton
            mainColor: "#14d95d"
            iconPath: "../image/crawler.png"
            buttonText: "Crawler"
            animatorRun: !welcomeTextOA.running
            onClicked: {
                backendController.changePage("Crawler")
                backendController.crawler()
            }
        }

        PageButton {
            id: analysisButton
            anchors.left: crawlerButton.right
            anchors.leftMargin: 30
            mainColor: "#e86b15"
            iconPath: "../image/analysis.png"
            buttonText: "Analysis"
            animatorRun: !welcomeTextOA.running
            onClicked: backendController.changePage("Analysis")
        }

        PageButton {
            id: settingButton
            anchors.left: analysisButton.right
            anchors.leftMargin: 30
            mainColor: "#d99e14"
            iconPath: "../image/setting.png"
            buttonText: "Setting"
            animatorRun: !welcomeTextOA.running
            onClicked: backendController.changePage("Setting")
        }


    }

}