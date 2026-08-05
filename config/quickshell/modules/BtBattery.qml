import Quickshell.Bluetooth
import QtQuick
import qs.components

Monitor {
  id: root

  // Iterate the model directly (not via `.find()`) so bindings track each device's
  // `connected` / `batteryAvailable` changes and the pill appears/disappears live,
  // without needing to relaunch quickshell. We walk the whole list (no early return)
  // so changes on any device re-evaluate this binding.
  readonly property var device: {
    const devices = Bluetooth.devices.values;
    let found = null;
    for (let i = 0; i < devices.length; i++) {
      const d = devices[i];
      if (d.connected && d.batteryAvailable)
        found = found ?? d;
    }
    return found;
  }
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
