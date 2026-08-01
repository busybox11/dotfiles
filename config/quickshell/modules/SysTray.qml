import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import Qt5Compat.GraphicalEffects
import qs.components

Row {
  id: root

  spacing: 8

  Repeater {
    model: SystemTray.items

    MouseArea {
      id: item

      required property SystemTrayItem modelData

      readonly property bool isSpotify: /spotify/i.test(modelData.id) || /spotify/i.test(modelData.title)

      visible: !isSpotify
      implicitWidth: 18
      implicitHeight: 18
      acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
      cursorShape: Qt.PointingHandCursor

      function openMenu() {
        const window = QsWindow.window;
        const pos = window.mapFromItem(item, width / 2, height);
        modelData.display(window, pos.x, pos.y);
      }

      onClicked: event => {
        if (event.button === Qt.LeftButton) {
          if (modelData.onlyMenu)
            openMenu();
          else
            modelData.activate();
        } else if (event.button === Qt.MiddleButton) {
          modelData.secondaryActivate();
        } else if (event.button === Qt.RightButton) {
          openMenu();
        }
      }

      onWheel: event => {
        modelData.scroll(event.angleDelta.y, false);
      }

      IconImage {
        id: trayIcon
        anchors.fill: parent
        source: item.modelData.icon
        asynchronous: true
        visible: false
        smooth: false
      }

      Desaturate {
        id: mono
        anchors.fill: trayIcon
        source: trayIcon
        desaturation: 1.0
        visible: false
      }

      ColorOverlay {
        anchors.fill: mono
        source: mono
        color: Colors.get("primary_fixed", "#ffffff")
      }
    }
  }
}
