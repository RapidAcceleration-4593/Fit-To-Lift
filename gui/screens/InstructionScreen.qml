import QtQuick
import QtQuick.Controls
import "../themes"

Item {
    id: instructionScreen
    visible: true

    property string testName: services.getCurrentTestName()
    property string instructionsText: services.getCurrentTestInstructions()

    signal goToTest()
    signal goToHomeScreen()
    signal goToInstructions()
    signal goToConfiguration()

    // Title Label
    Label {
        id: titleLabel
        text: testName
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
        id: instructionsLabel
        text: "Instructions:\n"+ instructionsText
        width: 800; height: 50
        anchors {
            top: parent.top; topMargin: 320
            horizontalCenter: parent.horizontalCenter
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        font {
            family: Theme.fontFamily
            pointSize: Theme.instructionFontSize
        }
    }

    // Repetition Label
    Label {
        id: repetitionLabel
        height: 30
        visible: true
        text: "Repetition #" + services.getCurrentRepetition()
        anchors {
            top: parent.top; topMargin: 185
            horizontalCenter: parent.horizontalCenter
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font {
            family: Theme.fontFamily
            pointSize: Theme.instructionFontSize
        }
        color: Theme.repTextColor
    }

    // Configuration Settings
    Image {
        id: settingsImage
        property url defaultSource: "../resources/gear.png"
        property url pressedSource: "../resources/gear_filled.png"
        source: defaultSource
        width: 95; height: 95
        anchors {
            left: parent.left; leftMargin: 15
            bottom: parent.bottom; bottomMargin: 15
        }

        Timer {
            id: downTimer
            interval: 150
            repeat: false
            onTriggered: parent.source = parent.defaultSource
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                parent.source = parent.pressedSource
                downTimer.start()
                goToConfiguration()
            }
        }
    }

    // Begin button
    Button {
        text: "Begin"
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
        onClicked: goToTest()
    }
}
