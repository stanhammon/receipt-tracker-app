import QtQuick 2.12
import QtQuick.Controls 2.5

Item {
    anchors.centerIn: parent
    id: root
    property date receiptDate: new Date()

    Rectangle {
        anchors.centerIn: parent
        id: rootRectangle
        x: 0
        y: 0
        width: 400
        height: 330
        color: "#999999"

        Text {
            id: text_Date
            x: 135
            y: 15
            width: 244
            height: 62
            text: receiptDate.toLocaleDateString().split(',').slice(1).join(',') // 'split' and 'slice' operations remove the day of week from date string
            font.pixelSize: 18
            verticalAlignment: Text.AlignVCenter
        }

        Button {
            id: button_Decrement
            x: 27
            y: 13
            width: 95
            height: 62
            text: qsTr("Decrement\nDate")
            onClicked: {
                var changeableDate = receiptDate
                changeableDate.setDate( changeableDate.getDate() - 1 )
                receiptDate = changeableDate
                var dateString = receiptDate.toLocaleDateString()
                text_Date.text = dateString.split(',').slice(1).join(',') // 'split' and 'slice' operations remove the day of week from date string
            }
        }

        TextField {
            id: textInput_Amount
            x: 135
            y: 97
            width: 181
            height: 35
            font.pixelSize: 18
            verticalAlignment: Text.AlignVCenter
            bottomPadding: (height - font.pixelSize)/2
            background: Rectangle {
                radius: 4
                //implicitWidth: parent.width
                //implicitHeight: parent.height
                border.color: "#333"
                border.width: 1
            }
            leftPadding: currencyLabel.width + currencyLabel.anchors.leftMargin + 2
            validator: RegExpValidator {
                regExp: /([+-]?[0-9]+(\.[0-9]{2})?)/
            }
            Text {
                id: currencyLabel
                anchors {
                    top: parent.top; bottom: parent.bottom
                    left: parent.left; leftMargin: 5
                }
                verticalAlignment: Text.AlignVCenter
                color: parent.color
                font.pixelSize: parent.font.pixelSize
                bottomPadding: (height - font.pixelSize)/2
                text: qsTr("$")
            }
        }

        TextField {
            id: textInput_Business
            x: 135
            y: 155
            width: 181
            height: 35
            //text: qsTr("Text Input")
            verticalAlignment: TextField.AlignVCenter
            font.pixelSize: 18
            leftPadding: currencyLabel.anchors.leftMargin + 2
            bottomPadding: (height - font.pixelSize)/2
            background: Rectangle {
                radius: 4
                //implicitWidth: parent.width
                //implicitHeight: parent.height
                border.color: "#333"
                border.width: 1
            }
        }

        Button {
            id: button_Cancel
            x: 87
            y: 266
            width: 92
            height: 48
            text: qsTr("Cancel")
            onClicked: {
                rootRectangle.visible = false
            }
        }

        Button {
            id: button_Save
            x: 234
            y: 267
            width: 92
            text: qsTr("Save")
            onClicked: {
                mainwindow.addReceipt()
                rootRectangle.visible = false
            }
        }

        Text {
            id: text1
            x: 14
            y: 102
            width: 107
            height: 25
            text: qsTr("Amount")
            font.pixelSize: 18
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            id: text2
            x: 14
            y: 160
            width: 107
            height: 25
            text: qsTr("Business")
            font.pixelSize: 18
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
        }

        TextField {
            id: textInput_TipAmount
            x: 135
            y: 211
            width: 181
            height: 35
            font.pixelSize: 18
            verticalAlignment: Text.AlignVCenter
            text: "0.00"
            enabled: false
            Text {
                id: currencyLabel1
                color: parent.color
                text: qsTr("$")
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                font.pixelSize: parent.font.pixelSize
                verticalAlignment: Text.AlignVCenter
                anchors.leftMargin: 5
                bottomPadding: (height - font.pixelSize)/2
            }
            background: Rectangle {
                radius: 4
                border.color: "#333333"
                border.width: 1
            }
            validator: RegExpValidator {
                regExp: /([+-]?[0-9]+(\.[0-9]{2})?)/
            }
            leftPadding: currencyLabel1.width + currencyLabel1.anchors.leftMargin + 2
            bottomPadding: (height - font.pixelSize)/2
        }

        CheckBox {
            id: checkBox_Tippable
            x: 14
            y: 205
            width: 113
            height: 48
            text: qsTr("Tippable")
            onClicked: {
                textInput_TipAmount.enabled = checked
            }
        }

    }

    /*
    DatePickerDialog {
         id: tDialog
         titleText: "Date of birth"
         onAccepted: callbackFunction()
     }

     function launchDialog() {
         tDialog.open();
     }

     function launchDialogToToday() {
         var d = new Date();
         tDialog.year = d.getFullYear();
         tDialog.month = d.getMonth();
         tDialog.day = d.getDate();
         tDialog.open();
     }

     function callbackFunction() {
         result.text = tDialog.year + " " + tDialog.month + " " + tDialog.day
     }
    */

}
