import QtQuick
import QtQuick.Controls
import "../themes"

Item {
    id: testScreen
    visible: true

    property string testName: services.getCurrentTestName()
    property string instructionsText: services.getCurrentTestInstructions()

    property int preCountdown: 3
    property int testCountdown: 5
    property bool isTesting: false

    signal goToTest()
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
                services.beginMeasuring(5.5)
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
                services.finishMeasuring()

                // TODO: Write results to file.

                services.nextTest()

                if (services.isTestingComplete()) {
                    services.exportSubject()
                    goToHomeScreen()
                } else {
                    goToInstructions()
                }
            }
        }
    }

    // Title Label
    Label {
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

    // Countdown Label
    Label {
        id: countdownLabel
        visible: preTimer.running || testTimer.running
        text: preTimer.running ? "Start Lifting In:" :
              isTesting ? "Time Remaining:" : ""
        width: 800; height: 50
        anchors {
            top: parent.top; topMargin: 300
            horizontalCenter: parent.horizontalCenter
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font {
            family: Theme.fontFamily
            pointSize: Theme.cdTitleFontSize
        }
    }

    // Countdown Label
    Label {
        id: countdownNumberLabel
        visible: preTimer.running || testTimer.running
        text: preTimer.running ? preCountdown :
              isTesting ? testCountdown : ""
        width: 800; height: 50
        anchors {
            top: parent.top; topMargin: 400
            horizontalCenter: parent.horizontalCenter
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font {
            family: Theme.fontFamily
            pointSize: Theme.cdNumberFontSize
        }
    }

    // Repetition Label
    Label {
        id: repetitionLabel
        width: 800; height: 30
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
}
