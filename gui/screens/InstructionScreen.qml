import QtQuick
import QtQuick.Controls

Item {
    id: instructionScreen
    width: 1280
    height: 720
    visible: true
    anchors.fill: stackView.view

    property string testName: services.getCurrentTestName()
    property string instructionsText: services.getCurrentTestInstructions()

    signal goToTest()
    signal goToHomeScreen()
    signal goToInstructions()
    signal goToConfiguration()
    
    // Title
    Label {
        id: titleLabel
        text: testName
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
            family: "Space Mono"
            pointSize: 56
            styleName: "Bold"
        }
    }

    // Instructions
    Label {
        id: instructionsLabel
        text: "Instructions:\n"+ instructionsText
        height: 50
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: 150
            rightMargin: 150
            topMargin: 320
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        font {
            family: "Space Mono"
            pointSize: 20
        }
    }

    // Repetition Label
    Label {
        id: repetitionLabel
        height: 30
        visible: true
        text: "Repetition #" + services.getCurrentRepetition()
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 200
        anchors.rightMargin: 200
        anchors.topMargin: 185
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pointSize: 18
        font.family: "Space Mono"
        color: "#cdcdcd"
    }

    // Begin button
    Button {
        id: beginButton
        text: "Begin"
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
            family: "Space Mono"
            pointSize: 22
            bold: true
            letterSpacing: 2
        }
        onClicked: goToTest()
    }
}
