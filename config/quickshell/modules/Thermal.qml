import Quickshell
import Quickshell.Io
import QtQuick
import qs.components

Row {
  id: root

  property string tempPath: ""

  spacing: 24

  Monitor {
    id: tempMon
    icon: ""
    style: "text"
    text: `${Math.round(value)}°C`
    warnAt: 70
    critAt: 80
  }

  Monitor {
    id: fanMon
    icon: "󰈐"
    style: "text"
    text: `${Math.round(value)}`
    warnAt: 4000
    critAt: 5200
  }

  Process {
    command: [
      "bash", "-c",
      `for d in /sys/class/hwmon/hwmon*; do
         n=$(cat "$d/name" 2>/dev/null) || continue
         if [ "$n" = k10temp ] || [ "$n" = coretemp ]; then
           printf '%s' "$d/temp1_input"
           exit 0
         fi
       done`
    ]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        const path = this.text.trim();
        if (path.length)
          root.tempPath = path;
      }
    }
  }

  FileView {
    id: tempFile
    path: root.tempPath
    onLoaded: {
      const raw = Number(text().trim());
      if (!Number.isNaN(raw))
        tempMon.pushSample(raw / 1000);
    }
  }

  Process {
    id: fanProc
    command: ["bash", Quickshell.env("HOME") + "/.config/eww/scripts/fan_speeds"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const data = JSON.parse(this.text.trim());
          fanMon.pushSample(Number(data.max) || 0);
        } catch (e) {
          console.error("Fan: parse failed:", e);
        }
      }
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      if (root.tempPath.length)
        tempFile.reload();
      fanProc.running = true;
    }
  }
}
