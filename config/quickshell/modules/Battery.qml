import Quickshell.Io
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

  // charge limit in %, defaulting to 100 when the battery has no limiter;
  // from 95% onward a regular battery is treated as full
  property real chargeCap: 100
  property string capPath: ""
  readonly property real fullAt: chargeCap < 100 ? chargeCap : 95
  readonly property bool full: !discharging && pct >= fullAt

  visible: !!(bat?.ready && bat?.isPresent && bat?.isLaptopBattery)

  icon: `${full ? "" : ""}${charging ? " 󱐋" : " "}`
  value: pct
  text: `${Math.round(pct)}%`
  showFill: !full
  iconOnly: full
  iconColor: {
    if (charging || full)
      return Colors.get("green");
    const low = Colors.levelLow(pct, 35, 25);
    return low === "normal" ? textColor : Colors.accent(low);
  }
  fillColor: charging ? Colors.get("green") : Colors.accent(Colors.levelLow(pct, 35, 25))
  tint: charging ? Colors.get("green") : Colors.accent(Colors.levelLow(pct, 35, 25))

  Process {
    id: capDetect
    command: ["bash", "-c",
      `for d in /sys/class/power_supply/*; do
         [ "$(cat "$d/type" 2>/dev/null)" = "Battery" ] || continue
         [ -f "$d/charge_control_end_threshold" ] || continue
         printf '%s' "$d/charge_control_end_threshold"
         exit 0
       done`]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        const path = String(this.text).trim();
        if (path.length)
          root.capPath = path;
      }
    }
  }

  function updateCap() {
    const v = Number(capFile.text().trim());
    root.chargeCap = v > 0 && v <= 100 ? v : 100;
  }

  FileView {
    id: capFile
    path: root.capPath
    watchChanges: true
    onLoaded: root.updateCap()
    onFileChanged: capFile.reload()
  }
}
