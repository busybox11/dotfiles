import Quickshell.Io
import QtQuick
import qs.components

Monitor {
  id: root

  icon: "󰋊"
  style: "text"
  warnAt: 85
  critAt: 95

  Process {
    id: df
    command: ["df", "-P", "/"]
    stdout: StdioCollector {
      onStreamFinished: {
        const lines = this.text.trim().split("\n");
        if (lines.length < 2)
          return;
        const parts = lines[1].trim().split(/\s+/);
        const pct = Number(String(parts[4] ?? "").replace("%", ""));
        if (!Number.isNaN(pct))
          root.pushSample(pct);
      }
    }
  }

  Timer {
    interval: 30000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: df.running = true
  }
}
