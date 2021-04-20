import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQml 2.12

Item{
    property bool bBlockNextTimer: false
    property bool bBlockWasTimer: false
    Timer{
        id: nextActiveTimerStandard
        interval: 0
        onTriggered: {
            if( !bBlockNextTimer ){
                //mainwindow.wasActive = "none"
                mainwindow.isActive = "standardButtons"
                mainwindow.nextActive = "none"
                bBlockWasTimer = true
            }
            bBlockNextTimer = false
        }
    }
    Timer{
        id: wasActiveTimerStandard
        interval: mainwindow.animationDuration
        onTriggered: {
            if( !bBlockWasTimer ){
                //mainwindow.wasActive = "none"
                standardButtonsRow.state = "preActiveStandard"
                bBlockNextTimer = true
            }
            bBlockWasTimer = false
        }
    }

    function setShowHiddenButtonVisibility( bShow ){ button_ShowHidden.visible = bShow }

    Row{
        id: standardButtonsRow
        width: mainwindow.width

        property var testInt: -1

        states: [
            State {
                name: "preActiveStandard"; when: mainwindow.nextActive === "standardButtons"
                PropertyChanges { target: standardButtonsRow; x: -mainwindow.width }
                StateChangeScript{
                    name: "preScriptStandard"
                    script: {
                        nextActiveTimerStandard.start()
                    }
                }
            },
            State {
                name: "activeStandard"; when: mainwindow.isActive === "standardButtons"
                PropertyChanges { target: standardButtonsRow; x: 0 }
            },
            State {
                name: "postActiveStandard"; when: mainwindow.wasActive === "standardButtons"
                PropertyChanges { target: standardButtonsRow; x: mainwindow.width }
                StateChangeScript{
                    name: "postScriptStandard"
                    script: wasActiveTimerStandard.start()
                }
            }
        ]
        transitions: [
            Transition {
                from: "preActiveStandard"; to: "activeStandard";
                PropertyAnimation{ property: "x"; duration: animationDuration; easing.type: Easing.InOutQuad }
                //ScriptAction { scriptName: "preScriptStandard" }
            },
            Transition {
                from: "activeStandard"; to: "postActiveStandard";
                PropertyAnimation{ property: "x"; duration: animationDuration; easing.type: Easing.InOutQuad }
                //ScriptAction { scriptName: "postScriptStandard" }
            }
        ]

        Button {
            id: button_Add
            anchors.left: parent.left
            anchors.margins: 30
            text: qsTr("Add Receipt")
            onClicked: {
                var component = Qt.createComponent("AddReceipt.qml")
                var window    = component.createObject(mainwindow)
                //window.show()
            }
        }

        Button {
            id: button_ShowHidden
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 30
            text: qsTr("Show Hidden")
            visible: false
            property alias showHidden_buttonVisibility : button_ShowHidden.visible
            onClicked: {
                for (var j=0; j<hiddenReceiptsModel.count; j++ ){
                    var hiddenListItem = hiddenReceiptsModel.get(j)
                    if( hiddenListItem.isVisible === false ){
                        hiddenListItem.isVisible = true
                        hiddenReceiptsModel.set(j,hiddenListItem)
                    }
                }
                listView.updateListModel(true)
                mainwindow.saveListModel()
            }
        }

        Button {
            id: button_Copy
            anchors.right: parent.right
            anchors.margins: 30
            text: qsTr("Copy")
            onClicked: {
                clipboardTextEdit.text = ""

                // write all the receipts to the hidden TextEdit
                for( var i=0; i<hiddenReceiptsModel.count; i++ ){
                    var receiptText = ""
                    var receipt = hiddenReceiptsModel.get(i)
                    receiptText = receipt.date + "   " + receipt.amount + "   " + receipt.businessName
                    clipboardTextEdit.append(receiptText)
                }

                // copy the contents of the hidden TextEdit to the system clipboard (for pasting into an email, or the like)
                clipboardTextEdit.selectAll()
                clipboardTextEdit.copy()
            }
        }
    }
}
