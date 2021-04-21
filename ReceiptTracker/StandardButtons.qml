import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQml 2.12

Item{
    // these properties are used to block a loop condition bouncing between the two transition animations
    property bool bBlockNextTimer: false
    property bool bBlockWasTimer: false

    // We have to use Timers (even 0 time timers), because you "can't trigger a state change from a state change"
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

    // allows for the shwoing/hiding of this button when needed
    function setShowHiddenButtonVisibility( bShow ){ button_ShowHidden.visible = bShow }

    Row{
        id: standardButtonsRow
        width: mainwindow.width

        // contains the three possible positions of the button row: offscreen-left, on screen, and offscreen-right
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

        // define the two transition between the states defined above: left-hidden to visible, and visible to right-hidden
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

        // triggers the addition of a new receipt through AddReceipt.qml
        Button {
            id: button_Add
            anchors.left: parent.left
            anchors.margins: 30
            text: qsTr("Add Receipt")
            font.pointSize: mainwindow.buttonFontSize
            onClicked: {
                var component = Qt.createComponent("AddReceipt.qml")
                var window    = component.createObject(mainwindow)
            }
        }

        // when visible, will trigger unhide of all hidden receipts
        Button {
            id: button_ShowHidden
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 30
            text: qsTr("Show Hidden")
            font.pointSize: mainwindow.buttonFontSize
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

        // triggers the copying of all receipts (even if hidden) to the system clipboard for pasting into email, etc
        Button {
            id: button_Copy
            anchors.right: parent.right
            anchors.margins: 30
            text: qsTr("Copy")
            font.pointSize: mainwindow.buttonFontSize
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
