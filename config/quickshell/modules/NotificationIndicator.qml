import QtQuick
import qs.components

BarText {
  id: root

  text: notifications.dnd ? "" : notifications.center.length > 0 ? `󱅫 ${notifications.center.length}` : ""
  font.pointSize: notifications.dnd ? 14 : 12

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: notifications.dnd ? notifications.toggleDnd() : notifications.toggleCenter()
  }
}
