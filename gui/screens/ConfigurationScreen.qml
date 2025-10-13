import QtQuick
import QtQuick.Controls
import "../themes"

Item {
    id: configurationScreen
    visible: true

    signal goToTest()
    signal goToHomeScreen()
    signal goToInstructions()
    signal goToConfiguration()

    // Title Label
    Label {
        text: "Configuration"
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
        text: "Please finalize height adjustments, if necessary."
        height: 30
        anchors {
            top: parent.top; topMargin: 240
            horizontalCenter: parent.horizontalCenter
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font {
            family: Theme.fontFamily
            pointSize: Theme.headerFontSize
        }
    }

    // Up Arrow
    Image {
        id: upArrowImage
        property url defaultSource: "../resources/arrow.png"
        property url pressedSource: "../resources/arrow_filled.png"
        source: defaultSource
        width: 140; height: 140
        anchors {
            top: parent.top; topMargin: 330
        }
        x: parent.width / 2 - width / 2 - 120

        Timer {
            id: upTimer
            interval: 150
            repeat: false
            onTriggered: parent.source = parent.defaultSource
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                parent.source = parent.pressedSource
                upTimer.start()
                services.bumpArmUp()
            }
        }
    }

    // Down Arrow
    Image {
        id: downArrowImage
        property url defaultSource: "../resources/arrow.png"
        property url pressedSource: "../resources/arrow_filled.png"
        source: defaultSource
        width: 140; height: 140
        anchors {
            top: parent.top; topMargin: 330
        }
        x: parent.width / 2 - width / 2 + 120
        rotation: 180

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
                services.bumpArmDown()
            }
        }
    }

    // Done button
    Button {
        text: "Done"
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
        onClicked: {
            goToInstructions()
        }
    }
}
