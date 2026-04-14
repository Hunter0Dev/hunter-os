// Hunter OS — SDDM Login Theme
// Premium dark, zero gradients, depth through shadow only

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Item {
    id: root
    width:  Screen.width
    height: Screen.height

    property int sessionIndex: sessionCombo.currentIndex

    // ─── Pure black background ─────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    // Wallpaper (sits behind everything, darkened)
    Image {
        id: wallpaper
        anchors.fill: parent
        source: "/usr/share/backgrounds/hunter-os-dark.png"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        opacity: 0.3
        visible: status === Image.Ready
    }

    // ─── Clock (top center) ───────────────────────────────
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 48
        spacing: 6

        Text {
            id: clockText
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 72
            font.weight: Font.Light
            font.letterSpacing: -1
            color: "#FFFFFF"
            text: Qt.formatDateTime(new Date(), "hh:mm")
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 15
            font.weight: Font.Normal
            color: "#6E6E80"
            text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
            font.letterSpacing: 0.3
        }

        Timer {
            interval: 1000; running: true; repeat: true
            onTriggered: clockText.text = Qt.formatDateTime(new Date(), "hh:mm")
        }
    }

    // ─── Login Card (centered) ────────────────────────────
    Column {
        anchors.centerIn: parent
        spacing: 0
        width: 320

        // Brand mark
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "HUNTER"
            font.pixelSize: 13
            font.weight: Font.Medium
            font.letterSpacing: 4
            color: "#3A3A48"
            bottomPadding: 40
        }

        // Avatar circle
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 96; height: 96
            radius: 48
            color: "#111116"
            border.color: "#1E1E24"
            border.width: 2
            bottomPadding: 0

            // Shadow
            layer.enabled: true
            layer.effect: Item {}

            // User icon
            Text {
                anchors.centerIn: parent
                text: usernameField.text.length > 0 ? usernameField.text.charAt(0).toUpperCase() : "H"
                font.pixelSize: 32
                font.weight: Font.Light
                color: "#3A3A48"
            }
        }

        Item { width: 1; height: 16 }

        // Username
        Text {
            id: usernameDisplay
            anchors.horizontalCenter: parent.horizontalCenter
            text: userModel.lastUser || "hunter"
            font.pixelSize: 18
            font.weight: Font.Normal
            color: "#FFFFFF"
            bottomPadding: 28
        }

        // Password field + submit button
        Rectangle {
            width: parent.width; height: 48
            color: "#111116"
            radius: 10
            border.color: passwordField.activeFocus ? "#00BFFF" : "#1E1E24"
            border.width: 1

            Behavior on border.color { ColorAnimation { duration: 150 } }

            // Focus glow
            Rectangle {
                anchors.fill: parent
                anchors.margins: -3
                radius: 13
                color: "transparent"
                border.color: passwordField.activeFocus ? "#00BFFF" : "transparent"
                border.width: 3
                opacity: 0.08
                Behavior on border.color { ColorAnimation { duration: 150 } }
            }

            TextField {
                id: passwordField
                anchors.fill: parent
                anchors.rightMargin: 48
                echoMode: TextInput.Password
                placeholderText: "Password"
                color: "#FFFFFF"
                placeholderTextColor: "#3A3A48"
                font.pixelSize: 14
                font.weight: Font.Normal
                leftPadding: 16
                background: Item {}
                Keys.onReturnPressed: doLogin()
            }

            // Submit arrow button
            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                width: 40; height: 40
                radius: 8
                color: submitMouse.pressed ? "#0090CC" : "#00BFFF"
                Behavior on color { ColorAnimation { duration: 100 } }

                // Arrow icon →
                Text {
                    anchors.centerIn: parent
                    text: "→"
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    color: "#000000"
                }

                MouseArea {
                    id: submitMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: doLogin()
                }
            }
        }

        Item { width: 1; height: 6 }

        // Status text
        Text {
            id: statusText
            anchors.horizontalCenter: parent.horizontalCenter
            text: ""
            font.pixelSize: 12
            color: "#6E6E80"
            height: 18
        }

        Item { width: 1; height: 16 }

        // Hidden username field (for SDDM)
        TextField {
            id: usernameField
            visible: false
            text: userModel.lastUser || "hunter"
        }

        // Session selector
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: sessionCombo.currentText + " ▾"
            font.pixelSize: 12
            color: "#3A3A48"

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: sessionCombo.popup.open()
            }
        }

        ComboBox {
            id: sessionCombo
            visible: false
            model: sessionModel
            textRole: "name"
        }
    }

    // ─── Power Buttons (bottom-right) ─────────────────────
    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 28
        spacing: 8

        PowerButton { iconText: "⏻"; tooltip: "Shutdown"; onClicked: sddm.powerOff() }
        PowerButton { iconText: "↺"; tooltip: "Restart";  onClicked: sddm.reboot()   }
    }

    // ─── Login Logic ──────────────────────────────────────
    function doLogin() {
        statusText.color = "#6E6E80"
        statusText.text = "Authenticating..."
        sddm.login(usernameField.text, passwordField.text, sessionIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            passwordField.clear()
            passwordField.forceActiveFocus()
            statusText.text = "Incorrect password"
            statusText.color = "#FF3B5C"
        }
    }

    // Focus password field on load
    Component.onCompleted: passwordField.forceActiveFocus()

    // ─── PowerButton Component ────────────────────────────
    component PowerButton: Rectangle {
        property string iconText: ""
        property string tooltip: ""
        signal clicked()

        width: 36; height: 36; radius: 18
        color: pwMouse.containsMouse ? "#111116" : "transparent"
        border.color: pwMouse.containsMouse ? "#3A3A48" : "#1E1E24"
        border.width: 1
        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        Text {
            anchors.centerIn: parent
            text: parent.iconText
            color: pwMouse.containsMouse ? "#6E6E80" : "#3A3A48"
            font.pixelSize: 14
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        ToolTip.visible: pwMouse.containsMouse
        ToolTip.text: parent.tooltip

        MouseArea {
            id: pwMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }
}
