import Quickshell.Widgets
import QtQuick
import qs.components

Item {
  id: root

  required property string icon
  property real value: 0
  property color color: Colors.get("primary", "#ffffff")
  property color iconColor: Colors.get("primary_fixed", "#ffffff")

  readonly property int size: 30

  implicitWidth: root.size
  implicitHeight: root.size

  function edge(c, alpha) {
    const col = Qt.color(c);
    return Qt.rgba(col.r, col.g, col.b, alpha);
  }

  ClippingRectangle {
    id: circle
    anchors.fill: parent
    radius: width / 2

    border.width: 1
    border.color: root.edge(root.color, 0.3)
    color: root.edge(root.color, 0.12)

    Rectangle {
      id: fill
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      anchors.bottomMargin: -1
      width: parent.width
      height: parent.height * Math.min(1, Math.max(0, root.value / 100))
      color: root.edge(root.color, 0.3)
      border.width: 1
      border.color: root.edge(root.color, 0.5)
    }

    BarText {
      anchors.centerIn: parent
      topPadding: 0.5
      text: root.icon
      color: root.iconColor
      style: Text.Outline
      styleColor: "#00000033"
    }
  }
}
