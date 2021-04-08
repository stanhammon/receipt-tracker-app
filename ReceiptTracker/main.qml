import QtQuick 2.12
import QtQuick.Controls 2.5

ApplicationWindow {
    id: mainwindow
    width: 640
    height: 480
    visible: true
    title: qsTr("Scroll")

    Button {
        id: button
        x: 25
        y: 14
        text: qsTr("Add Receipt")
        onClicked: {
            var component = Qt.createComponent("AddReceipt.qml")
            var window    = component.createObject(mainwindow)
            //window.show()
        }
    }

    Button {
        id: button1
        x: 512
        y: 19
        text: qsTr("Button")
    }

    ListView {
        id: listView
        x: 15
        y: 68
        width: 608
        height: 394
        delegate: Item {
            x: 5
            width: 80
            height: 40
            Row {
                id: row1
                Rectangle {
                    width: 40
                    height: 40
                    color: colorCode
                }

                Text {
                    text: name
                    anchors.verticalCenter: parent.verticalCenter
                    font.bold: true
                }
                spacing: 10
            }
        }
        model: ListModel {
            id: listModelID
            /*
            ListElement {
                name: "Grey"
                colorCode: "grey"
            }

            ListElement {
                name: "Red"
                colorCode: "red"
            }

            ListElement {
                name: "Blue"
                colorCode: "blue"
            }

            ListElement {
                name: "Green"
                colorCode: "green"
            }
            */
        }

    }

    function addReceipt(/*date,amount,business,bTippable,tip*/) {
        listModelID.append( "item" )
    }

}
