import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQml 2.12

Item{
    // these properties are used to block a loop condition bouncing between the two transition animations
    property bool bBlockNextTimer: false
    property bool bBlockWasTimer: false

    // We have to use Timers (even 0 time timers), because you "can't trigger a state change from a state change"
    Timer{
        id: nextActiveTimerDelete
        interval: 0
        onTriggered: {
            if( !bBlockNextTimer ){
                //mainwindow.wasActive = "none"
                mainwindow.isActive = "deleteButtons"
                mainwindow.nextActive = "none"
                bBlockWasTimer = true
            }
            bBlockNextTimer = false
        }
    }
    Timer{
        id: wasActiveTimerDelete
        interval: mainwindow.animationDuration
        onTriggered: {
            if( !bBlockWasTimer ){
                //mainwindow.wasActive = "none"
                deleteButtonsRow.state = "preActiveDelete"
                bBlockNextTimer = true
            }
            bBlockWasTimer = false
        }
    }

    Row{
        x: -mainwindow.width  // start off out of view (on the left), in the 'preActive' state
        id: deleteButtonsRow
        width: mainwindow.width

        // contains the three possible positions of the button row: offscreen-left, on screen, and offscreen-right
        states: [
            State {
                name: "preActiveDelete"; when: mainwindow.nextActive === "deleteButtons"
                PropertyChanges { target: deleteButtonsRow; x: -mainwindow.width }
                StateChangeScript{
                    name: "preScriptDelete"
                    script: {
                        nextActiveTimerDelete.start()
                    }
                }
            },
            State {
                name: "activeDelete"; when: mainwindow.isActive === "deleteButtons"
                PropertyChanges { target: deleteButtonsRow; x: 0 }
            },
            State {
                name: "postActiveDelete"; when: mainwindow.wasActive === "deleteButtons"
                PropertyChanges { target: deleteButtonsRow; x: mainwindow.width }
                StateChangeScript{
                    name: "postScriptDelete"
                    script: wasActiveTimerDelete.start()
                }
            }
        ]

        // define the two transition between the states defined above: left-hidden to visible, and visible to right-hidden
        transitions: [
            Transition {
                from: "preActiveDelete"; to: "activeDelete";
                PropertyAnimation{ property: "x"; duration: animationDuration; easing.type: Easing.InOutQuad }
                //ScriptAction { scriptName: "preScriptDelete" }
            },
            Transition {
                from: "activeDelete"; to: "postActiveDelete";
                PropertyAnimation{ property: "x"; duration: animationDuration; easing.type: Easing.InOutQuad }
                //ScriptAction { scriptName: "postScriptDelete" }
            }
        ]

        // triggers the deletion of any currently "double" selected receipts
        Button {
            id: button_Delete
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 30
            text: qsTr("Delete")
            font.pointSize: mainwindow.buttonFontSize
            onClicked: {
                // remove Receipts that have been marked as 'double'
                if( listView.currentSelectionType === "double" ){
                    for (var i=0; i<receiptListModel.count; i++ ){
                        if( receiptListModel.get(i).selectionType === "double" ){
                            // find the hidden copy of the receipt and delete it
                            var uid = receiptListModel.get(i).uuid
                            for (var j=0; j<hiddenReceiptsModel.count; j++ ){
                                if( hiddenReceiptsModel.get(j).uuid === uid ){
                                    hiddenReceiptsModel.remove(j);
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

        // unselects any currently "double" selected receipts
        Button {
            id: button_ClearSelection
            anchors.right: parent.right
            anchors.margins: 30
            text: qsTr("Clear Selection")
            font.pointSize: mainwindow.buttonFontSize
            onClicked: {
                for (var i=0; i<receiptListModel.count; i++ ){
                    var listItem = receiptListModel.get(i)
                    if( listItem.selectionType === "double" ){
                        listItem.selectionType = ""
                        receiptListModel.set(i,listItem)
                    }
                }
                listView.updateListModel(true)
            }
        }
    }
}
