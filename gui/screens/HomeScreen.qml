import QtQuick
import QtQuick.Controls
import "../components"
import "../themes"

Item {
    id: homeScreen
    visible: true

    signal goToTest()
    signal goToHomeScreen()
    signal goToInstructions()
    signal goToConfiguration()

    // Title Label
    Label {
        text: "Fit To Lift"
        height: 100
        anchors {
            top: parent.top; topMargin: 75
            horizontalCenter: parent.horizontalCenter
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font {
            family: Theme.fontFamily
            pointSize: Theme.titleFontSize
            bold: true
        }
    }
    
    // Instructions Label
    Label {
        text: "Please provide the client's name and height, in inches, below:"
        height: 30
        anchors {
            top: parent.top; topMargin: 240
            horizontalCenter: parent.horizontalCenter
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font {
            family: Theme.fontFamily
            pointSize: Theme.headerFontSize
        }
    }

    // Name Input
    TextField {
        id: nameField
        placeholderText: "Full Name"
        width: 680; height: 75
        anchors {
            top: parent.top; topMargin: 310
            horizontalCenter: parent.horizontalCenter
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font {
            family: Theme.fontFamily
            pointSize: Theme.inputFontSize
        }
        selectionColor: "#FFFFFF"
        cursorVisible: true
        onFocusChanged: {
            if (focus) {
                keyboard.visible = true
                keypad.visible = false
                keyboard.targetField = nameField
            }
        }
    }

    // Height Input
    TextField {
        id: heightField
        placeholderText: "Height"
        width: 380; height: 75
        anchors {
            top: parent.top; topMargin: 410
            horizontalCenter: parent.horizontalCenter
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font {
            family: Theme.fontFamily
            pointSize: Theme.inputFontSize
        }
        selectionColor: "#FFFFFF"
        cursorVisible: true
        onFocusChanged: {
            if (focus) {
                keypad.visible = true
                keyboard.visible = false
                keypad.targetField = heightField
            }
        }
    }

    // Submit Button
    Button {
        id: submitButon
        text: "Submit"
        width: 250; height: 75
        anchors {
            top: parent.top; topMargin: 515
            horizontalCenter: parent.horizontalCenter
        }
        font {
            family: Theme.fontFamily
            pointSize: Theme.buttonFontSize
            bold: true
        }
        enabled: nameField.text.length > 0 && isHeightValid(heightField.text)
        onClicked: {
            services.setSubjectName(nameField.text)
            services.setSubjectHeight(parseInt(heightField.text))
            goToInstructions()
        }
    }

    CustomKeyboard { id: keyboard; onVisibleChanged: updateKeyboardVisible() }
    CustomKeypad { id: keypad; onVisibleChanged: updateKeyboardVisible() }

    function isHeightValid(text) { var height = parseInt(text); return /^[0-9]+$/.test(text) && height >= 48 && height <= 84 }
    function updateKeyboardVisible() { window.keyboardVisible = keyboard.visible || keypad.visible }
}
