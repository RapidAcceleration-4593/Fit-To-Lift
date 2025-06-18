import QtQuick
import QtQuick.Controls

Item {
    id: configurationScreen
    width: 1280
    height: 720
    visible: true
    anchors.fill: stackView.view

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
        height: 130
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 450
        anchors.rightMargin: 700
        anchors.topMargin: 330
        source: "../images/arrow.png"

        MouseArea {
            id: upMouseArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                services.bumpArmUp()
            }
        }
    }

    Image {
        id: downArrowImage
        height: 130
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 700
        anchors.rightMargin: 450
        anchors.topMargin: 330
        source: "../images/arrow.png"
        rotation: 180

        MouseArea {
            id: downMouseArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
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
