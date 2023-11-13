import QtQuick 6.0
import QtQuick.Controls.Basic
import "../component"

Rectangle {
    id: settingContainer
    color: "transparent"

    opacity: 0
    OpacityAnimator {
        id: settingContainerOA
        target: settingContainer
        from: 0
        to: 1
        duration: 500
        running: true
    }

    Text {
        id: settingText
        text: "Setting"
        font.pointSize: 50
        color: "white"
        anchors.bottom: settingOptionRect.top
        anchors.bottomMargin: 10
        anchors.horizontalCenter: settingOptionRect.horizontalCenter
    }

    Rectangle {
        id: settingOptionRect
        color: "transparent"
        anchors.centerIn: parent
        width: childrenRect.width
        height: childrenRect.height

        Text {
            id: driverText
            anchors.left: parent.left
            anchors.top: parent.top
            text: "Driver Path: "
            font.pointSize: 25
            color: "white"
        }

        TextField {
            id: driverInput
            anchors.left: driverText.right
            anchors.leftMargin: 10
            anchors.top: driverText.top
            anchors.bottom: driverText.bottom
            placeholderText: "Path to driver.exe"
            placeholderTextColor: "#cfcfcf"
            color: "white"
            width: 300
            font.pointSize: 20
            background: Rectangle {
                border.color: driverInput.focus ? "white" : "#242424"
                color: "#242424"
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 2
                    z: driverInput.focus ? -1 : 1
                    color: "green"
                }
            }
        }

        Text {
            id: productText
            anchors.left: parent.left
            anchors.top: driverText.bottom
            anchors.topMargin: 10
            text: "Product link: "
            font.pointSize: 25
            color: "white"
        }

        ScrollView {
            id: scrollView
            anchors.left: productText.right
            anchors.leftMargin: 10
            anchors.top: productText.top
            ScrollBar.vertical.policy: ScrollBar.AsNeeded
            ScrollBar.horizontal.policy: ScrollBar.AsNeeded
            width: 500
            height: 100
            TextArea {
                id: productInput
                placeholderText: "URL to your product"
                placeholderTextColor: "#cfcfcf"
                color: "white"
                wrapMode: TextEdit.Wrap
                font.pointSize: 20
                background: Rectangle {
                    border.color: productInput.focus ? "white" : "#242424"
                    color: "#242424"
                    Rectangle {
                        anchors.bottom: parent.bottom
                        height: 2
                        z: productInput.focus ? -1 : 1
                        color: "green"
                    }
                }
            }
        }

    }
    Button {
        id: saveBtn
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: settingOptionRect.bottom
        anchors.topMargin: 10
        hoverEnabled: true
        contentItem: Text {
            text: "Save and Quit"
            font.pointSize: 20
        }
        background: Rectangle {
            color: saveBtn.hovered ? saveBtn.pressed ? "green" : "#29bd04" : "green"
        }
        onClicked: {
            let fileReg = new RegExp("^.+\/chromedriver\.exe")
            if (!fileReg.test(driverInput.text)) {
                backendController.showPopup("Driver path is not a valid path")
                return
            }
            let obj = new Object()
            obj.driverPath = driverInput.text
            obj.productLink = productInput.text
            backendController.saveSetting(JSON.stringify(obj))
            backendController.changePage("Welcome")
        }
    }

    Component.onCompleted: {
        let xhr = new XMLHttpRequest()
        xhr.open("GET", "../config/setting.json", false)
        xhr.onreadystatechange = () => {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status == 0) console.log("Setting file not found!")
                if (xhr.status == 200) {
                    let json = JSON.parse(xhr.responseText)
                    driverInput.text = json.driverPath
                    productInput.text = json.productLink
                }
            }
        }
        xhr.send()
    }



}