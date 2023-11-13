import QtQuick 6.0
import QtQuick.Controls.Basic
import "./component"

Window {
    property QtObject backendController
    id: mainWindow
	width: 1920
	height: 1080
	minimumWidth: 1920
	minimumHeight: 1080
	visible: true
	flags: Qt.FramelessWindowHint | Qt.Window

	Popup {
	    property alias message: messageLabel.text
	    id: popUpMessage
	    width: parent.width * 0.6
	    height: parent.height * 0.5
	    anchors.centerIn: parent
	    padding: 0
	    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
	    Rectangle {
            id: rectangle
            color: "#232730"
            anchors.fill: parent
            Label {
                id: messageLabel
                x: 185
                y: 83
                color: "#ffffff"
                text: ""
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: 30
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
	}

	Item {
	    id: pageController
	    state: "Welcome"
	    states: [
            State {
                name: "Welcome"
                PropertyChanges {
                    target: welcomeLoader
                    active: true
                    visible: true
                }
            },
            State {
                name: "Setting"
                PropertyChanges {
                    target: settingLoader
                    active: true
                    visible: true
                }
            },
            State {
                name: "Crawler"
                PropertyChanges {
                    target: runLoader
                    active: true
                    visible: true
                }
            },
            State {
                name: "Analysis"
                PropertyChanges {
                    target: analysisLoader
                    active: true
                    visible: true
                }
            }
        ]
	}

	function openPopup(msg) {
	    popUpMessage.message = msg
	    popUpMessage.open()
	}

	Connections {
	    id: mainConnection
	    target: backendController

	    function onRedirectPage(page) {
	        pageController.state = page
	    }

	    function onPopupMsg(msg) {
	        openPopup(msg)
	    }

	    function onSeleniumDone(msg) {
	        openPopup(msg)
	        onRedirectPage("Welcome")
	    }

	    function onSeleniumFail(msg) {
	        openPopup(msg)
	        onRedirectPage("Welcome")
	    }
	}
	
	Component.onCompleted: {
		mainWindow.x = 0
		mainWindow.y = 0
	}

	Rectangle {
		id: appContainer
		anchors.fill: parent
		color: "#121212"

        CustomToolBar {
            id: titleBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 50
            color: "black"
        }

        Rectangle {
            id: pageContainer
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: titleBar.bottom
            anchors.bottom: parent.bottom
            color: "transparent"

            Loader {
                id: welcomeLoader
                anchors.fill: parent
                source: Qt.resolvedUrl("./page/WelcomePage.qml")
                visible: false
                active: false
            }

            Loader {
                id: settingLoader
                anchors.fill: parent
                source: Qt.resolvedUrl("./page/SettingPage.qml")
                visible: false
                active: false
            }

            Loader {
                id: runLoader
                anchors.fill: parent
                source: Qt.resolvedUrl("./page/RunPage.qml")
                visible: false
                active: false
            }

            Loader {
                id: analysisLoader
                anchors.fill: parent
                source: Qt.resolvedUrl("./page/AnalysisPage.qml")
                visible: false
                active: false
            }

        }


		
		
		
		
	}


}