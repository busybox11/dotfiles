import Quickshell.Widgets
import QtQuick

Item {
  id: root

  required property string icon
  property real value: 0
  property real warnAt: Colors.warnAt
  property real critAt: Colors.critAt
  property bool lowIsBad: false

  readonly property string level: root.lowIsBad
    ? Colors.levelLow(value, warnAt, critAt)
    : Colors.level(value, warnAt, critAt)
  readonly property color textColor: Colors.foreground(level)
  readonly property color plotColor: Colors.accent(level)

  property color tint: Colors.accent(level)
  property real tintAlpha: 0.12
  property real borderAlpha: 0.3

  property alias radius: visual.radius
  property alias border: visual.border
  property alias color: visual.color
  readonly property alias contentItem: visual.contentItem

  implicitHeight: 40

  property ClippingRectangle visual: ClippingRectangle {
    id: visual

    parent: root
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    height: 28
    radius: height / 2

    border.width: 1
    border.color: {
      const c = Qt.color(root.tint);
      return Qt.rgba(c.r, c.g, c.b, root.borderAlpha);
    }

    color: {
      const c = Qt.color(root.tint);
      return Qt.rgba(c.r, c.g, c.b, root.tintAlpha);
    }

    BarText {
      anchors.left: parent.left
      anchors.leftMargin: 8
      anchors.verticalCenter: parent.verticalCenter
      topPadding: 0.5
      z: 1
      text: root.icon
      color: root.textColor
      style: Text.Outline
      styleColor: "#00000033"
    }
  }
}
