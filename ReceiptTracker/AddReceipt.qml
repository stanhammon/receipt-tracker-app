import QtQuick 2.12
import QtQuick.Controls 2.5

Item {
    anchors.centerIn: parent
    x: 0
    y: 0
    id: root
    property date receiptDate: new Date()

    // invisible rectangle used to catch clicks outside of the visible gui area
    Rectangle{
        id:cancelClickRectangle
        anchors.centerIn: parent
        width: mainwindow.width
        height: mainwindow.height
        color: "transparent"

        // this mouse area catches clicks outside the 'Add Receipt' pop-up and cancels the pop-up
        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true  // this passes clicks within the pop-up to the pop-up's MouseArea (so they can be ignored)
            onClicked: button_Cancel.onClicked()
        }
    }

    // contains the visible gui area
    Rectangle {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -mainwindow.height/6  // is offset "up" on the screen to not interfere with the keyboard, when it appears

        id: rootRectangle
        x: 0
        y: 0
        width: 400
        height: 330
        color: "#999999"

        // this MouseArea is only here to catch (and ignore) any clicks on the pop-up, so they don't triggger a Cancel from the invisible rectangle above
        MouseArea {
            anchors.fill: parent
        }

        // receipt date
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

        // decrements the receipt date one day per click (if needed)
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

        // label text
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

        // input field for the receipt amount
        TextField {
            id: textInput_Amount
            x: 135
            y: 97
            width: 181
            height: 35
            font.pixelSize: 18
            verticalAlignment: Text.AlignVCenter
            bottomPadding: (height - font.pixelSize)/2
            inputMethodHints: Qt.ImhDigitsOnly  // request that a number keyboard be displayed
            background: Rectangle {
                radius: 4
                //implicitWidth: parent.width
                //implicitHeight: parent.height
                border.color: "#333"
                border.width: 1
            }
            leftPadding: currencyLabel.width + currencyLabel.anchors.leftMargin + 2
            validator: RegExpValidator {  // only allow input of numeric characters
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

        // label text
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

        // input field for the business name
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

        // enables/disables the tip entry field
        CheckBox {
            id: checkBox_Tipped
            x: 14
            y: 205
            width: 113
            height: 48
            text: qsTr("Tipped")
            onClicked: {
                textInput_TipAmount.enabled = checked
                if(checked){
                    text1.text="Pre-tip"
                    textInput_TipAmount.text = ""
                }else{
                    text1.text="Amount"
                    textInput_TipAmount.text = "0.00"
                }
            }
        }

        // input field for the tip
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
            inputMethodHints: Qt.ImhDigitsOnly  // request that a number keyboard be displayed
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
            validator: RegExpValidator {  // only allow input of numeric characters
                regExp: /([+-]?[0-9]+(\.[0-9]{2})?)/
            }
            leftPadding: currencyLabel1.width + currencyLabel1.anchors.leftMargin + 2
            bottomPadding: (height - font.pixelSize)/2
        }

        // cancels (and hides) the form
        Button {
            id: button_Cancel
            x: 87
            y: 266
            width: 92
            height: 48
            text: qsTr("Cancel")
            onClicked: {
                rootRectangle.visible = false
                cancelClickRectangle.visible = false
            }
        }

        // adds the new receipt to the ListView, and triggers saving out to disk
        Button {
            id: button_Save
            x: 234
            y: 267
            width: 92
            text: qsTr("Save")
            onClicked: {
                // first, ensure that there is a usable input
                var amountNumber = Number(textInput_Amount.text)
                var tipNumber = Number(textInput_TipAmount.text)
                var bContinue = true
                if( textInput_Business.text.trim()== "" )bContinue = false
                if( amountNumber===0.0 && tipNumber===0.0 )bContinue = false

                if( bContinue ){
                    var shortDate = receiptDate.toLocaleDateString(Qt.locale(),"M/d/yyyy")
                    mainwindow.addReceipt(shortDate,textInput_Amount.text,checkBox_Tipped.checked,textInput_TipAmount.text,textInput_Business.text)
                    rootRectangle.visible = false
                    cancelClickRectangle.visible = false
                }
            }
        }

    }

}
