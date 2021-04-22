import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQml 2.12

ApplicationWindow {
    id: mainwindow
    width: 640
    height: 480
    visible: true
    title: qsTr("Scroll")

    // properties used to trigger state transitions between the different button groupings
    property var wasActive: "none"
    property var isActive: "standardButtons"
    property var nextActive: "none"

    // visual parameters
    property var animationDuration: 750
    property var buttonFontSize: 14
    property var textFontSize: 12

    // instantiate the buttons from StandardButtons.qml
    Repeater{
        id: standardButtonsRepeater
        model: 1
        delegate: StandardButtons {  }
    }

    // instantiate the buttons from DeleteButtons.qml
    Repeater{
        id: deleteButtonsRepeater
        model: 1
        delegate: DeleteButtons {  }
    }

    // instantiate the buttons from HideButtons.qml
    Repeater{
        id: hideButtonsRepeater
        model: 1
        delegate: HideButtons {  }
    }

    // used to set the color of the rows in the receipt ListView
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

    // returns the selected receipt (only one receipt) - should only be used with the Duplicate button
    function getSelectedReceipt(){
        for( var i=0; i<receiptListModel.count; i++ ){
            var receipt = receiptListModel.get(i)
            if( receipt.selectionType === "single" )
                return receipt
        }
        return ""
    }

    ListView {
        id: listView
        x: 5
        y: 60
        width: mainwindow.width-10
        height: mainwindow.height-70
        clip: true

        delegate: Item {
            x: 5
            width: parent.width
            height: 40

            // this is the row that contains an individual receipt
            Rectangle {
                id: receiptRectangle
                width: parent.width - 10  // this is the 'x' above * 2
                height: 40
                color: setColor( index, "normal" )

                Row{
                    anchors.verticalCenter: parent.verticalCenter
                    id: row1
                    spacing: 10

                    Text {
                        font.pointSize: mainwindow.textFontSize
                        text: date
                        anchors.verticalCenter: parent.verticalCenter
                        width: 5.4 * mainwindow.textFontSize
                        horizontalAlignment: Text.AlignRight
                    }

                    Text {
                        font.pointSize: mainwindow.textFontSize
                        text: totalAmount
                        anchors.verticalCenter: parent.verticalCenter
                        width: 12 * mainwindow.textFontSize
                        horizontalAlignment: Text.AlignRight
                    }

                    Text {
                        font.pointSize: mainwindow.textFontSize
                        text: businessName
                        anchors.verticalCenter: parent.verticalCenter
                    }

                }

                // single and double-clicking are used for hiding, and deleting receipts, respectively
                MouseArea {
                    id: receiptItemMouseArea
                    anchors.fill: parent

                    // select/unselect a receipt for hiding
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

                    // select/unselect a receipt for deletion
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

                    // this Timer (and onClicked()) is used to trigger only only click type at a time
                    // by default, single-click is always triggered, even when double-click is also triggered
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
        // valid values are: "", "single", and "double"
        property var currentSelectionType: ""
        property var currentSelectionCount: 0

        //  this function is used to limit selection to a single type at a time (either singleclick of doubleclick)
        function testCurrentSelectionType(){
            currentSelectionType = ""
            currentSelectionCount = 0
            for (var i=0; i<receiptListModel.count; i++ ){
                var thisType = receiptListModel.get(i).selectionType
                if( thisType !== "" ){
                    if( currentSelectionType === "" )  // make the
                        currentSelectionType = thisType
                    currentSelectionCount++
                }
            }

            // show the Duplicate button if only 1 receipt is selected for "hiding"
            if( currentSelectionType === "single" && currentSelectionCount === 1 )
                hideButtonsRepeater.itemAt(0).setShowDuplicateButtonVisibility(true)
            else
                hideButtonsRepeater.itemAt(0).setShowDuplicateButtonVisibility(false)

            // if surrentSelectionType has changed, trigger the transition to another set of gui buttons
            if( currentSelectionType === "single" ){
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

            // this function is called when 'JSON.stringify()' is invoked - needed because QML will by default only output metadata from a ListModel
            function toJSON(){
                var stringified = "["
                for( var i=0; i<hiddenReceiptsModel.count; i++ ){
                    stringified += JSON.stringify(hiddenReceiptsModel.get(i))
                    if( i < hiddenReceiptsModel.count-1)stringified += ","
                }
                stringified = stringified + "]"
                return stringified
            }
        }

        // rebuilds the visible version of the listModel using the isVisible field in the hidden list model as a guide
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

            // show the Unhide Receipts button, if needed (i.e., if there are any hidden receipts present)
            standardButtonsRepeater.itemAt(0).setShowHiddenButtonVisibility(bHasHiddenReceipts)
        }
    }

    // function called by AddReceipt.qml to add a new receipt to the ListView
    function addReceipt(date,amount,bTipped,tip,businessName) {
        var totalNumber = Number(amount)
        if( bTipped )
            totalNumber += Number(tip)
        else
            tip = "0.00"
        var totalAmount = "$" + totalNumber
        var tippedAmount = (bTipped) ? " (" + amount + "+" + tip + ")" : ""
        totalAmount += tippedAmount
        var uid = Date.now()  // using milliseconds since Unix Epoch (1/1/1970) as a UID - fine since receipts have to be manually entered

        var receiptJson = {date:date, totalAmount:totalAmount, businessName:businessName, selectionType:"", isVisible:true, uuid:uid, amount:amount, bTipped:bTipped, tip:tip}
        insertReceiptByDate( receiptJson, date )

        listView.updateListModel(true)
        listView.currentIndex = listView.count-1  // scroll to the newly added receipt
        saveListModel()  // write the updated lsit to file
    }

    // this function adds new receipts at the correct point to maintain date sorting
    function insertReceiptByDate( receipt, dateString ){
        var bInserted = false
        var newReceiptDate = Date.parse(receipt.date)
        for (var i=0; i<hiddenReceiptsModel.count-1; i++ ){
            var receiptDate1 = Date.parse(hiddenReceiptsModel.get(i).date)
            var receiptDate2 = Date.parse(hiddenReceiptsModel.get(i+1).date)

            if( receiptDate1<=newReceiptDate && newReceiptDate<receiptDate2){
                hiddenReceiptsModel.insert(i+1,receipt)
                bInserted = true
                break
            }
        }
        if( bInserted === false )
            hiddenReceiptsModel.append( receipt )
    }

    // load the current list of receipts from file upon starting the program
    Component.onCompleted: loadListModel()

    // this function saves the ListView contents to file (using c++ code in FileIO.h)
    function saveListModel() {
        var datastore = JSON.stringify(hiddenReceiptsModel)
        datastore = JSON.parse(datastore)  // this hack is to remove the extra set of "" being erroniously put around the JSON output
        fileio.write( "receipts.json", datastore )
    }

    // this function restores the ListView contents from JSON (using c++ code in FileIO.h)
    function loadListModel() {
        var datastore = fileio.read( "receipts.json" )
        if (datastore !== ""){
            var datamodel = JSON.parse(datastore)
            hiddenReceiptsModel.clear()
            for (var i = 0; i < datamodel.length; i++){
                hiddenReceiptsModel.append(datamodel[i])
            }
            listView.updateListModel(true)
        }
    }

    // this hidden TextEdit field is only used for copying receipts to the system clipboard - it is never visible
    TextEdit{
        id: clipboardTextEdit
        visible: false
    }

}
