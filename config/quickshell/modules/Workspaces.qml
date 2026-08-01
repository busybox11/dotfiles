import Quickshell
import Quickshell.Hyprland
import QtQuick
import Qt5Compat.GraphicalEffects
import qs.components

MouseArea {
  id: root

  readonly property var workspace1: Hyprland.workspaces.values.find(w => w.id === 1) ?? null

  implicitWidth: row.implicitWidth
  implicitHeight: 40
  acceptedButtons: Qt.NoButton

  function withAlpha(hex, a) {
    const c = Qt.color(hex);
    return Qt.rgba(c.r, c.g, c.b, a);
  }

  function hasTag(workspace, tag) {
    if (!workspace)
      return false;
    for (const t of workspace.toplevels.values) {
      const tags = t.lastIpcObject?.tags ?? [];
      if (tags.includes(tag))
        return true;
    }
    return workspace.urgent && tag === "urgent";
  }

  function entryColor(workspace, isLogo = false) {
    if (!workspace)
      return withAlpha(Colors.get("primary"), 0.4);
    if (hasTag(workspace, "urgent") && !workspace.focused)
      return "#d35d6e";
    if (hasTag(workspace, "bell") && !workspace.focused)
      return "#dc8746";
    if (workspace.focused)
      return Colors.get("primary_fixed");
    if (workspace.active)
      return withAlpha(Colors.get("primary"), !isLogo ? 0.75 : 1);
    return withAlpha(Colors.get("primary"), !isLogo ? 0.4 : 1);
  }

  function logoOpacity(workspace) {
    if (!workspace)
      return 0.75;
    if (workspace.focused)
      return 1;
    if (hasTag(workspace, "urgent") || hasTag(workspace, "bell"))
      return 0.85;
    return 0.4;
  }
  
  function switchWorkspace(target) {
    if (Hyprland.usingLua) {
      Hyprland.dispatch(`hl.dsp.focus({ workspace = ${target} })`);
    } else {
      Hyprland.dispatch(`workspace ${target}`);
    }
  }

  onWheel: event => {
    const current = Hyprland.focusedWorkspace?.id ?? 1;
    const next = Math.min(10, Math.max(1, current + (event.angleDelta.y < 0 ? 1 : -1)));
    if (next !== current)
      switchWorkspace(next);
  }

  Row {
    id: row
    anchors.verticalCenter: parent.verticalCenter

    MouseArea {
      id: ws1
      implicitWidth: 40
      implicitHeight: 40
      anchors.verticalCenter: parent.verticalCenter
      cursorShape: Qt.PointingHandCursor
      onClicked: switchWorkspace(1);

      Image {
        id: logo
        anchors.centerIn: parent
        width: 26
        height: 16
        source: Qt.resolvedUrl("../assets/nina_widget.svg")
        sourceSize: Qt.size(26, 16)
        asynchronous: true
        visible: false
      }

      ColorOverlay {
        anchors.fill: logo
        source: logo
        color: root.entryColor(root.workspace1, true)
        opacity: root.logoOpacity(root.workspace1)
      }
    }

    Repeater {
      model: Hyprland.workspaces

      MouseArea {
        id: entry

        required property HyprlandWorkspace modelData

        visible: modelData.id > 1
        implicitWidth: 30
        implicitHeight: 40
        anchors.verticalCenter: parent.verticalCenter
        cursorShape: Qt.PointingHandCursor
        onClicked: modelData.activate()

        BarText {
          id: label
          anchors.centerIn: parent
          text: entry.modelData.name
          color: root.entryColor(entry.modelData, false)
        }
      }
    }
  }
}
