import QtQuick
import QtQuick.Controls
import "themes"

Window {
    id: window
    visible: true
    width: 1280; height: 720
    title: "Fit To Lift"

    property bool keyboardVisible: false

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: "screens/HomeScreen.qml"
        background: Rectangle { color: "#1E1E1E" }
    }

    // Watermark
    Label {
        text: "Designed & Manufactured by Rapid Acceleration"
        anchors {
            bottom: parent.bottom; bottomMargin: 8
            horizontalCenter: parent.horizontalCenter
        }
        font.family: Theme.fontFamily
        font.pointSize: 12
        opacity: 0.6
        visible: !window.keyboardVisible
    }

    Connections {
        target: stackView.currentItem
        function onGoToHomeScreen() { stackView.push("screens/HomeScreen.qml") }
        function onGoToConfiguration() { 
            stackView.push("screens/ConfigurationScreen.qml")
            services.goToTestingHeight()
        }
        function onGoToInstructions() { stackView.push("screens/InstructionScreen.qml") }
        function onGoToTest() { stackView.push("screens/TestScreen.qml", StackView.Immediate) }
    }
}
