import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import qs.components

Item {
  id: root

  required property var notif
  required property color accentColor

  signal closeRequested()

  property bool replyActive: replyField.activeFocus

  implicitWidth: 400
  height: content.height

  function tone(c, a) {
    const col = Qt.color(c);
    return Qt.rgba(col.r, col.g, col.b, a);
  }

  function lighten(c, t) {
    const col = Qt.color(c);
    return Qt.rgba(col.r + (1 - col.r) * t, col.g + (1 - col.g) * t, col.b + (1 - col.b) * t, 1);
  }

  property string timeAgoText: formatElapsed(root.notif.sentAt)

  function formatElapsed(sentAt) {
    if (!sentAt || typeof sentAt !== "number" || isNaN(sentAt))
      return "";
    const sec = Math.floor((Date.now() - sentAt) / 1000);
    if (sec < 5) return "now";
    if (sec < 60) return `${sec}s`;
    const min = Math.floor(sec / 60);
    if (min < 60) return `${min}m`;
    const hr = Math.floor(min / 60);
    if (hr < 24) return `${hr}h`;
    return `${Math.floor(hr / 24)}d`;
  }

  Timer {
    interval: 1000
    running: root.visible
    repeat: true
    onTriggered: root.timeAgoText = root.formatElapsed(root.notif.sentAt)
  }

  function sendReply() {
    if (replyField.text.length === 0)
      return;
    root.notif.sendInlineReply(replyField.text);
    root.closeRequested();
  }

  Rectangle {
    id: bg
    anchors.fill: parent
    radius: 12
    color: root.notif.urgency === NotificationUrgency.Critical ? root.tone(Colors.get("error_container"), 0.30) : root.tone(Colors.get("on_primary_fixed"), 0.5)
    border.width: 2
    border.color: root.tone(root.accentColor, 0.5)

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
    color: root.accentColor
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
      id: headerRow
      width: parent.innerWidth
      spacing: 8

      IconImage {
        id: appIcon
        width: 18
        height: 18
        source: root.notif.appIcon.length > 0 ? Quickshell.iconPath(root.notif.appIcon) : ""
        visible: root.notif.appIcon.length > 0
        asynchronous: true
        smooth: false
        Layout.alignment: Qt.AlignVCenter
      }

      Text {
        visible: root.notif.appIcon.length === 0
        text: "󰂚"
        font.family: "Caskaydia Cove NF"
        font.pixelSize: 14
        color: root.accentColor
        Layout.alignment: Qt.AlignVCenter
      }

      Text {
        text: root.notif.appName.length > 0 ? root.notif.appName : "Notification"
        color: root.lighten(root.accentColor, 0.45)
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
        text: root.timeAgoText
        visible: root.timeAgoText.length > 0
        font.family: "Caskaydia Cove NF"
        font.pixelSize: 10
        color: Colors.get("on_surface_variant")
        Layout.alignment: Qt.AlignVCenter
        Layout.rightMargin: 4
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
          onClicked: root.closeRequested()
        }
      }
    }

    RowLayout {
      id: bodyRow
      width: parent.innerWidth
      spacing: 8

      ColumnLayout {
        id: bodyCol
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop
        spacing: 6

        Text {
          id: summaryText
          text: root.notif.summary
          Layout.fillWidth: true
          color: root.lighten(root.accentColor, 0.65)
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
          id: bodyText
          visible: root.notif.body.length > 0
          text: root.notif.body
          Layout.fillWidth: true
          color: root.lighten(root.accentColor, 0.85)
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
        visible: root.notif.image.length > 0
        Layout.preferredWidth: 48
        Layout.preferredHeight: 48
        radius: 10
        Layout.alignment: Qt.AlignVCenter
        color: "transparent"

        Image {
          anchors.fill: parent
          source: root.notif.image
          fillMode: Image.PreserveAspectCrop
          sourceSize: Qt.size(48, 48)
          asynchronous: true
          smooth: false
          cache: false
        }
      }
    }

    RowLayout {
      id: actionsRow
      visible: root.notif.actions.length > 0
      width: parent.innerWidth
      spacing: 6

      Repeater {
        model: root.notif.actions.map(action => ({ action: action }))

        delegate: Rectangle {
          required property var modelData
          readonly property string text: modelData.action.text
          width: actionText.implicitWidth + 16
          height: 24
          radius: 6
          color: "transparent"
          border.width: 1
          border.color: root.tone(root.accentColor, 0.4)

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
              root.closeRequested();
            }
          }
        }
      }
    }

    Item {
      id: replyRow
      visible: root.notif.hasInlineReply
      width: parent.innerWidth
      height: 26

      Rectangle {
        anchors.fill: parent
        radius: 6
        color: "transparent"
        border.width: 1
        border.color: root.tone(root.accentColor, 0.4)
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
        onAccepted: root.sendReply()
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
        text: root.notif.inlineReplyPlaceholder || "Reply…"
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
        color: root.tone(root.accentColor, 0.5)

        Text {
          text: "󰄷"
          anchors.centerIn: parent
          font.family: "Caskaydia Cove NF"
          font.pixelSize: 11
          color: root.accentColor
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.sendReply()
        }
      }
    }
  }
}
