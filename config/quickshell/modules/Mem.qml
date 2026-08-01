import Quickshell.Io
import QtQuick
import qs.components

Monitor {
  id: root

  icon: ""
  style: "circle"
  warnAt: 80
  critAt: 95

  function parse(text) {
    let total = 0;
    let available = 0;

    for (const line of text.split("\n")) {
      if (line.startsWith("MemTotal:"))
        total = Number(line.split(/\s+/)[1]);
      else if (line.startsWith("MemAvailable:"))
        available = Number(line.split(/\s+/)[1]);
    }

    if (total <= 0)
      return;

    root.pushSample(((total - available) / total) * 100);
  }

  FileView {
    id: meminfo
    path: "/proc/meminfo"
    onLoaded: root.parse(text())
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: meminfo.reload()
  }
}
