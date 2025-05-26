import QtQuick
import QtQuick.Controls
import "TestManager.js" as TestManager

Window {
    id: window
    visible: true
    width: 1280
    height: 720
    title: "Fit To Lift"

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#1e1e1e"

        StackView {
            id: stackView
            anchors.fill: parent
            initialItem: "HomeScreen.qml"
        }
    }

    // Watermark
    Label {
        id: watermarkLabel
        text: "Designed & Manufactured by Rapid Acceleration"
        height: 25
        color: "#cdcdcd"
        anchors {
            left: parent.left
            bottom: parent.bottom
            leftMargin: 8
            bottomMargin: 8
        }
        font {
            family: "Space Mono"
            styleName: "Regular"
            pointSize: 14
        }
    }

    Connections {
        target: stackView.currentItem
        function onGoToHomeScreen() {
            stackView.push("HomeScreen.qml")
        }
        function onGoToConfiguration() {
            stackView.push("ConfigurationScreen.qml")
        }
        function onGoToInstructions() {
            stackView.push("InstructionScreen.qml")
        }
        function onGoToTest() {
            stackView.push("TestScreen.qml")
        }
    }
}
