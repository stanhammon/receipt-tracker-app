import QtQuick 2.12
import QtQuick.Controls 2.5

Item{
    //Row{
    //    id: standardButtonsRow

        function setShowHiddenButtonVisibility( bShow ){ button_ShowHidden.visible = bShow }

        Button {
            id: button_Add
            x: 25
            y: 14
            text: qsTr("Add Receipt")
            onClicked: {
                var component = Qt.createComponent("AddReceipt.qml")
                var window    = component.createObject(mainwindow)
                //window.show()
            }
        }

        Button {
            id: button_ShowHidden
            x: 250
            y: 14
            text: qsTr("Show Hidden")
            visible: false
            property alias showHidden_buttonVisibility : button_ShowHidden.visible
            onClicked: {
                /*
                var component = Qt.createComponent("AddReceipt.qml")
                var window    = component.createObject(mainwindow)
                */
            }
        }

        Button {
            id: button_Copy
            x: 500
            y: 14
            text: qsTr("Copy")
            onClicked: {
                /*
                var component = Qt.createComponent("AddReceipt.qml")
                var window    = component.createObject(mainwindow)
                */
            }
        }
    //}
}
