import QtQuick
import qs.components

Item {
  id: root

  property bool showDate: false
  property real rightPadding: 0

  implicitWidth: showDate ? dateText.implicitWidth + rightPadding : timeText.implicitWidth + rightPadding
  implicitHeight: 40
  clip: true

  Behavior on implicitWidth {
    enabled: root.showDate
    NumberAnimation {
      duration: 220
      easing.type: Easing.OutCubic
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.showDate = true
    onExited: root.showDate = false
  }

  BarText {
    id: timeText
    anchors.verticalCenter: parent.verticalCenter
    x: root.showDate ? -implicitWidth : 0
    text: "  " + Time.time

    Behavior on x {
      enabled: root.showDate
      NumberAnimation {
        duration: 220
        easing.type: Easing.OutCubic
      }
    }
  }

  BarText {
    id: dateText
    anchors.verticalCenter: parent.verticalCenter
    x: root.showDate ? 0 : root.width
    visible: root.showDate
    text: "  " + Time.date

    Behavior on x {
      enabled: root.showDate
      NumberAnimation {
        duration: 220
        easing.type: Easing.OutCubic
      }
    }
  }
}
