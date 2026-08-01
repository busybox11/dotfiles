import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.components

Scope {
  id: root

  readonly property int osdMs: 1000
  readonly property int extendedOsdMs: 2500
  readonly property int capsOsdMs: 1500

  property string mode: "output"
  property bool showOsd: false
  property bool showLabel: false
  property string labelText: ""
  property bool extendOsd: false
  property bool pendingSinkOsd: false
  property int hideDuration: root.osdMs
  property var lastSinkId: null

  property bool brightnessReady: false
  property string backlightDir: ""
  property real brightnessPct: 0
  property bool capsOn: false

  readonly property var sink: Pipewire.defaultAudioSink
  readonly property var source: Pipewire.defaultAudioSource
  readonly property bool outputMuted: sink?.audio?.muted ?? false
  readonly property real outputVolume: sink?.audio?.volume ?? 0
  readonly property string outputApi: sink?.properties?.["device.api"] ?? ""
  readonly property bool sourceMuted: source?.audio?.muted ?? false
  readonly property real sourceVolume: source?.audio?.volume ?? 0
  function nodeName(node) {
    if (!node)
      return "";
    const props = node.properties ?? {};
    return props["node.description"]
      ?? props["device.description"]
      ?? props["application.name"]
      ?? props["media.name"]
      ?? props["node.nick"]
      ?? node.description
      ?? node.name
      ?? "";
  }

  readonly property string sinkName: {
    const name = root.nodeName(root.sink);
    return name.length ? name : "Unknown output";
  }

  readonly property bool isMuted: root.mode === "input" ? root.sourceMuted : root.outputMuted
  readonly property real level: {
    switch (root.mode) {
    case "brightness":
      return root.brightnessPct / 100;
    case "caps":
      return 0;
    case "input":
      return root.sourceMuted ? 0 : Math.min(1, root.sourceVolume);
    default:
      return root.outputMuted ? 0 : Math.min(1, root.outputVolume);
    }
  }

  readonly property string icon: {
    switch (root.mode) {
    case "input":
      return root.sourceMuted ? "󰍭" : "󰍬";
    case "brightness":
      if (root.brightnessPct < 30)
        return "󰃞";
      if (root.brightnessPct > 70)
        return "󰃠";
      return "󰃟";
    case "caps":
      return root.capsOn ? "󰪛" : "󰪚";
    default:
      if (root.outputApi === "bluez5")
        return root.outputMuted ? "󱡐" : "󱡏";
      return root.outputMuted ? "󰝟" : "󰕾";
    }
  }

  readonly property string valueText: {
    switch (root.mode) {
    case "caps":
      return root.capsOn ? "On" : "Off";
    case "brightness":
      return `${Math.round(root.brightnessPct)}%`;
    default:
      return root.isMuted ? "muted" : `${Math.round(root.level * 100)}%`;
    }
  }

  readonly property bool showBar: root.mode !== "caps"
  readonly property bool useNerdFont: root.mode === "output" || root.mode === "input" || root.mode === "caps"

  function tone(c, a) {
    const col = Qt.color(c);
    return Qt.rgba(col.r, col.g, col.b, a);
  }

  function restartOsd(duration, opts) {
    stateResetTimer.stop();
    root.showOsd = true;
    if (opts?.mode)
      root.mode = opts.mode;
    if (opts?.showLabel)
      root.showLabel = true;
    else if (opts?.label) {
      root.showLabel = true;
      root.labelText = opts.label;
    } else if (!root.extendOsd) {
      root.showLabel = false;
    }
    root.hideDuration = duration;
    hideTimer.restart();
  }

  function beginSinkChangeOsd(node) {
    root.extendOsd = true;
    root.showLabel = true;
    root.pendingSinkOsd = true;
    root.tryCompleteSinkOsd(node);
  }

  function tryCompleteSinkOsd(node) {
    if (!root.pendingSinkOsd)
      return;
    const target = node ?? root.sink;
    const name = root.nodeName(target);
    if (!name.length && target && !target.ready)
      return;
    root.pendingSinkOsd = false;
    root.restartOsd(root.extendedOsdMs, { mode: "output", showLabel: true });
  }

  function resetOsdState() {
    root.showLabel = false;
    root.extendOsd = false;
    root.pendingSinkOsd = false;
  }

  function updateBrightness() {
    if (!root.backlightDir.length || !brightnessFile.loaded || !maxBrightnessFile.loaded)
      return;
    const current = Number(brightnessFile.text().trim());
    const max = Number(maxBrightnessFile.text().trim());
    if (!max)
      return;
    root.brightnessPct = current / max * 100;
    if (!root.brightnessReady) {
      root.brightnessReady = true;
      return;
    }
    root.restartOsd(root.osdMs, { mode: "brightness" });
  }

  PwObjectTracker {
    objects: {
      const tracked = [];
      if (root.sink)
        tracked.push(root.sink);
      if (root.source)
        tracked.push(root.source);
      return tracked;
    }
  }

  Process {
    command: ["sh", "-c", "ls /sys/class/backlight 2>/dev/null | head -1"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        const name = this.text.trim();
        if (!name.length)
          return;
        root.backlightDir = `/sys/class/backlight/${name}`;
      }
    }
  }

  FileView {
    id: brightnessFile
    path: root.backlightDir ? `${root.backlightDir}/brightness` : ""
    watchChanges: true
    onLoaded: root.updateBrightness()
    onFileChanged: root.updateBrightness()
  }

  FileView {
    id: maxBrightnessFile
    path: root.backlightDir ? `${root.backlightDir}/max_brightness` : ""
    onLoaded: root.updateBrightness()
    onFileChanged: root.updateBrightness()
  }

  Connections {
    target: Pipewire

    function onDefaultAudioSinkChanged() {
      const next = Pipewire.defaultAudioSink;
      if (!next)
        return;
      const id = next.id;
      if (root.lastSinkId !== null && id !== root.lastSinkId)
        root.beginSinkChangeOsd(next);
      root.lastSinkId = id;
    }
  }

  Timer {
    id: sinkOsdPoll
    interval: 50
    repeat: true
    running: root.pendingSinkOsd
    onTriggered: root.tryCompleteSinkOsd(root.sink)
  }

  Connections {
    target: root.sink

    function onReadyChanged() {
      root.tryCompleteSinkOsd(root.sink);
    }
  }

  Connections {
    target: root.sink?.audio

    function onVolumeChanged() {
      root.restartOsd(root.extendOsd ? root.extendedOsdMs : root.osdMs, { mode: "output" });
    }

    function onMutedChanged() {
      root.restartOsd(root.extendOsd ? root.extendedOsdMs : root.osdMs, { mode: "output" });
    }
  }

  Connections {
    target: root.source?.audio

    function onVolumeChanged() {
      root.restartOsd(root.osdMs, { mode: "input" });
    }

    function onMutedChanged() {
      root.restartOsd(root.osdMs, { mode: "input" });
    }
  }

  IpcHandler {
    target: "osd"

    function showCapsLock(on: bool): void {
      root.capsOn = on;
      root.restartOsd(root.capsOsdMs, { mode: "caps" });
    }
  }

  Timer {
    id: hideTimer
    interval: root.hideDuration
    onTriggered: {
      root.showOsd = false;
      stateResetTimer.restart();
    }
  }

  Timer {
    id: stateResetTimer
    interval: 600
    onTriggered: root.resetOsdState()
  }

  LazyLoader {
    active: root.showOsd

    PanelWindow {
      anchors {
        left: true
        right: true
        bottom: true
      }
      margins.bottom: screen.height / 9
      exclusiveZone: 0
      height: osdRoot.height
      color: "transparent"
      mask: Region {}

      WlrLayershell.namespace: "quickshell-osd"

      Item {
        id: osdRoot
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: osdPanel.width
        height: root.showLabel ? labelRow.height + 8 + osdPanel.height : osdPanel.height

        Row {
          id: labelRow
          visible: root.showLabel
          spacing: 8
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.bottom: osdPanel.top
          anchors.bottomMargin: 8

          OsdText {
            text: "󰓃"
            font.family: "Caskaydia Cove NF"
            anchors.verticalCenter: parent.verticalCenter
          }

          OsdText {
            text: root.sinkName
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        OsdPanel {
          id: osdPanel
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.bottom: parent.bottom
          panelWidth: root.showBar ? 280 : 200
          panelHeight: 44
          horizontalPadding: 20
          verticalPadding: 12

          RowLayout {
            anchors.fill: parent
            spacing: 16

            OsdText {
              text: root.icon
              font.family: root.useNerdFont ? "Caskaydia Cove NF" : "Cascadia Code NF"
              font.pixelSize: 16
              Layout.alignment: Qt.AlignVCenter
            }

            Rectangle {
              visible: root.showBar
              Layout.fillWidth: true
              Layout.preferredHeight: 8
              radius: 4
              color: tone(Colors.get("primary"), 0.25)
              border.width: 1
              border.color: tone(Colors.get("primary"), 0.75)

              Rectangle {
                anchors {
                  left: parent.left
                  top: parent.top
                  bottom: parent.bottom
                }
                width: parent.width * Math.min(1, root.level)
                radius: parent.radius
                color: Colors.get("primary")
              }
            }

            OsdText {
              text: root.valueText
              font.weight: Font.DemiBold
              Layout.alignment: Qt.AlignVCenter
              Layout.preferredWidth: implicitWidth
            }
          }
        }
      }
    }
  }
}
