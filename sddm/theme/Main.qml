// Glass — a macOS-style SDDM login screen.
// Only plain QtQuick 2 is used: this system's Qt5 greeter has no Controls or GraphicalEffects
// modules, so the round avatar is cut ahead of time (sddm/install.sh) rather than masked live.
import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#101014"

    property int sessionIndex: sessionModel.lastIndex
    property string userName: userModel.lastUser
    property bool busy: false

    FontLoader { id: fontRegular;  source: config.fontRegular  ? Qt.resolvedUrl(config.fontRegular)  : "" }
    FontLoader { id: fontSemibold; source: config.fontSemibold ? Qt.resolvedUrl(config.fontSemibold) : "" }
    FontLoader { id: fontBold;     source: config.fontBold     ? Qt.resolvedUrl(config.fontBold)     : "" }
    readonly property string familyRegular:  fontRegular.status  === FontLoader.Ready ? fontRegular.name  : "Cantarell"
    readonly property string familySemibold: fontSemibold.status === FontLoader.Ready ? fontSemibold.name : "Cantarell"
    readonly property string familyBold:     fontBold.status     === FontLoader.Ready ? fontBold.name     : "Cantarell"

    function login() {
        if (busy) return
        busy = true
        message.text = ""
        sddm.login(userName, password.text, sessionIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.busy = false
            password.text = ""
            message.text = "Incorrect password"
            shake.restart()
            password.forceActiveFocus()
        }
        function onLoginSucceeded() { message.text = "" }
    }

    // no remembered user yet (first login after install): fall back to the first account
    Repeater {
        model: userModel
        delegate: Item {
            Component.onCompleted: if (root.userName === "" && index === 0) root.userName = model.name
        }
    }

    // ---------- background ----------
    Image {
        anchors.fill: parent
        source: config.background ? Qt.resolvedUrl(config.background) : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: false
    }
    // the photo is shown sharp, so darken it a little, and more behind the clock and the
    // login column, to keep the white text readable on any picture
    Rectangle { anchors.fill: parent; color: "#000000"; opacity: 0.20 }
    Rectangle {
        anchors { left: parent.left; right: parent.right; top: parent.top }
        height: parent.height * 0.38
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#66000000" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }
    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: parent.height * 0.55
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 1.0; color: "#80000000" }
        }
    }

    // ---------- date and clock, top centre ----------
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.round(parent.height * 0.085)
        spacing: -6

        Text {
            id: dateLabel
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#ffffff"; opacity: 0.85
            font.family: root.familySemibold; font.pixelSize: Math.round(root.height * 0.026); font.weight: Font.DemiBold
        }
        Text {
            id: clockLabel
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#ffffff"; opacity: 0.92
            font.family: root.familyBold; font.pixelSize: Math.round(root.height * 0.118); font.weight: Font.Bold
        }
    }
    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            dateLabel.text = Qt.formatDate(now, "dddd, d MMMM")
            clockLabel.text = Qt.formatTime(now, "h:mm ap").split(" ")[0]
        }
    }

    // ---------- avatar, name, password ----------
    Column {
        id: loginColumn
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.round(parent.height * 0.60)
        spacing: 12

        // avatar: the round profile picture; underneath it, as a fallback, the initial on a disc
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 96; height: 96; radius: 48
            border.color: "#40ffffff"; border.width: avatarImage.status === Image.Ready ? 0 : 1
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#b8bcc8" }
                GradientStop { position: 1.0; color: "#6f7482" }
            }
            Text {
                anchors.centerIn: parent
                text: root.userName.length ? root.userName.charAt(0).toUpperCase() : "?"
                color: "#ffffff"
                font.family: root.familySemibold; font.pixelSize: 44; font.weight: Font.DemiBold
                visible: avatarImage.status !== Image.Ready
            }
            Image {
                id: avatarImage
                anchors.fill: parent
                source: config.avatar ? Qt.resolvedUrl(config.avatar) : ""
                smooth: true; mipmap: true
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.userName
            color: "#ffffff"
            font.family: root.familySemibold; font.pixelSize: 19; font.weight: Font.DemiBold
        }

        // frosted pill with the password field
        Rectangle {
            id: field
            anchors.horizontalCenter: parent.horizontalCenter
            width: 140; height: 24; radius: 12
            color: "#38ffffff"
            border.color: password.activeFocus ? "#70ffffff" : "#30ffffff"; border.width: 1

            SequentialAnimation on anchors.horizontalCenterOffset {
                id: shake; running: false
                NumberAnimation { to: -10; duration: 50 }
                NumberAnimation { to: 10; duration: 80 }
                NumberAnimation { to: -6; duration: 70 }
                NumberAnimation { to: 6; duration: 60 }
                NumberAnimation { to: 0; duration: 50 }
            }

            TextInput {
                id: password
                anchors { left: parent.left; right: goButton.left; verticalCenter: parent.verticalCenter; leftMargin: 12; rightMargin: 4 }
                echoMode: TextInput.Password
                passwordCharacter: "•"
                color: "#ffffff"
                selectionColor: "#60ffffff"
                clip: true
                focus: true
                enabled: !root.busy
                font.family: root.familyRegular; font.pixelSize: 12
                Keys.onReturnPressed: root.login()
                Keys.onEnterPressed: root.login()

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: password.text.length === 0
                    text: "Enter Password"
                    color: "#b0ffffff"
                    font: password.font
                }
            }

            // round arrow button, appears once something is typed
            Rectangle {
                id: goButton
                anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 4 }
                width: 16; height: 16; radius: 8
                color: goArea.containsMouse ? "#90ffffff" : "#50ffffff"
                opacity: password.text.length ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 120 } }
                Text { anchors.centerIn: parent; text: "→"; color: "#ffffff"; font.pixelSize: 11; font.family: root.familySemibold }
                MouseArea { id: goArea; anchors.fill: parent; hoverEnabled: true; onClicked: root.login() }
            }
        }

        Text {
            id: message
            anchors.horizontalCenter: parent.horizontalCenter
            height: 18
            color: "#ffffff"; opacity: 0.85
            text: keyboard.capsLock && text === "" ? "" : text
            font.family: root.familyRegular; font.pixelSize: 13
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: keyboard.capsLock
            text: "Caps Lock is on"
            color: "#ffffff"; opacity: 0.7
            font.family: root.familyRegular; font.pixelSize: 12
        }
    }

    // ---------- power buttons, top left ----------
    Row {
        anchors { left: parent.left; top: parent.top; leftMargin: 28; topMargin: 24 }
        spacing: 22

        Repeater {
            model: [
                { label: "Sleep",     glyph: "☾", action: "suspend",  can: sddm.canSuspend },
                { label: "Restart",   glyph: "↻", action: "reboot",   can: sddm.canReboot },
                { label: "Shut Down", glyph: "⏻", action: "powerOff", can: sddm.canPowerOff }
            ]
            delegate: Column {
                spacing: 5
                visible: modelData.can
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 32; height: 32; radius: 16
                    color: area.containsMouse ? "#60ffffff" : "#30ffffff"
                    border.color: "#30ffffff"; border.width: 1
                    Text { anchors.centerIn: parent; text: modelData.glyph; color: "#ffffff"; font.pixelSize: 15 }
                    MouseArea {
                        id: area; anchors.fill: parent; hoverEnabled: true
                        onClicked: {
                            if (modelData.action === "suspend") sddm.suspend()
                            else if (modelData.action === "reboot") sddm.reboot()
                            else sddm.powerOff()
                        }
                    }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: modelData.label
                    color: "#ffffff"; opacity: 0.8
                    font.family: root.familyRegular; font.pixelSize: 11
                }
            }
        }
    }

    // ---------- photo caption, bottom centre ----------
    // sddm/wallpaper.sh writes it to backgrounds/caption.txt next to the photo
    Text {
        id: caption
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 24 }
        width: Math.min(parent.width * 0.6, implicitWidth)
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        color: "#ffffff"; opacity: 0.75
        font.family: root.familyRegular; font.pixelSize: 12
        Component.onCompleted: {
            var request = new XMLHttpRequest()
            request.onreadystatechange = function() {
                if (request.readyState === XMLHttpRequest.DONE)
                    caption.text = (request.responseText || "").trim()
            }
            request.open("GET", Qt.resolvedUrl("backgrounds/caption.txt"))
            request.send()
        }
    }

    // ---------- session name, bottom right; click to switch ----------
    Item {
        anchors { right: parent.right; bottom: parent.bottom; rightMargin: 28; bottomMargin: 24 }
        width: sessionRow.width; height: sessionRow.height
        Row {
            id: sessionRow
            spacing: 6
            Repeater {
                id: sessions
                model: sessionModel
                delegate: Text {
                    visible: index === root.sessionIndex
                    width: visible ? implicitWidth : 0
                    text: model.name
                    color: "#ffffff"; opacity: 0.6
                    font.family: root.familyRegular; font.pixelSize: 12
                }
            }
        }
        MouseArea {
            anchors.fill: parent; anchors.margins: -8
            onClicked: if (sessions.count > 0) root.sessionIndex = (root.sessionIndex + 1) % sessions.count
        }
    }

    Component.onCompleted: password.forceActiveFocus()
}
