import QtQuick
import QtQuick.Effects
import qs.components

Item {
  id: root

  property real panelWidth: -1
  property real panelHeight: 44
  property real horizontalPadding: 20
  property real verticalPadding: 12

  readonly property color accentFg: Colors.get("on_primary_fixed", "#001f29")
  readonly property color accent: Colors.get("primary")

  readonly property real contentWidth: contentArea.childrenRect.width
  readonly property real contentHeight: contentArea.childrenRect.height
  readonly property real resolvedWidth: root.panelWidth > 0
    ? root.panelWidth
    : root.contentWidth + root.horizontalPadding * 2
  readonly property real resolvedHeight: root.panelHeight > 0
    ? root.panelHeight
    : root.contentHeight + root.verticalPadding * 2

  function tone(c, a) {
    const col = Qt.color(c);
    return Qt.rgba(col.r, col.g, col.b, a);
  }

  implicitWidth: resolvedWidth + 32
  implicitHeight: resolvedHeight + 24
  width: implicitWidth
  height: implicitHeight

  default property alias content: contentArea.data

  Item {
    id: panel
    anchors.centerIn: parent
    width: root.resolvedWidth
    height: root.resolvedHeight

    Rectangle {
      id: background
      anchors.fill: parent
      radius: height / 2
      color: root.tone(root.accentFg, 0.75)

      layer.enabled: true
      layer.smooth: true
      layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: "#30000000"
        shadowVerticalOffset: 8
        shadowBlur: 1
        shadowOpacity: 1
      }
    }

    Rectangle {
      anchors.fill: parent
      radius: parent.height / 2
      color: "transparent"
      border.width: 2
      border.color: root.tone(root.accentFg, 0.5)
    }

    Rectangle {
      anchors.fill: parent
      anchors.margins: 1
      radius: Math.max(0, parent.height / 2 - 1)
      color: "transparent"
      border.width: 1
      border.color: root.tone(root.accent, 0.25)
    }

    Item {
      id: contentArea
      anchors.fill: parent
      anchors.leftMargin: root.horizontalPadding
      anchors.rightMargin: root.horizontalPadding
      anchors.topMargin: root.verticalPadding
      anchors.bottomMargin: root.verticalPadding
    }
  }
}
