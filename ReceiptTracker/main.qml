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
        id: button_Delete
        x: 267
        y: 14
        text: qsTr("Delete")
        onClicked: {
            // remove Receipts that has been marked as 'selected'
            for (var i=0; i<receiptListModel.count; ){
                if( receiptListModel.get(i).isSelected === "yes" ){
                    receiptListModel.remove(i);
                }else{
                    i++
                }
            }
        }
    }

    ListView {
        id: listView
        x: 15
        y: 68
        width: 608
        height: 394
        delegate: Item {
            x: 5
            width: parent.width
            height: 40

            Rectangle {
                id: receiptRectangle
                width: parent.width - 10  // this is the 'x' above * 2
                height: 40
                color: index % 2 == 0 ? "#EEEEEE" : "#CCCCCC"

                Row{
                    id: row1
                    spacing: 20

                    Text {
                        text: date
                        anchors.verticalCenter: parent.verticalCenter
                        width: 70
                        horizontalAlignment: Text.AlignRight
                    }

                    Text {
                        text: amount
                        anchors.verticalCenter: parent.verticalCenter
                        width: 170
                         horizontalAlignment: Text.AlignRight
                    }

                    Text {
                        text: businessName
                        anchors.verticalCenter: parent.verticalCenter
                    }

                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {

                        var test = index
                        var receiptItem = receiptListModel.get(index)
                        if( receiptItem.isSelected === "yes" ){
                            receiptItem.isSelected = ""
                            parent.color = index % 2 == 0 ? "#EEEEEE" : "#CCCCCC"
                        }else{
                            receiptItem.isSelected = "yes"
                            parent.color = "#999999"
                        }

                        receiptListModel.set( index, receiptItem )
                    }
                }
            }
        }
        model: ListModel {
            id: receiptListModel

            // create some test entries
            ListElement {
                date: "1/1/2001"
                amount: "$9999.00 ($9000.00 + $999.00)"
                businessName: "Test1"
                isSelected: ""
            }
            ListElement {
                date: "6/18/2009"
                amount: "$1.99"
                businessName: "Test2"
                isSelected: ""
            }
            ListElement {
                date: "5/21/2021"
                amount: "$419.99"
                businessName: "Test3"
                isSelected: ""
            }
        }
    }

    function addReceipt(date,amount,bTipped,tip,businessName) {
        var totalNumber = Number(amount)
        if( bTipped )totalNumber += Number(tip)
        var totalAmount = "$" + totalNumber
        var tippedAmount = (bTipped) ? "  ($" + amount + " + $" + tip + ")" : ""
        totalAmount += tippedAmount
        listModel.append( {date: date, amount: totalAmount, businessName: businessName, isSelected: ""} )
    }

}
