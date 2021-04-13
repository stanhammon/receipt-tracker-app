import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQml 2.12

ApplicationWindow {
    id: mainwindow
    width: 640
    height: 480
    visible: true
    title: qsTr("Scroll")

    Repeater{
        id: standardButtonsRepeater
        model: 1
        delegate: StandardButtons {  }
    }

    Repeater{
        id: deleteButtonsRepeater
        model: 1
        delegate: DeleteButtons { visible: false }
    }

    function setColor( index, useCase ){
        if( index%2  === 0 ){
            if( useCase === "normal" )return "#EEEEEE"
            else if( useCase === "singleClicked" )return "#CCEECC"
            else if( useCase === "doubleClicked" )return "#EECCCC"
        }else{
            if( useCase === "normal" )return "#CCCCCC"
            else if( useCase === "singleClicked" )return "#AACCAA"
            else if( useCase === "doubleClicked" )return "#CCAAAA"
        }
        return "#FFFFOO"  // yellow indicates a logic failure above
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
                color: setColor( index, "normal" )

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


                /////////////standardButtonsRepeater.itemAt(0).setShowHiddenButtonVisibility(true)

                MouseArea {
                    id: receiptItemMouseArea
                    anchors.fill: parent
                    function singleClick(){
                        //listView.testCurrentSelectionType()
                        if( listView.currentSelectionType !== "double" ){  // proceed for "" and "single"
                            var receiptItem = receiptListModel.get(index)
                            if( receiptItem.selectionType !== "" ){
                                receiptItem.selectionType = ""
                                parent.color = setColor( index, "normal" )
                            }else{
                                receiptItem.selectionType = "single"
                                parent.color = setColor( index, "singleClicked" )
                            }
                            listView.testCurrentSelectionType()

                            receiptListModel.set( index, receiptItem )
                        }
                    }
                    function doubleClick(){
                        //listView.testCurrentSelectionType()  add this to a startup
                        if( listView.currentSelectionType !== "single" ){  // proceed for "" and "double"
                            var receiptItem = receiptListModel.get(index)
                            if( receiptItem.selectionType !== "" ){
                                receiptItem.selectionType = ""
                                parent.color = setColor( index, "normal" )
                            }else{
                                receiptItem.selectionType = "double"
                                parent.color = setColor( index, "doubleClicked" )
                            }
                            listView.testCurrentSelectionType()

                            receiptListModel.set( index, receiptItem )
                        }
                    }
                    Timer{
                        id: clickTimer
                        interval: 200
                        onTriggered: receiptItemMouseArea.singleClick()
                    }
                    onClicked: {
                        if( clickTimer.running ){
                            doubleClick()
                            clickTimer.stop()
                        }else{
                            clickTimer.restart()
                        }
                    }
                }
            }
        }

        // this variable contains the currently active selection mode (after being update by 'testCurrentSelectionType()')
        property var currentSelectionType: ""

        //  this function is used to limit selection to a single type at a time (either singleclick of doubleclick)
        function testCurrentSelectionType(){
            currentSelectionType = ""
            for (var i=0; i<receiptListModel.count; i++ ){
                var thisType = receiptListModel.get(i).selectionType
                if( thisType !== "" ){
                    currentSelectionType = thisType
                    break
                }
            }
            if( currentSelectionType === "single" ){
                standardButtonsRepeater.itemAt(0).visible = false
                deleteButtonsRepeater.itemAt(0).visible = false
            }else if( currentSelectionType === "double" ){
                standardButtonsRepeater.itemAt(0).visible = false
                deleteButtonsRepeater.itemAt(0).visible = true
            }else{
                standardButtonsRepeater.itemAt(0).visible = true
                deleteButtonsRepeater.itemAt(0).visible = false
            }
        }

        model: ListModel {
            id: receiptListModel

            // create some test entries
            ListElement {
                date: "1/1/2001"
                amount: "$9999.00 ($9000.00 + $999.00)"
                businessName: "Test1"
                selectionType: ""
            }
            ListElement {
                date: "6/18/2009"
                amount: "$1.99"
                businessName: "Test2"
                selectionType: ""
            }
            ListElement {
                date: "5/21/2021"
                amount: "$419.99"
                businessName: "Test3"
                selectionType: ""
            }
        }
    }

    function addReceipt(date,amount,bTipped,tip,businessName) {
        var totalNumber = Number(amount)
        if( bTipped )totalNumber += Number(tip)
        var totalAmount = "$" + totalNumber
        var tippedAmount = (bTipped) ? "  ($" + amount + " + $" + tip + ")" : ""
        totalAmount += tippedAmount
        receiptListModel.append( {date: date, amount: totalAmount, businessName: businessName, selectionType: ""} )
    }

}
