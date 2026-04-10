import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height

    // Background with blur
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: config.background || "/usr/share/backgrounds/hunter-os-dark.png"
        fillMode: Image.PreserveAspectCrop
        smooth: true

        // Dark overlay for readability
        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: 0.3
        }
    }

    // Clock at top
    ColumnLayout {
        anchors.top: parent.top
        anchors.topMargin: 60
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 4

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatTime(new Date(), "hh:mm")
            font.pixelSize: 72
            font.weight: Font.Light
            color: "white"
            renderType: Text.NativeRendering
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatDate(new Date(), "dddd, MMMM d")
            font.pixelSize: 20
            font.weight: Font.Normal
            color: "#cccccc"
            renderType: Text.NativeRendering
        }
    }

    // Timer to update clock
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: { /* Clock auto-updates via binding */ }
    }

    // Login box - centered
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16
        width: 320

        // User avatar circle
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 96
            height: 96
            radius: 48
            color: "#4a90d9"
            border.color: "#ffffff"
            border.width: 2

            Text {
                anchors.centerIn: parent
                text: "🛡️"
                font.pixelSize: 42
            }
        }

        // Username display
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: userModel.lastUser || "Hunter"
            font.pixelSize: 22
            font.weight: Font.Medium
            color: "white"
            renderType: Text.NativeRendering
        }

        // Password field
        TextField {
            id: passwordField
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 280
            Layout.preferredHeight: 40
            echoMode: TextInput.Password
            placeholderText: "Enter Password"
            horizontalAlignment: TextInput.AlignHCenter

            background: Rectangle {
                radius: 20
                color: "#40ffffff"
                border.color: passwordField.activeFocus ? "#4a90d9" : "#60ffffff"
                border.width: 1
            }

            color: "white"
            font.pixelSize: 14

            Keys.onReturnPressed: {
                sddm.login(userModel.lastUser, passwordField.text, sessionModel.lastIndex)
            }

            Component.onCompleted: forceActiveFocus()
        }

        // Error message
        Text {
            id: errorMessage
            Layout.alignment: Qt.AlignHCenter
            text: ""
            color: "#ff6b6b"
            font.pixelSize: 12
            visible: text !== ""
        }

        // Session selector (small, at bottom)
        ComboBox {
            id: sessionSelector
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 200
            model: sessionModel
            currentIndex: sessionModel.lastIndex
            textRole: "name"

            background: Rectangle {
                radius: 12
                color: "#20ffffff"
                border.color: "#40ffffff"
            }

            contentItem: Text {
                text: sessionSelector.displayText
                color: "#aaaaaa"
                font.pixelSize: 11
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    // Power buttons - bottom right
    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 24
        spacing: 16

        ImageButton {
            id: btnReboot
            source: "reboot.svg"
            width: 32
            height: 32
            onClicked: sddm.reboot()

            Text {
                anchors.top: parent.bottom
                anchors.topMargin: 4
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Restart"
                color: "#aaaaaa"
                font.pixelSize: 10
            }
        }

        ImageButton {
            id: btnPoweroff
            source: "shutdown.svg"
            width: 32
            height: 32
            onClicked: sddm.powerOff()

            Text {
                anchors.top: parent.bottom
                anchors.topMargin: 4
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Shut Down"
                color: "#aaaaaa"
                font.pixelSize: 10
            }
        }
    }

    // OS branding - bottom left
    Text {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 24
        text: "Hunter OS"
        color: "#60ffffff"
        font.pixelSize: 12
        font.weight: Font.Medium
    }

    // Handle login failure
    Connections {
        target: sddm
        function onLoginFailed() {
            errorMessage.text = "Incorrect password. Please try again."
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }
        function onLoginSucceeded() {
            errorMessage.text = ""
        }
    }
}
