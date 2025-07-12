import QtQuick
import QtQuick.Controls

Item {
    id: configurationScreen
    width: 1280
    height: 720
    visible: true
    anchors.fill: stackView

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
        property url defaultSource: "../images/arrow.png"
        property url pressedSource: "../images/arrow_filled.png"

        source: defaultSource
        height: 130
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 450
        anchors.rightMargin: 700
        anchors.topMargin: 330

        Timer {
            id: upTimer
            interval: 350
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
        property url defaultSource: "../images/arrow.png"
        property url pressedSource: "../images/arrow_filled.png"

        source: defaultSource
        height: 130
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 700
        anchors.rightMargin: 450
        anchors.topMargin: 330
        rotation: 180

        Timer {
            id: downTimer
            interval: 350
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
        onClicked: {
            goToInstructions()
        }
    }
}
