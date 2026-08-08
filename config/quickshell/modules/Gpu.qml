import Quickshell.Io
import QtQuick
import qs.components

Monitor {
  id: root

  property bool useSysfs: false
  property string sysfsPath: ""

  Process {
    id: detectProc
    command: ["sh", "-c",
      "for p in /sys/class/drm/card*/device/gpu_busy_percent; do if [ -r \"$p\" ]; then printf '%s' \"$p\"; exit 0; fi; done; printf nvidia"
    ]
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        const out = String(this.text).trim();
        if (out && out !== "nvidia") {
          root.sysfsPath = out;
          root.useSysfs = true;
        } else {
          root.sysfsPath = "";
          root.useSysfs = false;
        }
      }
    }
  }

  Component.onCompleted: detectProc.running = true

  icon: "󰇄"
  style: "graph"

  // Recurring GPU sampling process; command chosen from detection
  Process {
    id: gpuProc
    command: root.useSysfs ? ["cat", root.sysfsPath] : ["nvidia-smi", "--query-gpu=utilization.gpu", "--format=csv,noheader,nounits"]
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
