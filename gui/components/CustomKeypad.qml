import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: keypad
    visible: false
    property var targetField

    width: parent.width; height: 220
    anchors.bottom: parent.bottom
    z: 100

    Rectangle {
        anchors.fill: parent
        color: "#222"
    }

    GridLayout {
        id: keyGrid
        anchors.fill: parent
        columns: 3
        rowSpacing: 2
        columnSpacing: 4
        anchors.margins: 10

        property var keys: [
            "1", "2", "3",
            "4", "5", "6",
            "7", "8", "9",
            "Back", "0", "Enter"
        ]

        Repeater {
            model: keyGrid.keys.length
            delegate: KeyButton {
                text: keyGrid.keys[index]
                targetField: keypad.targetField
                keyboardRef: keypad
                maxLength: 2
                Layout.preferredWidth: keyGrid.width / 3 - 8
                Layout.preferredHeight: 50
            }
        }
    }
}
