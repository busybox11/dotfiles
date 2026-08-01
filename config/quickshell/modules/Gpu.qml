import Quickshell.Io
import QtQuick
import qs.components

Monitor {
  id: root

  icon: "󰇄"
  style: "graph"

  Process {
    id: gpuProc
    command: ["nvidia-smi", "--query-gpu=utilization.gpu", "--format=csv,noheader,nounits"]
    stdout: StdioCollector {
      onStreamFinished: {
        const val = Number(String(this.text.trim()).split("\n")[0]);
        if (!Number.isNaN(val))
          root.pushSample(val);
      }
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: gpuProc.running = true
  }
}
