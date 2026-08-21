import QtQuick

Pill {
  id: root

  property string text: `${Math.round(value)}%`
  property bool showFill: true
  property real fillAlpha: 0.25
  property real edgeAlpha: 0.5
  property color fillColor: root.plotColor

  // volume-style metrics stay on primary chrome unless tint/fillColor override
  warnAt: 150
  critAt: 150
  borderAlpha: edgeAlpha

  width: root.iconOnly ? 28 : 84

  Item {
    parent: root.contentItem
    anchors.fill: parent
    visible: root.showFill
    z: 0

    Rectangle {
      id: fill
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      width: parent.width * Math.min(1, Math.max(0, root.value / 100))
      color: {
        const c = Qt.color(root.fillColor);
        return Qt.rgba(c.r, c.g, c.b, root.fillAlpha);
      }

      Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: root.fillColor
        opacity: root.edgeAlpha
      }
    }
  }

  BarText {
    parent: root.contentItem
    anchors.right: parent.right
    anchors.rightMargin: 8
    anchors.verticalCenter: parent.verticalCenter
    topPadding: 0.5
    z: 1
    visible: !root.iconOnly
    text: root.text
    color: root.iconColor
    style: Text.Outline
    styleColor: "#00000033"
  }
}
