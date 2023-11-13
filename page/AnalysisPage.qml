import QtQuick 6.0
import QtQuick.Controls.Basic
import Qt.labs.qmlmodels
import "../component"

Rectangle {
    id: analysisContainer
    color: "transparent"

    function printStar(count) {
        let ret = ""
        for ( let i = 0; i < count; ++i )
            ret += String.fromCodePoint(0x002B50)
        return ret
    }

    Connections {
        target: backendController
        function onAnalysisResult(resultSet) {
            runBusyIndicator.visible = false
            analyzingLabel.visible = false
            analyzingResultContainerOA.running = true
            analyzingLabel.playAnimation = false
            let json = JSON.parse(resultSet)
            let results = json.results
            let positive = 0
            let negative = 0
            let rating = 0
            results.forEach( (value) => {
                let defaultLabel = value.default[0].label
                let amazonLabel = value.amazon[0].label
                let currentRating = parseInt(amazonLabel.slice(0, amazonLabel.search(" ")))
                rating += currentRating
                defaultLabel == "POSITIVE" ? ++positive : ++negative
                tableModel.appendRow(
                    {
                        Comment: value.comment,
                        Feeling: defaultLabel == "POSITIVE" ? String.fromCodePoint(0x1F60A) : String.fromCodePoint(0x1F641),
                        Rating: printStar(currentRating)
                    }
                )

                totalText.text =
                    String.fromCodePoint(0x1F60A) + " " + positive + " " +
                    String.fromCodePoint(0x1F641) + " " + negative + "\n" +
                    "Overall " + String.fromCodePoint(0x002B50) +": " + (rating / results.length).toFixed(1)


            })
        }
    }

    CustomBusyIndicator {
        id: runBusyIndicator
        anchors.centerIn: parent
    }

    Text {
        property bool playAnimation: true
        id: analyzingLabel
        anchors.top: runBusyIndicator.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Analyzing..."
        font.pointSize: 50
        color: "white"
        OpacityAnimator {
            id: analyzingLabelOAShow
            target: analyzingLabel
            from: 0
            to: 1
            duration: 750
            running: analyzingLabel.playAnimation && !analyzingLabelOAHidden.running
        }
        OpacityAnimator {
            id: analyzingLabelOAHidden
            target: analyzingLabel
            from: 1
            to: 0
            duration: 750
            running: analyzingLabel.playAnimation && !analyzingLabelOAShow.running
        }
    }

    Rectangle {
        id: analyzingResultContainer
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20
        width: parent.width * 0.6
        height: parent.height * 0.7
        color: "transparent"
        opacity: 0
        OpacityAnimator {
            id: analyzingResultContainerOA
            target: analyzingResultContainer
            from: 0
            to: 1
            duration: 500
            running: false
        }
        Rectangle {
            id: header
            width: parent.width
            height: 45
            color: "transparent"
            Row {
                spacing: 0
                Repeater {
                    id: repeater
                    model: ["Comment", "Feeling", "Rating"]
                    Rectangle {
                        width: header.width / repeater.model.length
                        height: header.height
                        color: "#242424"
                        border.width: 0.5
                        border.color: "#666666"
                        Text {
                            text: modelData
                            font.bold: true
                            font.family: "Arial"
                            anchors.centerIn: parent
                            font.pointSize: 20
                            color: "white"
                        }
                    }
                }
            }
        }

        TableView {
            id: tableView
            width: parent.width
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            clip: true
            boundsBehavior: Flickable.OvershootBounds

            ScrollBar.vertical: ScrollBar {
                anchors.right: tableView.right
                anchors.rightMargin: 0
                visible: tableModel.rowCount > 5
                background: Rectangle {
                    color: "#666666"
                }
                onActiveChanged: {
                    active = true
                }
                contentItem: Rectangle {
                    implicitWidth: 5
                    implicitHeight: 30
                    radius: 3
                    color: "#999999"
                }
            }
            model: TableModel {
                id: tableModel
                TableModelColumn {
                    display: "Comment"
                }
                TableModelColumn {
                    display: "Feeling"
                }
                TableModelColumn {
                    display: "Rating"
                }
            }
            delegate: DelegateChooser {
                DelegateChoice {
                    column: 0
                    delegate: ScrollView {
                        id: scrollView
                        x: repeater.itemAt(0).x
                        implicitWidth: header.width / 3
                        implicitHeight: 100
                        ScrollBar.vertical.policy: ScrollBar.AsNeeded
                        ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                        TextArea {
                            id: productInput
                            text: display
                            enabled: false
                            placeholderTextColor: "#cfcfcf"
                            color: "white"
                            wrapMode: TextEdit.Wrap
                            font.pointSize: 20
                            background: Rectangle {
                                border.color: productInput.focus ? "white" : "#242424"
                                color: row % 2 == 0 ? "#363636" : "#242424"
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
                DelegateChoice {
                    column: 1
                    delegate: Rectangle {
                        id: tableReact
                        color: row % 2 == 0 ? "#363636" : "#242424"
                        x: repeater.itemAt(0).x
                        implicitWidth: header.width / 3
                        implicitHeight: 40
                        width: Math.max(header.width * 0.5, implicitWidth)
                        height: Math.max(40, implicitHeight)
                        clip: true
                        Text {
                            text: display
                            anchors.centerIn: parent
                            font.pointSize: 30
                            color: "white"
                        }
                    }
                }
                DelegateChoice {
                    column: 2
                    delegate: Rectangle {
                        id: tableReact
                        color: row % 2 == 0 ? "#363636" : "#242424"
                        x: repeater.itemAt(0).x
                        implicitWidth: header.width / 3
                        implicitHeight: 40
                        width: Math.max(header.width * 0.5, implicitWidth)
                        height: Math.max(40, implicitHeight)
                        clip: true
                        Text {
                            text: display
                            anchors.centerIn: parent
                            font.pointSize: 30
                            color: "white"
                        }
                    }
                }
            }
        }
        Rectangle {
            id: resultOverview
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: tableView.bottom
            anchors.topMargin: 10
            height: totalText.height
            color: "transparent"
            Text {
                id: totalText
                font.family: "Arial"
                font.pointSize: 40
                text: String.fromCodePoint(0x1F60A) + " " + String.fromCodePoint(0x1F641)
                color: "white"
            }
        }
        Button {
            id: backButton
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: resultOverview.bottom
            anchors.topMargin: 10
            hoverEnabled: true
            contentItem: Text {
                text: "Return to menu"
                font.pointSize: 20
            }
            background: Rectangle {
                color: backButton.hovered ? backButton.pressed ? "green" : "#29bd04" : "green"
            }
            onClicked: backendController.changePage("Welcome")
        }
    }

    Component.onCompleted: {
        backendController.startAnalysis()
    }



}