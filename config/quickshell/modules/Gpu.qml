import Quickshell.Io
import QtQuick
import qs.components

Monitor {
  id: root

  property string backend: ""
  property string sysfsPath: ""
  property int intelCol: -1

  icon: "󰇄"
  style: "graph"

  function parseBusy(text) {
    const val = Number(String(text).trim().split("\n")[0]);
    if (!Number.isNaN(val))
      root.pushSample(val);
  }

  function parseIntelCsv(line) {
    const cols = String(line).trim().split(",");
    if (cols.length < 2)
      return;

    if (root.intelCol < 0) {
      const i = cols.findIndex(c => /RCS|Render/i.test(c));
      root.intelCol = i >= 0 ? i : 6;
      if (i >= 0)
        return;
    }

    const val = Number(cols[root.intelCol]);
    if (!Number.isNaN(val))
      root.pushSample(val);
  }

  Process {
    command: ["bash", "-c",
      `for p in /sys/class/drm/card[0-9]/device/gpu_busy_percent; do
         [ -r "$p" ] && { printf 'busy:%s' "$p"; exit 0; }
       done
       for p in /sys/class/drm/card[0-9]/device/vendor; do
         [ -r "$p" ] || continue
         [ "$(cat "$p")" = "0x8086" ] && { printf intel; exit 0; }
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
          root.backend = out || "nvidia";
          root.sysfsPath = "";
        }
      }
    }
  }

  FileView {
    id: sysfsFile
    path: root.sysfsPath
    onLoaded: root.parseBusy(text())
  }

  Process {
    running: root.backend === "intel"
    command: ["stdbuf", "-oL", "intel_gpu_top", "-c", "-s", "1000", "-o", "-"]
    stdout: SplitParser {
      onRead: line => root.parseIntelCsv(line)
    }
  }

  Process {
    id: nvidiaProc
    command: ["nvidia-smi", "--query-gpu=utilization.gpu", "--format=csv,noheader,nounits"]
    stdout: StdioCollector {
      onStreamFinished: root.parseBusy(this.text)
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
