import Quickshell.Io
import QtQuick
import qs.components

Monitor {
  id: root

  property string backend: ""
  property string sysfsPath: ""
  property var prevRc6: null

  icon: "󰇄"
  style: "graph"

  function parseSysfs(text) {
    if (root.backend === "busy") {
      const val = Number(String(text).trim().split("\n")[0]);
      if (!Number.isNaN(val))
        root.pushSample(val);
      return;
    }

    if (root.backend !== "rc6")
      return;

    const ms = Number(String(text).trim());
    if (Number.isNaN(ms))
      return;

    const t = Date.now();
    if (root.prevRc6) {
      const dRc6 = ms - root.prevRc6.ms;
      const dWall = t - root.prevRc6.t;
      if (dWall > 0)
        root.pushSample(Math.min(100, Math.max(0, (1 - dRc6 / dWall) * 100)));
    }
    root.prevRc6 = { ms, t };
  }

  Process {
    command: ["bash", "-c",
      `for p in /sys/class/drm/card[0-9]/device/gpu_busy_percent; do
         [ -r "$p" ] && { printf 'busy:%s' "$p"; exit 0; }
       done
       for p in /sys/class/drm/card[0-9]/gt/gt0/rc6_residency_ms /sys/class/drm/card[0-9]/power/rc6_residency_ms; do
         [ -r "$p" ] && { printf 'rc6:%s' "$p"; exit 0; }
       done
       printf nvidia`]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        const out = String(this.text).trim();
        const i = out.indexOf(":");
        if (i > 0) {
          root.backend = out.slice(0, i);
          root.sysfsPath = out.slice(i + 1);
        } else {
          root.backend = "nvidia";
          root.sysfsPath = "";
        }
      }
    }
  }

  FileView {
    id: sysfsFile
    path: root.sysfsPath
    onLoaded: root.parseSysfs(text())
  }

  Process {
    id: nvidiaProc
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
    onTriggered: {
      if (root.backend === "nvidia")
        nvidiaProc.running = true;
      else if (root.sysfsPath.length)
        sysfsFile.reload();
    }
  }
}
