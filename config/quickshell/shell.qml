//@ pragma UseQApplication
import Quickshell
import QtQuick
import qs.modules

Scope {
  PanelWindow {
    anchors {
      top: true
      left: true
      right: true
    }

    color: "transparent"

    implicitHeight: 40
    exclusiveZone: 33

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
