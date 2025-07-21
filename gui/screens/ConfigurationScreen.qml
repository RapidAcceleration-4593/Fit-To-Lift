import QtQuick
import QtQuick.Controls

Item {
    id: configurationScreen
    visible: true

    signal goToTest()
    signal goToHomeScreen()
    signal goToInstructions()
    signal goToConfiguration()

    // Title
    Label {
        id: titleLabel
        text: "Configuration"
        height: 100
        color: "#ffffff"
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
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
        text: "Please finalize height adjustments, if necessary."
        height: 30
        color: "#ffffff"
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: 150
            rightMargin: 150
            topMargin: 240
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        font {
            family: "Space Mono"
            pointSize: 20
        }
    }

    Image {
        id: upArrowImage
        property url defaultSource: "../resources/arrow.png"
        property url pressedSource: "../resources/arrow_filled.png"
        source: defaultSource
        width: 140
        height: 140
        anchors {
            top: parent.top
            topMargin: 330
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

    Image {
        id: downArrowImage
        property url defaultSource: "../resources/arrow.png"
        property url pressedSource: "../resources/arrow_filled.png"
        source: defaultSource
        width: 140
        height: 140
        anchors {
            top: parent.top
            topMargin: 330
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
        id: beginButton
        text: "Done"
        width: 280
        height: 75
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 515
        }
        font {
            family: "Space Mono"
            pointSize: 22
            bold: true
            letterSpacing: 2
        }
        onClicked: {
            goToInstructions()
        }
    }
}
