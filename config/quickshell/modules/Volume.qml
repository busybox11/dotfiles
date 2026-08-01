import Quickshell.Services.Pipewire
import QtQuick
import qs.components

BarPill {
  id: root

  readonly property var sink: Pipewire.defaultAudioSink
  readonly property bool muted: sink?.audio?.muted ?? false
  readonly property real volumePct: (sink?.audio?.volume ?? 0) * 100
  readonly property string api: sink?.properties?.["device.api"] ?? ""

  icon: {
    if (api === "bluez5") {
      return muted ? "󱡐" : "󱡏";
    } else {
      return muted ? "󰝟" : "󰕾";
    }
  }
  value: muted ? 0 : volumePct
  text: `${Math.round(volumePct)}%`
  showFill: !muted

  PwObjectTracker {
    objects: root.sink ? [root.sink] : []
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton
    cursorShape: Qt.PointingHandCursor

    onClicked: {
      if (root.sink?.audio)
        root.sink.audio.muted = !root.sink.audio.muted;
    }

    onWheel: event => {
      if (!root.sink?.audio)
        return;
      const step = event.angleDelta.y > 0 ? 0.02 : -0.02;
      root.sink.audio.volume = Math.min(1.5, Math.max(0, root.sink.audio.volume + step));
    }
  }
}
