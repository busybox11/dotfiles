import Quickshell.Io
import QtQuick
import qs.components

Monitor {
  id: root

  icon: ""
  style: "graph"

  property var prev: null

  function parse(text) {
    const line = text.split("\n")[0];
    if (!line?.startsWith("cpu "))
      return;

    const parts = line.trim().split(/\s+/).slice(1).map(Number);
    const idle = parts[3] + (parts[4] || 0);
    const total = parts.reduce((a, b) => a + b, 0);

    if (root.prev) {
      const di = idle - root.prev.idle;
      const dt = total - root.prev.total;
      if (dt > 0)
        root.pushSample((1 - di / dt) * 100);
    }

    root.prev = { idle, total };
  }

  FileView {
    id: stat
    path: "/proc/stat"
    onLoaded: root.parse(text())
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: stat.reload()
  }
}
