import QtQuick
import QtQuick.Controls
import FitToLift
import QtQuick.Studio.Components
import QtQuick.Studio.DesignEffects
import QtQuickUltralite.Layers

Column {
    id: column
    width: 1280
    height: 720
    visible: true
    anchors.fill: parent

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
        placeholderText: "Full Name"
        height: 75
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
        placeholderText: "Height"
        height: 75
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
        onClicked: goToConfiguration()
    }

    function isHeightValid(text) {
        return text.length === 2 && /^[0-9]+$/.test(text)
    }

}
