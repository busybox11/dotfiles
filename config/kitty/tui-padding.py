from typing import Any

from kitty.boss import Boss
from kitty.window import Window

TUI_COMMANDS = frozenset(
    {
        "nvim",
        "vim",
        "vi",
        "htop",
        "btop",
        "top",
        "opencode",
        "opencode2",
        "lazygit",
        "gitui",
    }
)
_WRAPPERS = frozenset({"sudo", "doas", "command", "env", "nice", "stdbuf"})
_EDGES = ("left", "right", "top", "bottom")
_UNWRAPPED = "-unwrapped"


def _basename(tok: str) -> str:
    slash = tok.rfind("/")
    base = tok[slash + 1 :] if slash >= 0 else tok
    # nix wrapped binaries exec as .<name>-unwrapped
    if base.startswith(".") and base.endswith(_UNWRAPPED):
        base = base[1 : -len(_UNWRAPPED)]
    return base


def _is_tui(cmdline: str) -> bool:
    for tok in cmdline.split():
        if tok.startswith("-") or tok in _WRAPPERS:
            continue
        return _basename(tok) in TUI_COMMANDS
    return False


def _set_padding(window: Window, zero: bool) -> None:
    if getattr(window, "_tui_unpadded", False) == zero:
        return
    window._tui_unpadded = zero
    val = 0.0 if zero else None
    for edge in _EDGES:
        window.patch_edge_width("padding", edge, val)
    tab = window.tabref()
    if tab is not None:
        tab.relayout()


def on_cmd_startstop(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    _set_padding(
        window,
        bool(data.get("is_start") and _is_tui(data.get("cmdline") or "")),
    )
