pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  property var colors: ({})
  property bool ready: false

  readonly property color warning: "#dc8746"
  readonly property color critical: "#d35d6e"
  readonly property real warnAt: 75
  readonly property real critAt: 90

  function get(name, fallback = "#ff00ff") {
    return root.colors[name] ?? fallback;
  }

  function level(value, warnAt = root.warnAt, critAt = root.critAt) {
    if (value > critAt)
      return "critical";
    if (value > warnAt)
      return "warning";
    return "normal";
  }

  // low-is-bad (battery)
  function levelLow(value, warnBelow = 40, critBelow = 25) {
    if (value < critBelow)
      return "critical";
    if (value < warnBelow)
      return "warning";
    return "normal";
  }

  function accent(level) {
    switch (level) {
    case "critical":
      return root.critical;
    case "warning":
      return root.warning;
    default:
      return root.get("primary");
    }
  }

  function foreground(level) {
    switch (level) {
    case "critical":
      return root.critical;
    case "warning":
      return root.warning;
    default:
      return root.get("primary_fixed", "#ffffff");
    }
  }

  function reload() {
    file.reload();
  }

  function parse(text) {
    try {
      root.colors = JSON.parse(text);
      root.ready = true;
    } catch (e) {
      console.error("Colors: parse failed:", e);
    }
  }

  FileView {
    id: file
    path: Quickshell.env("HOME") + "/.config/colors.json"
    watchChanges: true
    blockLoading: true

    onFileChanged: reload()
    onLoaded: root.parse(text())
    onLoadFailed: error => {
      console.error("Colors: load failed:", error);
    }
  }

  Component.onCompleted: {
    if (file.loaded)
      root.parse(file.text());
  }
}
