pragma Singleton

import Quickshell
import Quickshell.Services.Mpris
import QtQuick

Singleton {
  id: root

  property MprisPlayer player: null
  // MPRIS often blanks artUrl briefly on pause; keep last good URL
  property string stickyArtUrl: ""

  readonly property bool active: !!(player?.trackTitle && player?.trackArtist)
  readonly property string title: player?.trackTitle || "Unknown"
  readonly property string artist: player?.trackArtist || ""
  readonly property string artUrl: (player?.trackArtUrl || "") || stickyArtUrl
  readonly property bool isPlaying: player?.isPlaying ?? false

  onPlayerChanged: stickyArtUrl = player?.trackArtUrl || ""

  function rememberArt() {
    const u = player?.trackArtUrl || "";
    if (u)
      stickyArtUrl = u;
  }

  function toggle() {
    if (player?.canTogglePlaying)
      player.togglePlaying();
  }

  function next() {
    if (player?.canGoNext)
      player.next();
  }

  function previous() {
    if (player?.canGoPrevious)
      player.previous();
  }

  function adjustVolume(delta) {
    if (!player?.canControl)
      return;
    player.volume = Math.min(1, Math.max(0, player.volume + delta));
  }

  function hasFullMetadata(p) {
    return !!(p?.trackTitle && p?.trackArtist);
  }

  function isBrowser(p) {
    const id = `${p?.identity ?? ""} ${p?.dbusName ?? ""}`.toLowerCase();
    return /chrome|chromium|firefox|zen|helium|brave|vivaldi|edge|mozilla|plasma-browser|webkit/.test(id);
  }

  function updatePlayer() {
    const all = Mpris.players.values;
    const eligible = all.filter(hasFullMetadata);
    const playing = eligible.filter(p => p.isPlaying);

    if (playing.length > 0) {
      if (playing.includes(root.player))
        return;
      root.player = playing.find(p => !isBrowser(p)) ?? playing[0];
      return;
    }

    // Nothing playing: keep current while still registered (metadata can blip on pause)
    if (root.player && all.includes(root.player))
      return;

    root.player = eligible.find(p => !isBrowser(p)) ?? eligible[0] ?? null;
  }

  Connections {
    target: Mpris.players
    function onValuesChanged() {
      root.updatePlayer();
    }
  }

  Connections {
    target: root.player
    function onTrackArtUrlChanged() {
      root.rememberArt();
    }
  }

  Instantiator {
    model: Mpris.players

    Connections {
      required property MprisPlayer modelData
      target: modelData

      function onPlaybackStateChanged() {
        root.updatePlayer();
      }

      function onTrackTitleChanged() {
        root.updatePlayer();
      }

      function onTrackArtistChanged() {
        root.updatePlayer();
      }
    }
  }

  Component.onCompleted: updatePlayer()
}
