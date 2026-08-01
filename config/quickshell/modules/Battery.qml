import Quickshell.Services.UPower
import QtQuick
import qs.components

BarPill {
  id: root

  readonly property var bat: UPower.displayDevice
  readonly property real pct: {
    const p = bat?.percentage ?? 0;
    return p <= 1 ? p * 100 : p;
  }
  readonly property bool charging: bat?.state === UPowerDeviceState.Charging
  readonly property bool discharging: bat?.state === UPowerDeviceState.Discharging

  visible: !!(bat?.ready && bat?.isPresent && bat?.isLaptopBattery)

  icon: `${pct > 90 ? "" : ""}${charging ? " 󱐋" : " "}`
  value: pct
  text: `${Math.round(pct)}%`
  showFill: pct < 95 || discharging

  // disable high-is-bad; battery uses levelLow
  warnAt: 150
  critAt: 150
  tint: Colors.accent(Colors.levelLow(pct, 40, 25))
}
