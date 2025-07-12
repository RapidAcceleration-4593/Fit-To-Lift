import QtQuick
import QtQuick.Controls

Button {
    id: keyButton
    property var targetField
    property int maxLength: -1
    property var keyboardRef: null

    font.pointSize: 20
    font.family: "Space Mono"
    background: Rectangle {
        color: "#333"
        radius: 6
    }

    onClicked: {
        if (!targetField) return
        targetField.forceActiveFocus()

        /* --- Backspace --- */
        if (text === "Back") {
            const pos = targetField.cursorPosition
            if (pos > 0) {
                const currentText = targetField.text
                targetField.text = currentText.slice(0, pos - 1) + currentText.slice(pos)
                targetField.cursorPosition = pos - 1
            }
            return
        }
        
        /* --- Space --- */
        if (text === "Space") {
            targetField.insert(targetField.cursorPosition, " ")
            targetField.cursorPosition += 1
            return
        }
        
        /* --- Enter --- */
        if (text === "Enter") {
            if (keyboardRef) keyboardRef.visible = false
            return
        }

        /* --- Auto-Capitalize --- */
        const pos = targetField.cursorPosition
        const prevChar = pos > 0 ? targetField.text.charAt(pos - 1) : " "
        const charToInsert = (pos === 0 || prevChar === " ")
            ? text.toUpperCase()
            : text.toLowerCase()

        if (maxLength === -1 || targetField.text.length < maxLength) {
            targetField.insert(pos, charToInsert)
            targetField.cursorPosition = pos + 1
        }
    }
}
