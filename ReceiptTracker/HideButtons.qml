import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQml 2.12

Item{
    // these properties are used to block a loop condition bouncing between the two transition animations
    property bool bBlockNextTimer: false
    property bool bBlockWasTimer: false

    // We have to use Timers (even 0 time timers), because you "can't trigger a state change from a state change"
    Timer{
        id: nextActiveTimerHide
        interval: 0
        onTriggered: {
            if( !bBlockNextTimer ){
                //mainwindow.wasActive = "none"
                mainwindow.isActive = "hideButtons"
                mainwindow.nextActive = "none"
                bBlockWasTimer = true
            }
            bBlockNextTimer = false
        }
    }
    Timer{
        id: wasActiveTimerHide
        interval: mainwindow.animationDuration
        onTriggered: {
            if( !bBlockWasTimer ){
                //mainwindow.wasActive = "none"
                hideButtonsRow.state = "preActiveHide"
                bBlockNextTimer = true
            }
            bBlockWasTimer = false
        }
    }

    // allows for the shwoing/hiding of this button when needed
    function setShowDuplicateButtonVisibility( bShow ){ button_Duplicate.visible = bShow }

    Row{
        x: -mainwindow.width  // start off out of view (on the left), in the 'preActive' state
        id: hideButtonsRow
        width: mainwindow.width

        // contains the three possible positions of the button row: offscreen-left, on screen, and offscreen-right
        states: [
            State {
                name: "preActiveHide"; when: mainwindow.nextActive === "hideButtons"
                PropertyChanges { target: hideButtonsRow; x: -mainwindow.width }
                StateChangeScript{
                    name: "preScriptHide"
                    script: {
                        nextActiveTimerHide.start()
                    }
                }
            },
            State {
                name: "activeHide"; when: mainwindow.isActive === "hideButtons"
                PropertyChanges { target: hideButtonsRow; x: 0 }
            },
            State {
                name: "postActiveHide"; when: mainwindow.wasActive === "hideButtons"
                PropertyChanges { target: hideButtonsRow; x: mainwindow.width }
                StateChangeScript{
                    name: "postScriptHide"
                    script: wasActiveTimerHide.start()
                }
            }
        ]

        // define the two transition between the states defined above: left-hidden to visible, and visible to right-hidden
        transitions: [
            Transition {
                from: "preActiveHide"; to: "activeHide";
                PropertyAnimation{ property: "x"; duration: animationDuration; easing.type: Easing.InOutQuad }
                //ScriptAction { scriptName: "preScriptHide" }
            },
            Transition {
                from: "activeHide"; to: "postActiveHide";
                PropertyAnimation{ property: "x"; duration: animationDuration; easing.type: Easing.InOutQuad }
                //ScriptAction { scriptName: "postScriptHide" }
            }
        ]

        // copies the values from an old receipt into a new Add Receipt form for easy duplication (intended as aid for common transactions)
        Button {
            id: button_Duplicate
            anchors.left: parent.left
            anchors.margins: 30
            text: qsTr("Duplicate")
            font.pointSize: mainwindow.buttonFontSize
            onClicked: {
                var receipt = mainwindow.getSelectedReceipt()
                if( receipt !== "" ){
                    standardButtonsRepeater.itemAt(0).makeDuplicateReceipt( receipt.amount, receipt.businessName, receipt.bTipped, receipt.tip )
                }
                button_ClearSelection2.clearSelection()
            }
        }

        // triggers the hiding of any currently "single" selected receipts
        Button {
            id: button_Hide
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 30
            text: qsTr("Hide Receipts")
            font.pointSize: mainwindow.buttonFontSize
            onClicked: {
                // hide Receipts that have been marked as 'single'
                if( listView.currentSelectionType === "single" ){
                    for (var i=0; i<receiptListModel.count; i++ ){
                        var listItem = receiptListModel.get(i)
                        if( listItem.selectionType === "single" ){
                            var uid = listItem.uuid
                            for (var j=0; j<hiddenReceiptsModel.count; j++ ){
                                var hiddenListItem = hiddenReceiptsModel.get(j)
                                if( hiddenListItem.uuid === uid ){
                                    hiddenListItem.isVisible = false
                                    hiddenListItem.selectionType = ""
                                    hiddenReceiptsModel.set(j,hiddenListItem)
                                    break
                                }
                            }
                        }
                    }
                    listView.updateListModel(true)
                    mainwindow.saveListModel()
                }
            }
        }

        // unselects any currently "single" selected receipts
        Button {
            id: button_ClearSelection2
            anchors.right: parent.right
            anchors.margins: 30
            text: qsTr("Clear Selection")
            font.pointSize: mainwindow.buttonFontSize
            onClicked: clearSelection()
            function clearSelection(){
                for (var i=0; i<receiptListModel.count; i++ ){
                    var listItem = receiptListModel.get(i)
                    if( listItem.selectionType === "single" ){
                        listItem.selectionType = ""
                        receiptListModel.set(i,listItem)
                    }
                }
                listView.updateListModel(true)
            }
        }
    }
}
