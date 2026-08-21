//@ pragma UseQApplication
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import qs.components
import qs.modules

Scope {
  PanelWindow {
    id: bar

    anchors {
      top: true
      left: true
      right: true
    }

    readonly property var chromeByClass: ({
      spotify: "#000000",
      cursor: "background",
      code: "background",
      "org.gnome.nautilus": "background",
      equibop: "#160e13",
      kitty: "on_secondary_fixed",
      "zen-twilight": "#000000",
      helium: "#30191E"
    })

    readonly property var workspace: Hyprland.monitorFor(screen)?.activeWorkspace ?? null
    readonly property int windowCount: workspace?.toplevels.values.length ?? 0

    readonly property var mappedWindows: {
      const _ = windowCount;
      const ws = workspace;
      if (!ws || ws.id < 1)
        return [];
      return ws.toplevels.values.filter(t => {
        const ipc = t.lastIpcObject;
        return ipc?.mapped === true && !ipc.floating;
      });
    }

    readonly property bool hasChrome: chromeFill !== ""

    readonly property string chromeFill: {
      const _ = Colors.colors;
      if (mappedWindows.length !== 1)
        return "";
      const ipc = mappedWindows[0].lastIpcObject ?? {};
      const classes = [ipc.class, ipc.initialClass];
      for (const cls of classes) {
        const mapped = chromeByClass[(cls ?? "").toLowerCase()];
        if (!mapped)
          continue;
        return mapped.startsWith("#") ? mapped : Colors.get(mapped);
      }
      return "";
    }

    color: "transparent"
    WlrLayershell.namespace: "quickshell"
    WlrLayershell.layer: WlrLayer.Bottom

    implicitHeight: 40
    exclusiveZone: 40

    Connections {
      target: Hyprland

      function onRawEvent(event) {
        if (event.name.includes("window") || event.name === "changefloatingmode" || event.name.startsWith("workspace") || event.name.startsWith("focusedmon"))
          Hyprland.refreshToplevels();
      }
    }

    Rectangle {
      anchors.fill: parent
      visible: bar.hasChrome
      color: bar.chromeFill
    }

    Row {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      height: parent.height

      spacing: 24
      leftPadding: 12

      Workspaces {
        anchors.verticalCenter: parent.verticalCenter
      }

      Row {
        spacing: 8
        anchors.verticalCenter: parent.verticalCenter

        Cpu {
          anchors.verticalCenter: parent.verticalCenter
        }
        Gpu {
          anchors.verticalCenter: parent.verticalCenter
        }
        Mem {
          anchors.verticalCenter: parent.verticalCenter
        }
      }

      Thermal {
        anchors.verticalCenter: parent.verticalCenter
      }
    }

    NowPlaying {
      anchors.centerIn: parent
    }

    Row {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      height: parent.height

      spacing: 20

      Disk {
        anchors.verticalCenter: parent.verticalCenter
      }

      BtBattery {
        anchors.verticalCenter: parent.verticalCenter
      }
      Volume {
        anchors.verticalCenter: parent.verticalCenter
      }

      Battery {
        anchors.verticalCenter: parent.verticalCenter
      }

      SysTray {
        anchors.verticalCenter: parent.verticalCenter
      }

      NotificationIndicator {
        anchors.verticalCenter: parent.verticalCenter
      }

      Clock {
        rightPadding: 20
        anchors.verticalCenter: parent.verticalCenter
      }
    }
  }

  Osd {}

  Notifications {
    id: notifications
  }
}
