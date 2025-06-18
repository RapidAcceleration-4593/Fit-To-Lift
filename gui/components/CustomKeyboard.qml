import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: keyboard
    visible: false
    property var targetField

    width: parent.width
    height: 280
    anchors.bottom: parent.bottom
    z: 100

    Rectangle {
        anchors.fill: parent
        color: "#222"
    }

    GridLayout {
        id: keyGrid
        width: parent.width
        height: parent.height - 40
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        columns: 10
        rowSpacing: 3
        columnSpacing: 5
        anchors.margins: 10

        property var keys: [
            "Q","W","E","R","T","Y","U","I","O","P",
            "A","S","D","F","G","H","J","K","L","←",
            "Z","X","C","V","B","N","M","Space","Enter"
        ]

        Repeater {
            model: keyGrid.keys.length
            delegate: Button {
                text: keyGrid.keys[index]
                Layout.preferredWidth: keyGrid.width / 10 - 8
                Layout.preferredHeight: 60
                font {
                    family: "Space Mono"
                    pointSize: 18
                }
                onClicked: {
                    if (!keyboard.targetField) return
                    keyboard.targetField.forceActiveFocus()

                    if (text === "←") {
                        let pos = keyboard.targetField.cursorPosition
                        if (pos > 0) {
                            let currentText = keyboard.targetField.text
                            keyboard.targetField.text = currentText.slice(0, pos - 1) + currentText.slice(pos)
                            keyboard.targetField.cursorPosition = pos - 1
                        }
                    } else if (text === "Space") {
                        keyboard.targetField.insert(keyboard.targetField.cursorPosition, " ")
                        keyboard.targetField.cursorPosition += 1
                    } else if (text === "Enter") {
                        keyboard.visible = false
                    } else {
                        keyboard.targetField.insert(keyboard.targetField.cursorPosition, text)
                        keyboard.targetField.cursorPosition += text.length
                    }
                }
            }
        }
    }
}
