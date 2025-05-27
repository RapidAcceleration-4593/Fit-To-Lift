import QtQuick
import QtQuick.Controls
import "scripts/TestManager.js" as TestManager

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
            initialItem: "screens/HomeScreen.qml"
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
        onGoToHomeScreen: stackView.push("screens/HomeScreen.qml")
        onGoToConfiguration: stackView.push("screens/ConfigurationScreen.qml")
        onGoToInstructions: stackView.push("screens/InstructionScreen.qml")
        onGoToTest: stackView.push("screens/TestScreen.qml")
    }
}
