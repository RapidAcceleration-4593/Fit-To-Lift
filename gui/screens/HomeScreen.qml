import QtQuick
import QtQuick.Controls
import "../components"

Item {
    id: homeScreen
    width: 1280
    height: 720
    visible: true
    anchors.fill: stackView.view

    signal goToTest()
    signal goToHomeScreen()
    signal goToInstructions()
    signal goToConfiguration()

    // Title Label
    Label {
        id: titleLabel
        text: "Fit To Lift"
        height: 100
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: 0
            rightMargin: 0
            topMargin: 75
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font {
            bold: true
            family: "Space Mono"
            pointSize: 56
        }
    }

    // Instructions Label
    Label {
        id: instructionsLabel
        text: "Please enter the user's name and height, in inches, below:"
        height: 30
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: 0
            rightMargin: 0
            topMargin: 240
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font {
            bold: true
            family: "Space Mono"
            pointSize: 20
        }
    }

    // Name Input TextField
    TextField {
        id: nameField
        height: 75
        placeholderText: "Full Name"
        onFocusChanged: {
            if (focus) {
                keyboard.visible = true
                keypad.visible = false
                keyboard.targetField = nameField
            }
        }
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: 300
            rightMargin: 300
            topMargin: 310
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font {
            family: "Space Mono"
            pointSize: 24
        }
        selectionColor: "#ffffff"
        cursorVisible: true
    }

    // Height Input TextField
    TextField {
        id: heightField
        height: 75
        placeholderText: "Height (inches)"
        onFocusChanged: {
            if (focus) {
                keypad.visible = true
                keyboard.visible = false
                keypad.targetField = heightField
            }
        }
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: 450
            rightMargin: 450
            topMargin: 410
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.strikeout: false
        font {
            family: "Space Mono"
            pointSize: 24
        }
        selectionColor: "#ffffff"
        cursorVisible: true

    }

    // Submit Button
    Button {
        id: submitButton
        text: "Submit"
        height: 75
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: 500
            rightMargin: 500
            topMargin: 515
        }
        font {
            bold: true
            family: "Space Mono"
            pointSize: 22
        }
        enabled: nameField.text.length > 0 && isHeightValid(heightField.text)
        onClicked: {
            services.setSubjectName(nameField.text)
            services.setSubjectHeight(parseInt(heightField.text))
            goToConfiguration()
        }
    }

    function isHeightValid(text) {
        return text.length === 2 && /^[0-9]+$/.test(text)
    }

    CustomKeyboard {
        id: keyboard
    }

    CustomKeypad {
        id: keypad
    }
}
