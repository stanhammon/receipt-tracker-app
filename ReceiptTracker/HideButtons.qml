import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQml 2.12

Item{
    property bool bBlockNextTimer: false
    property bool bBlockWasTimer: false
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

    Row{
        x: -mainwindow.width
        id: hideButtonsRow
        width: mainwindow.width

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

        Button {
            id: button_ClearSelection2
            anchors.right: parent.right
            anchors.margins: 30
            text: qsTr("Clear Selection")
            font.pointSize: mainwindow.buttonFontSize
            onClicked: {
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
