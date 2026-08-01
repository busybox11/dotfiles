import Quickshell.Bluetooth
import QtQuick
import qs.components

Monitor {
  id: root

  readonly property var device: Bluetooth.devices.values.find(d => d.connected && d.batteryAvailable) ?? null
  readonly property real pct: (device?.battery ?? 0) * 100

  visible: !!device
  icon: "󰂯"
  style: "text"
  value: pct
  text: `${Math.round(pct)}%`

  lowIsBad: true
  warnAt: 26
  critAt: 16
}
