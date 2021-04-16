import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQml 2.12

ApplicationWindow {
    id: mainwindow
    width: 640
    height: 480
    visible: true
    title: qsTr("Scroll")

    property var wasActive: "none"
    property var isActive: "standardButtons"
    property var nextActive: "none"
    property var animationDuration: 1000

    Repeater{
        id: standardButtonsRepeater
        model: 1
        delegate: StandardButtons {  }
    }

    Repeater{
        id: deleteButtonsRepeater
        model: 1
        delegate: DeleteButtons {  }
    }

    Repeater{
        id: hideButtonsRepeater
        model: 1
        delegate: HideButtons {  }
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
                //standardButtonsRepeater.itemAt(0).visible = false
                //deleteButtonsRepeater.itemAt(0).visible = false
                if( isActive != "hideButtons" ){
                    wasActive = isActive
                    isActive = "none"
                    nextActive = "hideButtons"
                }
            }else if( currentSelectionType === "double" ){
                if( isActive != "deleteButtons" ){
                    wasActive = isActive
                    isActive = "none"
                    nextActive = "deleteButtons"
                }
            }else{
                if( isActive != "standardButtons" ){
                    wasActive = isActive
                    isActive = "none"
                    nextActive = "standardButtons"
                }
            }
        }

        // this is the visible list model, some items from the true list (hiddenReceiptsModel) may not be included here if they are currently hidden
        model: ListModel {
            id: receiptListModel
        }

        // this is the true list model, containing all receipts whether they are currently visible or not
        ListModel {
            id: hiddenReceiptsModel

            // create some test entries
            ListElement {
                date: "1/1/2001"
                amount: "$9999.00 ($9000.00 + $999.00)"
                businessName: "Test1"
                selectionType: ""
                isVisible: true
                uuid: 1
            }
            ListElement {
                date: "6/18/2009"
                amount: "$1.99"
                businessName: "Test2"
                selectionType: ""
                isVisible: true
                uuid: 2
            }
            ListElement {
                date: "5/21/2021"
                amount: "$419.99"
                businessName: "Test3"
                selectionType: ""
                isVisible: true
                uuid: 3
            }

            Component.onCompleted: listView.updateListModel()
        }

        function updateListModel(bResetSelectionType){
            receiptListModel.clear()
            var bHasHiddenReceipts = false

            for( var i=0; i<hiddenReceiptsModel.count; i++ ){
                var itemCopy = hiddenReceiptsModel.get(i)
                if( itemCopy.isVisible === true )
                    receiptListModel.append(itemCopy)
                else
                    bHasHiddenReceipts = true;
            }
            if( bResetSelectionType === true )
                testCurrentSelectionType()

            // show the Unhide Receipts button, if needed
            standardButtonsRepeater.itemAt(0).setShowHiddenButtonVisibility(bHasHiddenReceipts)
        }
    }

    function addReceipt(date,amount,bTipped,tip,businessName) {
        var totalNumber = Number(amount)
        if( bTipped )totalNumber += Number(tip)
        var totalAmount = "$" + totalNumber
        var tippedAmount = (bTipped) ? "  ($" + amount + " + $" + tip + ")" : ""
        totalAmount += tippedAmount
        var uid = Date.now()  // using milliseconds since Unix Epoch (1/1/1970) as a UID - fine since receipts have to be manually entered
        receiptListModel.append( {date: date, amount: totalAmount, businessName: businessName, selectionType: "", parentRefernce: "", isVisible:true, uid} )
        hiddenReceiptsModel.append( {date: date, amount: totalAmount, businessName: businessName, selectionType: "", parentRefernce: "", isVisible:true, uid} )
    }

}
