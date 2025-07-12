import QtQuick
import QtQuick.Controls

Window {
    id: window
    visible: true
    width: 1280
    height: 720
    title: "Fit To Lift"

    property bool keyboardVisible: false

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: "screens/HomeScreen.qml"
        background: Rectangle {
            color: "#1e1e1e"
        }
    }

    // Watermark
    Label {
        id: watermarkLabel
        text: "Designed & Manufactured by Rapid Acceleration"
        height: 25
        color: "#cdcdcd"
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 8
        }
        font {
            family: "Space Mono"
            styleName: "Regular"
            pointSize: 14
        }
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
