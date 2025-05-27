import QtQuick
import QtQuick.Controls
import "../scripts/TestManager.js" as TestManager

Item {
    id: testScreen
    width: 1280
    height: 720
    visible: true
    anchors.fill: parent

    property string testName: TestManager.getCurrentTest().name
    property string instructionsText: TestManager.getCurrentTest().instructions

    property int preCountdown: 3
    property int testCountdown: 5
    property bool isTesting: false

    signal goToHomeScreen()
    signal goToInstructions()
    signal goToConfiguration()

    // Timers
    Timer {
        id: preTimer
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            preCountdown--
            if (preCountdown <= 0) {
                preTimer.stop()
                testTimer.start()
                isTesting = true
            }
        }
    }

    Timer {
        id: testTimer
        interval: 1000
        repeat: true
        onTriggered: {
            testCountdown--
            if (testCountdown <= 0) {
                testTimer.stop()
                isTesting = false

                // TODO: Write results to file.

                TestManager.nextTest()

                if (TestManager.isTestingComplete()) {
                    goToHomeScreen()
                } else if (TestManager.getCurrentRepetition() === 1) {
                    goToConfiguration()
                } else {
                    goToInstructions()
                }
            }
        }
    }

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

    // Countdown label
    Label {
        id: countdownLabel
        visible: preTimer.running || testTimer.running
        text: preTimer.running ? "Start Lifting in" :
              isTesting ? "Time Remaining:" : ""
        height: 50
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: 200
            rightMargin: 200
            topMargin: 300
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font {
            family: "Space Mono"
            pointSize: 32
        }
    }

    // Countdown label
    Label {
        id: countdownNumberLabel
        visible: preTimer.running || testTimer.running
        text: preTimer.running ? preCountdown :
              isTesting ? testCountdown : ""
        height: 50
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: 200
            rightMargin: 200
            topMargin: 400
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font {
            family: "Space Mono"
            pointSize: 42
        }
    }

    // Repetition Label
    Label {
        id: repetitionLabel
        height: 30
        visible: true
        text: "Repetition #" + TestManager.getCurrentRepetition()
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
}
