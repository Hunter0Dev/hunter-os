// Hunter OS — Calamares Installation Slideshow
// Premium dark. Zero gradients. Depth via opacity only.
// Palette: #000000 / #0A0A0F / #111116 / #1E1E24
// Accent: #00BFFF   Text: #FFFFFF / #6E6E80

import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    width: 800
    height: 440

    property int slideIndex: 0

    // ─── Slide Data ──────────────────────────────────────
    ListModel {
        id: slides

        ListElement {
            icon: "◆"
            title: "Welcome to Hunter OS"
            subtitle: "A SECURITY-FIRST LINUX EXPERIENCE"
            body: "Hunter OS combines the power of Arch Linux with enterprise-grade security and a polished desktop. Your system is being configured with hardened defaults — no extra setup needed."
        }
        ListElement {
            icon: "◈"
            title: "Built-In Protection"
            subtitle: "SECURITY THAT WORKS OUT OF THE BOX"
            body: "AppArmor confines applications. UFW firewall blocks all inbound traffic by default. Fail2Ban stops brute-force attacks. Kernel hardening is pre-applied. Your system is locked down from the first boot."
        }
        ListElement {
            icon: "◉"
            title: "Your Privacy, Enforced"
            subtitle: "MULTI-USER ISOLATION"
            body: "Each user's home directory is completely private — other users cannot access your files. Process isolation hides your running apps from other accounts. Private by default, shared by choice."
        }
        ListElement {
            icon: "◎"
            title: "A Beautiful Desktop"
            subtitle: "KDE PLASMA 6 — FAST, MODERN, CUSTOMIZABLE"
            body: "A macOS-inspired layout with a global menu bar, floating dock, Mission Control hot corners, and smooth animations. Everything you need to be productive, nothing you don't."
        }
        ListElement {
            icon: "▣"
            title: "Developer Ready"
            subtitle: "ALL YOUR TOOLS, ONE COMMAND AWAY"
            body: "GCC, Clang, Python, Node.js, Rust, and Go are pre-installed. VS Code is ready. Use 'hunter install dev-c' or 'hunter install dev-rust' to set up complete toolchains instantly."
        }
        ListElement {
            icon: "◇"
            title: "Almost There"
            subtitle: "YOUR SYSTEM IS BEING INSTALLED"
            body: "Hunter OS is being written to your drive. This usually takes 5–15 minutes depending on your hardware. When finished, remove the installation media and reboot into your new system."
        }
    }

    // ─── Background ──────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    // ─── Slide Content ───────────────────────────────────
    Item {
        id: slideContainer
        anchors.fill: parent
        anchors.leftMargin: 60
        anchors.rightMargin: 60
        anchors.topMargin: 40
        anchors.bottomMargin: 40

        // Geometric icon
        Text {
            id: slideIcon
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 24
            text: slides.get(slideIndex).icon
            font.pixelSize: 40
            font.weight: Font.Light
            color: "#00BFFF"
            opacity: 0.6
        }

        // Title — large, light weight
        Text {
            id: slideTitle
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: slideIcon.bottom
            anchors.topMargin: 24
            text: slides.get(slideIndex).title
            font.pixelSize: 36
            font.weight: Font.Light
            font.letterSpacing: -0.5
            color: "#FFFFFF"
            horizontalAlignment: Text.AlignHCenter
        }

        // Subtitle — cyan, uppercase, tracked
        Text {
            id: slideSubtitle
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: slideTitle.bottom
            anchors.topMargin: 12
            text: slides.get(slideIndex).subtitle
            font.pixelSize: 11
            font.weight: Font.Medium
            font.letterSpacing: 2.5
            color: "#00BFFF"
            horizontalAlignment: Text.AlignHCenter
        }

        // Thin separator line
        Rectangle {
            id: separator
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: slideSubtitle.bottom
            anchors.topMargin: 20
            width: 40
            height: 1
            color: "#1E1E24"
        }

        // Body text — secondary color, generous line height
        Text {
            id: slideBody
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: separator.bottom
            anchors.topMargin: 20
            width: parent.width * 0.75
            text: slides.get(slideIndex).body
            font.pixelSize: 14
            font.weight: Font.Normal
            color: "#6E6E80"
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            lineHeight: 1.6
        }

        // ─── Dot Indicators ──────────────────────────────
        Row {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            Repeater {
                model: slides.count
                Rectangle {
                    width: index === slideIndex ? 24 : 6
                    height: 6
                    radius: 3
                    color: index === slideIndex ? "#00BFFF" : "#1E1E24"

                    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 250 } }
                }
            }
        }
    }

    // ─── Auto-advance ────────────────────────────────────
    Timer {
        interval: 8000
        running: true
        repeat: true
        onTriggered: slideIndex = (slideIndex + 1) % slides.count
    }

    // ─── Fade Transition ─────────────────────────────────
    onSlideIndexChanged: fadeOut.start()

    SequentialAnimation {
        id: fadeOut
        NumberAnimation {
            target: slideContainer
            property: "opacity"
            to: 0; duration: 200
            easing.type: Easing.InQuad
        }
        NumberAnimation {
            target: slideContainer
            property: "opacity"
            to: 1; duration: 350
            easing.type: Easing.OutQuad
        }
    }
}
