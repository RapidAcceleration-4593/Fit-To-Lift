import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: keyboard
    visible: false
    property var targetField

    width: parent.width; height: 220
    anchors.bottom: parent.bottom
    z: 100

    Rectangle {
        anchors.fill: parent
        color: "#222"
    }

    property int keyWidth: 110
    property int keyLargeWidth: 240
    property int keyHeight: 50

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 1
        Layout.alignment: Qt.AlignHCenter

        /* --- Row 1 --- */
        RowLayout {
            spacing: 6
            Layout.alignment: Qt.AlignHCenter
            Repeater {
                model: ["Q","W","E","R","T","Y","U","I","O","P"]
                delegate: KeyButton {
                    text: modelData.toUpperCase()
                    targetField: keyboard.targetField
                    keyboardRef: keyboard
                    Layout.preferredWidth: keyboard.keyWidth
                    Layout.preferredHeight: keyboard.keyHeight
                }
            }
        }

        /* --- Row 2 --- */
        RowLayout {
            spacing: 6
            Layout.alignment: Qt.AlignHCenter
            Repeater {
                model: ["A","S","D","F","G","H","J","K","L"]
                delegate: KeyButton {
                    text: modelData.toUpperCase()
                    targetField: keyboard.targetField
                    keyboardRef: keyboard
                    Layout.preferredWidth: keyboard.keyWidth
                    Layout.preferredHeight: keyboard.keyHeight
                }
            }
        }

        /* --- Row 3 --- */
        RowLayout {
            spacing: 6
            Layout.alignment: Qt.AlignHCenter
            Repeater {
                model: ["Z","X","C","V","B","N","M"]
                delegate: KeyButton {
                    text: modelData.toUpperCase()
                    targetField: keyboard.targetField
                    keyboardRef: keyboard
                    Layout.preferredWidth: keyboard.keyWidth
                    Layout.preferredHeight: keyboard.keyHeight
                }
            }
        }

        /* --- Row 4 --- */
        RowLayout {
            spacing: 6
            Layout.alignment: Qt.AlignHCenter
            KeyButton {
                text: "Back"
                targetField: keyboard.targetField
                keyboardRef: keyboard
                Layout.preferredWidth: keyboard.keyLargeWidth
                Layout.preferredHeight: keyboard.keyHeight
            }
            KeyButton {
                text: "Space"
                targetField: keyboard.targetField
                keyboardRef: keyboard
                Layout.preferredWidth: keyboard.keyLargeWidth
                Layout.preferredHeight: keyboard.keyHeight
            }
            KeyButton {
                text: "Enter"
                targetField: keyboard.targetField
                keyboardRef: keyboard
                Layout.preferredWidth: keyboard.keyLargeWidth
                Layout.preferredHeight: keyboard.keyHeight
            }
        }
    }
}
