import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
    id: container
    width: 640
    height: 480

    // Background Image
    Image {
        id: background
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
    }

    // Glassmorphism Login Box
    Rectangle {
        id: loginBox
        anchors.centerIn: parent
        width: 320
        height: 350
        color: "#1e1e2e"
        opacity: 0.85 // See-through glass effect
        radius: 15
        border.color: "#33ccff"
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: 20

            // Title / Avatar
            Text {
                text: "HUNTER OS"
                color: "#ffffff"
                font.family: config.fontFamily
                font.pixelSize: 24
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Input Field
            TextBox {
                id: password
                width: 250
                height: 40
                text: ""
                echoMode: TextInput.Password
                font.pixelSize: 14
                color: "#ffffff"
                borderColor: "#33ccff"
                focus: true
                
                // On Enter Key
                Keys.onPressed: {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        sddm.login(userModel.lastUser, password.text, sessionModel.lastIndex)
                    }
                }
            }

            // Login Button
            Button {
                id: loginButton
                text: "LOGIN"
                width: 250
                height: 40
                color: "#33ccff"
                textColor: "#000000"
                activeColor: "#00ff99"
                onClicked: sddm.login(userModel.lastUser, password.text, sessionModel.lastIndex)
            }
        }
    }
}
