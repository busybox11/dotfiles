import Quickshell.Widgets
import QtQuick
import qs.components

Item {
  id: root

  implicitWidth: row.implicitWidth
  implicitHeight: 40
  visible: Music.active
  opacity: Music.isPlaying ? 1 : 0.75

  Row {
    id: row
    spacing: 12
    anchors.verticalCenter: parent.verticalCenter

    ClippingRectangle {
      width: 32
      height: 32
      radius: 8
      border.width: 1
      border.color: {
        const c = Qt.color(Colors.get("primary_fixed"))
        return Qt.rgba(c.r, c.g, c.b, 0.1)
      }
 
      color: "transparent"
      visible: Music.artUrl.length > 0
      anchors.verticalCenter: parent.verticalCenter

      Image {
        anchors.fill: parent
        source: Music.artUrl
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(32, 32)
        asynchronous: true
        smooth: false
      }
    }

    BarText {
      text: Music.title
      anchors.verticalCenter: parent.verticalCenter
    }

    BarText {
      text: Music.artist
      opacity: 0.6
      visible: Music.artist.length > 0
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    cursorShape: Qt.PointingHandCursor
    onClicked: event => {
      if (event.button === Qt.LeftButton)
        Music.previous();
      else if (event.button === Qt.RightButton)
        Music.next();
      else if (event.button === Qt.MiddleButton)
        Music.toggle();
    }
    onWheel: event => {
      if (event.angleDelta.y === 0)
        return;
      Music.adjustVolume(event.angleDelta.y > 0 ? 0.05 : -0.05);
    }
  }
}
