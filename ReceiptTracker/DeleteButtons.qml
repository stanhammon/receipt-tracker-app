import QtQuick 2.12
import QtQuick.Controls 2.5

Item{
    //Row{
    //    id: standardButtonsRow
        Button {
            id: button_Delete
            x: 267
            y: 14
            text: qsTr("Delete")
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
                }
            }
        }

        Button {
            id: button_ClearSelection
            x: 500
            y: 14
            text: qsTr("Clear Selection")
            onClicked: {
                /*
                var component = Qt.createComponent("AddReceipt.qml")
                var window    = component.createObject(mainwindow)
                */
            }
        }
    //}
}
