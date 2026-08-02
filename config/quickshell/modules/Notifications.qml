import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
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
  property bool centerVisible: false
  property var notifications: []
  property var center: []

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
    root.notifications = root.notifications.filter(n => n !== notif);
    root.center = root.center.filter(n => n !== notif);
  }

  function popupRemove(notif) {
    if (notif.hasInlineReply)
      root.replyActive = false;
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
    root.center.slice().forEach(n => n.dismiss());
  }

  function toggleCenter() {
    root.centerVisible = !root.centerVisible;
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
      root.center = [notif, ...root.center].slice(0, 50);
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

    function toggleCenter(): void {
      root.toggleCenter();
    }

    function setCenter(on: bool): void {
      root.centerVisible = on;
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
          property bool popupOnly: false
          property real baseOffset: 0
          property double lastSampleTime: 0
          property real lastSampleOffset: 0
          property double lastWheelTime: 0

          width: root.popupWidth
          height: cardBody.height

          function dismiss() {
            root.dismissNotif(card.notif);
          }

          function hidePopup() {
            card.popupOnly = true;
            card.dismissing = false;
            card.velocity = 900;
            card.animateOut();
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

          NotifCard {
            id: cardBody
            width: parent.width
            notif: card.notif
            accentColor: card.accentColor
            onCloseRequested: {
              card.dismissing = false;
              card.velocity = 900;
              card.animateOut();
            }
            onReplyActiveChanged: root.replyActive = cardBody.replyActive
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
            onFinished: {
              if (card.popupOnly)
                root.popupRemove(card.notif);
              else
                root.dismissNotif(card.notif);
            }
          }

          TapHandler {
            id: cardTap
            enabled: !cardBody.replyActive && !card.dragging
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
            enabled: !cardBody.replyActive
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
            enabled: !cardBody.replyActive

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
            onTriggered: card.hidePopup()
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

  PanelWindow {
    id: centerPanel
    anchors {
      top: true
      right: true
      bottom: true
    }
    margins {
      top: 18
      right: 18
      bottom: 18
    }
    exclusiveZone: 0
    color: "transparent"
    implicitWidth: root.popupWidth + 36
    implicitHeight: centerPanel.screen ? centerPanel.screen.height : 800
    visible: root.centerVisible
    WlrLayershell.namespace: "quickshell-notifications-center"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.centerVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Rectangle {
      id: panelBg
      anchors.fill: parent
      focus: true
      Keys.onEscapePressed: root.centerVisible = false
      radius: 12
      color: root.tone(Colors.get("surface_container"), 0.7)
      border.width: 2
      border.color: root.tone(Colors.get("primary"), 0.3)

      layer.enabled: true
      layer.smooth: true
      layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: "#80000000"
        shadowVerticalOffset: 8
        shadowBlur: 2
        shadowOpacity: 1
      }
    }

    ColumnLayout {
      id: centerLayout
      anchors {
        fill: parent
        topMargin: 14
        rightMargin: 14
        bottomMargin: 14
        leftMargin: 14
      }
      spacing: 10

      RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Text {
          text: "Notifications"
          color: Colors.get("on_surface")
          font {
            family: "Caskaydia Cove NF"
            pointSize: 11
            weight: Font.DemiBold
          }
          leftPadding: 4
          Layout.fillWidth: true
        }

        Text {
          text: `󰑎 ${root.center.length}`
          color: Colors.get("on_surface_variant")
          font {
            family: "Caskaydia Cove NF"
            pointSize: 9
          }
          Layout.alignment: Qt.AlignVCenter
        }

        Rectangle {
          implicitWidth: clearText.implicitWidth + 16
          height: 24
          radius: 6
          color: "transparent"
          border.width: 1
          border.color: root.tone(Colors.get("primary"), 0.4)
          Layout.alignment: Qt.AlignVCenter

          Text {
            id: clearText
            anchors.centerIn: parent
            text: "󰅴 Clear"
            color: Colors.get("on_surface")
            font {
              family: "Caskaydia Cove NF"
              pointSize: 9
            }
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clearAll()
          }
        }

        Text {
          text: "󰅖"
          font.family: "Caskaydia Cove NF"
          font.pixelSize: 18
          padding: 4
          color: Colors.get("on_surface_variant")
          Layout.alignment: Qt.AlignVCenter

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.centerVisible = false
          }
        }
      }

      Flickable {
        id: centerList
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        contentHeight: centerListColumn.height
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar {
          policy: ScrollBar.AsNeeded
        }

        Column {
          id: centerListColumn
          width: parent.width
          spacing: 8

          Repeater {
            model: root.center

            delegate: Item {
              required property var modelData
              width: centerListColumn.width
              height: cardBody.height
              implicitHeight: cardBody.implicitHeight + 8

              NotifCard {
                id: cardBody
                width: parent.width
                notif: modelData
                accentColor: root.urgencyColor(modelData.urgency)
                onCloseRequested: root.dismissNotif(modelData)
                onReplyActiveChanged: root.replyActive = cardBody.replyActive
              }

              TapHandler {
                enabled: !cardBody.replyActive
                acceptedButtons: Qt.LeftButton
                onTapped: root.focusApp(modelData)
              }
            }
          }
        }
      }
    }
  }

  PanelWindow {
    anchors {
      left: true
      top: true
      right: true
      bottom: true
    }
    exclusiveZone: 0
    color: "transparent"
    visible: root.centerVisible
    WlrLayershell.namespace: "quickshell-notifications-center-backdrop"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
      cursorShape: Qt.ArrowCursor
      onClicked: root.centerVisible = false
    }
  }
}
