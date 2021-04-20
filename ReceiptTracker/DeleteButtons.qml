import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQml 2.12

Item{
    property bool bBlockNextTimer: false
    property bool bBlockWasTimer: false
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
        x: -mainwindow.width
        id: deleteButtonsRow
        width: mainwindow.width

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

        Button {
            id: button_Delete
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 30
            text: qsTr("Delete")
            font.pointSize: mainwindow.buttonFontSize
            onClicked: {
                // remove Receipts that have been marked as 'double'
                if( listView.currentSelectionType === "double" ){
                    for (var i=0; i<receiptListModel.count; ){
                        if( receiptListModel.get(i).selectionType === "double" ){
                            receiptListModel.remove(i);
                        }else{
                            i++
                        }
                    }
                    mainwindow.saveListModel()
                }
            }
        }

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
