import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: keypad
    visible: false
    property var targetField

    width: parent.width
    height: 200
    anchors.bottom: parent.bottom
    z: 100

    Rectangle {
        anchors.fill: parent
        color: "#222"
    }

    GridLayout {
        id: keyGrid
        anchors.fill: parent
        columns: 4
        rowSpacing: 4
        columnSpacing: 4
        anchors.margins: 10

        property var keys: [
            "1", "2", "3",
            "4", "5", "6",
            "7", "8", "9",
            "←", "0", "Enter"
        ]

        Repeater {
            model: keyGrid.keys.length
            delegate: Button {
                text: keyGrid.keys[index]
                Layout.preferredWidth: keyGrid.width / 4 - 8
                Layout.preferredHeight: 40
                font {
                    family: "Space Mono"
                    pointSize: 18
                }
                onClicked: {
                    if (!keypad.targetField) return
                    keypad.targetField.forceActiveFocus()

                    if (text === "←") {
                        let pos = keypad.targetField.cursorPosition
                        if (pos > 0) {
                            let currentText = keypad.targetField.text
                            keypad.targetField.text = currentText.slice(0, pos - 1) + currentText.slice(pos)
                            keypad.targetField.cursorPosition = pos - 1
                        }
                    } else if (text === "Enter") {
                        keypad.visible = false
                    } else {
                        if (keypad.targetField.text.length < 2) {
                            keypad.targetField.insert(keypad.targetField.cursorPosition, text)
                            keypad.targetField.cursorPosition += text.length
                        }
                    }
                }
            }
        }
    }
}
