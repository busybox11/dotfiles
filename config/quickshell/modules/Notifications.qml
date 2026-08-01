import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import qs.components

Scope {
  id: root

  readonly property int lowMs: 5000
  readonly property int normalMs: 7000
  readonly property int criticalMs: 0
  readonly property int popupWidth: 400

  property bool dnd: false
  property bool replyActive: false
  property var notifications: []

  function tone(c, a) {
    const col = Qt.color(c);
    return Qt.rgba(col.r, col.g, col.b, a);
  }

  function lighten(c, t) {
    const col = Qt.color(c);
    return Qt.rgba(col.r + (1 - col.r) * t, col.g + (1 - col.g) * t, col.b + (1 - col.b) * t, 1);
  }

  function urgencyColor(urgency) {
    switch (urgency) {
    case NotificationUrgency.Critical:
      return Colors.critical;
    case NotificationUrgency.Low:
      return Colors.get("outline");
    default:
      return Colors.get("primary");
    }
  }

  function timeoutFor(notif) {
    if (notif.resident)
      return 0;
    if (notif.expireTimeout > 0)
      return notif.expireTimeout;
    switch (notif.urgency) {
    case NotificationUrgency.Critical:
      return root.criticalMs;
    case NotificationUrgency.Low:
      return root.lowMs;
    default:
      return root.normalMs;
    }
  }

  function removeNotif(notif) {
    if (notif.hasInlineReply)
      root.replyActive = false;
    if (root.notifications.indexOf(notif) === -1)
      return;
    root.notifications = root.notifications.filter(n => n !== notif);
  }

  function focusApp(notif) {
    const candidates = [];
    if (notif.desktopEntry.length > 0)
      candidates.push(notif.desktopEntry.toLowerCase());
    if (notif.appName.length > 0)
      candidates.push(notif.appName.toLowerCase());

    for (const toplevel of Hyprland.toplevels.values) {
      if (!toplevel.lastIpcObject)
        continue;
      const cls = (toplevel.lastIpcObject.class ?? "").toLowerCase();
      const initial = (toplevel.lastIpcObject.initialClass ?? "").toLowerCase();
      for (const c of candidates) {
        if (cls === c || initial === c) {
          if (Hyprland.usingLua)
            Hyprland.dispatch(`hl.dsp.focus({ window = 'address:0x${toplevel.address}' })`);
          else
            Hyprland.dispatch(`focuswindow address:0x${toplevel.address}`);
          return;
        }
      }
    }
  }

  function dismissNotif(notif) {
    if (notif)
      notif.dismiss();
  }

  function clearAll() {
    root.notifications.slice().forEach(n => n.dismiss());
  }

  function toggleDnd() {
    root.dnd = !root.dnd;
    if (root.dnd)
      root.notifications.slice().forEach(n => {
        if (n.urgency !== NotificationUrgency.Critical)
          n.dismiss();
      });
  }

  NotificationServer {
    id: server
    keepOnReload: false
    actionsSupported: true
    imageSupported: true
    bodyHyperlinksSupported: true
    bodyMarkupSupported: true
    persistenceSupported: true
    inlineReplySupported: true

    onNotification: notif => {
      if (root.dnd && notif.urgency !== NotificationUrgency.Critical) {
        notif.tracked = false;
        return;
      }
      notif.tracked = true;
      root.notifications = [notif, ...root.notifications];
    }
  }

  IpcHandler {
    target: "notifications"

    function toggleDnd(): void {
      root.toggleDnd();
    }

    function setDnd(on: bool): void {
      root.dnd = on;
      if (on)
        root.notifications.slice().forEach(n => {
          if (n.urgency !== NotificationUrgency.Critical)
            n.dismiss();
        });
    }

    function clearAll(): void {
      root.clearAll();
    }

    function test(): void {
      Quickshell.execDetached(["notify-send", "-u", "low", "-a", "quickshell", "Low urgency", "Test notification body."]);
      Quickshell.execDetached(["notify-send", "-a", "quickshell", "Normal urgency", "Test notification body."]);
      Quickshell.execDetached(["notify-send", "-u", "critical", "-a", "quickshell", "Critical urgency", "Test notification body."]);
    }
  }

  PanelWindow {
    anchors {
      top: true
      right: true
    }
    exclusiveZone: 0
    color: "transparent"
    implicitWidth: root.popupWidth + 36
    implicitHeight: stack.height + 36
    visible: root.notifications.length > 0
    focusable: root.replyActive
    WlrLayershell.namespace: "quickshell-notifications"

    Column {
      id: stack
      anchors {
        top: parent.top
        right: parent.right
      }
      topPadding: 18
      rightPadding: 18
      bottomPadding: 18
      leftPadding: 18
      width: root.popupWidth + 36
      spacing: 8

      Repeater {
        model: root.notifications

        delegate: Item {
          id: card
          required property var modelData
          readonly property var notif: modelData
          readonly property color accentColor: root.urgencyColor(card.notif.urgency)
          readonly property int dismissMs: root.timeoutFor(card.notif)
          readonly property real swipeThreshold: root.popupWidth * 0.35

          property real offset: 0
          property real velocity: 0
          property bool dragging: false
          property bool dismissing: false
          property real baseOffset: 0
          property double lastSampleTime: 0
          property real lastSampleOffset: 0
          property double lastWheelTime: 0

          width: root.popupWidth
          height: content.height

          function dismiss() {
            root.dismissNotif(card.notif);
          }

          function sendReply() {
            if (replyField.text.length === 0)
              return;
            card.notif.sendInlineReply(replyField.text);
            card.dismiss();
          }

          function restartTimer() {
            if (card.dismissMs > 0 && !hover.hovered && !card.dragging)
              autoTimer.restart();
          }

          function settle() {
            const decel = 1800;
            const predicted = card.offset + (card.velocity > 0 ? (card.velocity * card.velocity) / (2 * decel) : 0);
            if (predicted > card.swipeThreshold)
              card.animateOut();
            else
              card.slideBack();
          }

          function animateOut() {
            if (card.dismissing)
              return;
            card.dismissing = true;
            const remaining = root.popupWidth + 80 - card.offset;
            const v = Math.max(600, Math.abs(card.velocity));
            outAnim.duration = Math.max(120, Math.min(300, Math.round((remaining / v) * 1000)));
            outAnim.start();
          }

          function slideBack() {
            if (card.dismissing)
              return;
            backAnim.start();
          }

          transform: Translate {
            x: card.offset
          }

          PropertyAnimation {
            id: backAnim
            target: card
            property: "offset"
            to: 0
            duration: 250
            easing.type: Easing.OutCubic
          }

          PropertyAnimation {
            id: outAnim
            target: card
            property: "offset"
            to: root.popupWidth + 80
            duration: 250
            easing.type: Easing.OutCubic
            onFinished: card.dismiss()
          }

          TapHandler {
            id: cardTap
            enabled: !replyField.activeFocus && !card.dragging
            acceptedButtons: Qt.LeftButton
            onTapped: {
              if (card.offset > 0)
                return;
              root.focusApp(card.notif);
              card.dismissing = false;
              card.velocity = 900;
              card.animateOut();
            }
          }

          DragHandler {
            id: cardDrag
            target: null
            xAxis.enabled: true
            yAxis.enabled: false
            dragThreshold: 8
            enabled: !replyField.activeFocus
            onActiveChanged: {
              if (active) {
                card.dragging = true;
                card.dismissing = false;
                card.baseOffset = card.offset;
                card.lastSampleTime = Date.now();
                card.lastSampleOffset = card.offset;
                card.velocity = 0;
              } else {
                card.dragging = false;
                card.settle();
              }
            }

            onActiveTranslationChanged: {
              if (!active)
                return;
              card.offset = card.baseOffset + activeTranslation.x;
              const now = Date.now();
              const dt = (now - card.lastSampleTime) / 1000;
              if (dt > 0.016) {
                card.velocity = (card.offset - card.lastSampleOffset) / dt;
                card.lastSampleTime = now;
                card.lastSampleOffset = card.offset;
              }
            }
          }

          WheelHandler {
            id: cardWheel
            target: null
            orientation: Qt.Horizontal
            activeTimeout: 300
            enabled: !replyField.activeFocus

            onWheel: (event) => {
              const now = Date.now();
              const dt = (now - card.lastWheelTime) / 1000;
              card.lastWheelTime = now;
              const px = event.pixelDelta.x;
              const dx = px !== 0 ? px : event.angleDelta.x * 0.125;
              card.offset = Math.max(0, card.offset + dx);
              if (dt > 0.016)
                card.velocity = dx / dt;
            }

            onActiveChanged: {
              if (!active && card.offset > 0)
                card.settle();
            }
          }

          Rectangle {
            id: bg
            anchors.fill: parent
            radius: 12
            color: card.notif.urgency === NotificationUrgency.Critical ? root.tone(Colors.get("error_container"), 0.30) : root.tone(Colors.get("on_primary_fixed"), 0.5)
            border.width: 2
            border.color: root.tone(card.accentColor, 0.35)

            layer.enabled: true
            layer.smooth: true
            layer.effect: MultiEffect {
              shadowEnabled: true
              shadowColor: "#40000000"
              shadowVerticalOffset: 4
              shadowBlur: 1
              shadowOpacity: 1
            }
          }

          Rectangle {
            anchors {
              left: parent.left
              leftMargin: 8
              top: parent.top
              topMargin: 10
              bottom: parent.bottom
              bottomMargin: 10
            }
            width: 3
            radius: 1.5
            color: card.accentColor
          }

          Column {
            id: content
            width: parent.width
            padding: 10
            leftPadding: 20
            rightPadding: 10
            spacing: 6
            readonly property real innerWidth: width - leftPadding - rightPadding

            RowLayout {
              width: parent.innerWidth
              spacing: 8

              IconImage {
                id: appIcon
                width: 18
                height: 18
                source: Quickshell.iconPath(card.notif.appIcon)
                visible: card.notif.appIcon.length > 0
                asynchronous: true
                smooth: false
                Layout.alignment: Qt.AlignVCenter
              }

              Text {
                visible: card.notif.appIcon.length === 0
                text: "󰂚"
                font.family: "Caskaydia Cove NF"
                font.pixelSize: 14
                color: card.accentColor
                Layout.alignment: Qt.AlignVCenter
              }

              Text {
                text: card.notif.appName.length > 0 ? card.notif.appName : "Notification"
                color: root.lighten(card.accentColor, 0.45)
                font {
                  family: "Caskaydia Cove NF"
                  pointSize: 9
                  weight: Font.DemiBold
                }
                elide: Text.ElideRight
                Layout.fillWidth: true
                verticalAlignment: Text.AlignVCenter
              }

              Text {
                text: "󰅖"
                font.family: "Caskaydia Cove NF"
                font.pixelSize: 12
                color: Colors.get("on_surface_variant")
                Layout.alignment: Qt.AlignVCenter
                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    card.dismissing = false;
                    card.velocity = 900;
                    card.animateOut();
                  }
                }
              }
            }

            RowLayout {
              width: parent.innerWidth
              spacing: 8

              Column {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 6

                Text {
                  text: card.notif.summary
                  width: parent.width
                  color: root.lighten(card.accentColor, 0.65)
                  font {
                    family: "Caskaydia Cove NF"
                    pointSize: 10
                    weight: Font.DemiBold
                  }
                  wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                  maximumLineCount: 2
                  elide: Text.ElideRight
                }

                Text {
                  visible: card.notif.body.length > 0
                  text: card.notif.body
                  width: parent.width
                  color: root.lighten(card.accentColor, 0.85)
                  font {
                    family: "Caskaydia Cove NF"
                    pointSize: 9
                  }
                  wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                  maximumLineCount: 3
                  elide: Text.ElideRight
                  textFormat: Text.PlainText
                }
              }

              ClippingRectangle {
                visible: card.notif.image.length > 0
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                radius: 10
                Layout.alignment: Qt.AlignVCenter
                color: "transparent"

                Image {
                  anchors.fill: parent
                  source: card.notif.image
                  fillMode: Image.PreserveAspectCrop
                  sourceSize: Qt.size(48, 48)
                  asynchronous: true
                  smooth: false
                  cache: false
                }
              }
            }

            RowLayout {
              visible: card.notif.actions.length > 0
              width: parent.innerWidth
              spacing: 6

              Repeater {
                model: card.notif.actions.map(action => ({ action: action, notif: card.notif }))

                delegate: Rectangle {
                  required property var modelData
                  readonly property string text: modelData.action.text
                  width: actionText.implicitWidth + 16
                  height: 24
                  radius: 6
                  color: "transparent"
                  border.width: 1
                  border.color: root.tone(root.urgencyColor(modelData.notif.urgency), 0.4)

                  Text {
                    id: actionText
                    anchors.centerIn: parent
                    text: parent.text
                    color: Colors.get("on_surface")
                    font {
                      family: "Caskaydia Cove NF"
                      pointSize: 9
                    }
                  }

                  MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                      modelData.action.invoke();
                      root.dismissNotif(modelData.notif);
                    }
                  }
                }
              }
            }

            Item {
              visible: card.notif.hasInlineReply
              width: parent.innerWidth
              height: 26

              Rectangle {
                anchors.fill: parent
                radius: 6
                color: "transparent"
                border.width: 1
                border.color: root.tone(card.accentColor, 0.4)
              }

              TextInput {
                id: replyField
                anchors {
                  left: parent.left
                  right: parent.right
                  top: parent.top
                  bottom: parent.bottom
                  leftMargin: 8
                  rightMargin: 30
                }
                verticalAlignment: Text.AlignVCenter
                clip: true
                color: Colors.get("on_surface")
                font {
                  family: "Caskaydia Cove NF"
                  pointSize: 9
                }
                selectByMouse: true
                onAccepted: card.sendReply()
                onActiveFocusChanged: root.replyActive = replyField.activeFocus
              }

              Text {
                visible: replyField.text.length === 0
                anchors {
                  left: parent.left
                  right: parent.right
                  top: parent.top
                  bottom: parent.bottom
                  leftMargin: 8
                  rightMargin: 30
                }
                verticalAlignment: Text.AlignVCenter
                text: card.notif.inlineReplyPlaceholder || "Reply…"
                color: Colors.get("outline")
                font {
                  family: "Caskaydia Cove NF"
                  pointSize: 9
                }
                elide: Text.ElideRight
              }

              Rectangle {
                anchors {
                  right: parent.right
                  top: parent.top
                  bottom: parent.bottom
                }
                width: 24
                radius: 6
                color: root.tone(card.accentColor, 0.5)

                Text {
                  text: "󰄷"
                  anchors.centerIn: parent
                  font.family: "Caskaydia Cove NF"
                  font.pixelSize: 11
                  color: card.accentColor
                }

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: card.sendReply()
                }
              }
            }
          }

          HoverHandler {
            id: hover
            target: card
            onHoveredChanged: {
              if (hover.hovered)
                autoTimer.stop();
              else if (card.dismissMs > 0)
                autoTimer.restart();
            }
          }

          Timer {
            id: autoTimer
            interval: Math.max(1, card.dismissMs)
            repeat: false
            onTriggered: card.dismiss()
          }

          Connections {
            target: card.notif

            function onClosed() {
              root.removeNotif(card.notif);
            }

            function onSummaryChanged() {
              card.restartTimer();
            }

            function onBodyChanged() {
              card.restartTimer();
            }

            function onActionsChanged() {
              card.restartTimer();
            }
          }
        }
      }
    }
  }
}
