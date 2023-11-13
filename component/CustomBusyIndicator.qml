import QtQuick 6.0
import QtQuick.Controls.Basic
import "../component"

BusyIndicator {
    id: control

    contentItem: Item {
        implicitWidth: 250
        implicitHeight: 250

        Item {
            id: item
            anchors.centerIn: parent
            width: 250
            height: 250
            opacity: control.running ? 1 : 0

            Behavior on opacity {
                OpacityAnimator {
                    duration: 500
                }
            }

            RotationAnimator {
                target: item
                running: control.visible && control.running
                from: 0
                to: 360
                loops: Animation.Infinite
                duration: 1250
            }

            Repeater {
                id: repeater
                model: 6

                Rectangle {
                    x: item.width / 2 - width / 2
                    y: item.height / 2 - height / 2
                    implicitWidth: 50
                    implicitHeight: 50
                    radius: 25
                    color: "#FFFFFF"
                    transform: [
                        Translate {
                            y: -Math.min(item.width, item.height) * 0.5 + 5
                        },
                        Rotation {
                            angle: index / repeater.count * 360
                            origin.x: 25
                            origin.y: 25
                        }]
                }
            }
        }
    }
}