import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  visible: false
  width: 0
  height: 0

  signal tempSample(real celsius)
  signal fanSample(real rpm)

  property string tempPath: ""
  property var fanPaths: []

  function reload() {
    if (root.tempPath.length) {
      tempFile.reload();
      const raw = Number(tempFile.text().trim());
      if (!Number.isNaN(raw))
        root.tempSample(raw / 1000);
    }

    let max = 0;
    let saw = false;
    for (let i = 0; i < fanViews.count; i++) {
      const view = fanViews.itemAt(i);
      if (!view)
        continue;
      const n = Number(view.read().trim());
      if (Number.isNaN(n))
        continue;
      saw = true;
      if (n > max)
        max = n;
    }
    if (saw)
      root.fanSample(max);
  }

  Process {
    command: ["bash", Quickshell.env("HOME") + "/.config/hypr/scripts/fan_speed.sh"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        const fans = [];
        for (const line of String(this.text).trim().split("\n")) {
          const sp = line.indexOf(" ");
          if (sp < 0)
            continue;
          const kind = line.slice(0, sp);
          const path = line.slice(sp + 1);
          if (kind === "temp")
            root.tempPath = path;
          else if (kind === "fan")
            fans.push(path);
        }
        root.fanPaths = fans;
      }
    }
  }

  FileView {
    id: tempFile
    path: root.tempPath
    blockAllReads: true
    printErrors: false
  }

  Repeater {
    id: fanViews
    model: root.fanPaths
    delegate: Item {
      required property string modelData

      function read() {
        view.reload();
        return view.text();
      }

      FileView {
        id: view
        path: modelData
        blockAllReads: true
        printErrors: false
      }
    }
  }

  onFanPathsChanged: Qt.callLater(root.reload)
}
