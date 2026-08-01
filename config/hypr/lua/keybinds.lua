local terminal = "kitty"
local fileManager = "nautilus"
local mainMod = "SUPER"
local mainModShift = "SUPER + SHIFT"
local osdBright = "~/.config/quickshell/scripts/brightness"
local osdCaps = "~/.config/quickshell/scripts/caps-osd"
local shot = "bash ~/.config/hypr/scripts/hyprshot.sh"

local function exec(keys, command, opts)
  hl.bind(keys, hl.dsp.exec_cmd(command), opts)
end

hl.bind(mainModShift .. " + A", hl.dsp.window.close())
exec(mainModShift .. " + L", "uwsm stop")
hl.bind(mainModShift .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + K", hl.dsp.layout("swapsplit"))

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

for i = 1, 12 do
  local keycode = i + 9
  hl.bind(mainMod .. " + code:" .. keycode, hl.dsp.focus({ workspace = i }))
  hl.bind(mainModShift .. " + code:" .. keycode, hl.dsp.window.move({ workspace = i }))
  hl.bind(mainModShift .. " + CTRL + code:" .. keycode, hl.dsp.window.move({ workspace = i, silent = true }))
end

hl.bind(mainMod .. " + code:49", hl.dsp.focus({ workspace = "previous_per_monitor" }))
hl.bind(mainModShift .. " + code:49", hl.dsp.workspace.swap_monitors({ monitor1 = 0, monitor2 = 1 }))
hl.bind("ALT + TAB", hl.dsp.focus({ workspace = "m+1" }))
hl.bind("SHIFT + ALT + TAB", hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + CTRL + left", hl.dsp.focus({ workspace = "m-1" }))

local keypad = {
  KP_End = 1,
  KP_Down = 2,
  KP_Next = 3,
  KP_Left = 4,
  KP_Begin = 5,
  KP_Right = 6,
  KP_Home = 7,
  KP_Up = 8,
  KP_Prior = 9,
  KP_Insert = 10,
}
for key, workspace in pairs(keypad) do
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
end

hl.bind(mainMod .. " + W", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainModShift .. " + mouse_down", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainModShift .. " + mouse_up", hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

exec("XF86AudioRaiseVolume", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+", { locked = true, repeating = true })
exec("XF86AudioLowerVolume", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-", { locked = true, repeating = true })
exec("XF86AudioMute", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", { locked = true, repeating = true })
exec("XF86AudioMicMute", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle", { locked = true, repeating = true })
exec("XF86MonBrightnessUp", osdBright .. " +5%", { locked = true, repeating = true })
exec("XF86MonBrightnessDown", osdBright .. " 5%-", { locked = true, repeating = true })
exec("CTRL + XF86AudioMute", "playerctl play-pause", { locked = true })
exec("CTRL + XF86AudioLowerVolume", "playerctl previous", { locked = true })
exec("CTRL + XF86AudioRaiseVolume", "playerctl next", { locked = true })
exec("Caps_Lock", osdCaps, { release = true })
exec("XF86AudioPlay", "playerctl play-pause", { locked = true })
exec("XF86AudioNext", "playerctl next", { locked = true })
exec("XF86AudioPrev", "playerctl previous", { locked = true })
exec("XF86AudioStop", "playerctl stop", { locked = true })

exec("META + CTRL + mouse_up", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+", { locked = true, repeating = true })
exec("META + CTRL + mouse_down", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-", { locked = true, repeating = true })
exec("META + ALT + SHIFT + mouse_left", "playerctl position 5+", { locked = true, repeating = true })
exec("META + ALT + SHIFT + mouse_right", "playerctl position 5-", { locked = true, repeating = true })
exec("META + CTRL + SHIFT + mouse:276", "playerctl next", { locked = true })
exec("META + CTRL + SHIFT + mouse:275", "playerctl previous", { locked = true })
exec("META + CTRL + SHIFT + mouse:277", "playerctl play-pause", { locked = true })
exec("META + CTRL + SHIFT + mouse_down", "playerctl volume 0.1+", { locked = true, repeating = true })
exec("META + CTRL + SHIFT + mouse_up", "playerctl volume 0.1-", { locked = true, repeating = true })
exec("META + CTRL + SHIFT + left", "playerctl previous", { locked = true, repeating = true })
exec("META + CTRL + SHIFT + right", "playerctl next", { locked = true, repeating = true })
exec("META + CTRL + up", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+", { locked = true, repeating = true })
exec("META + CTRL + down", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-", { locked = true, repeating = true })
exec("META + ALT + SHIFT + up", "playerctl position 5+", { locked = true, repeating = true })
exec("META + ALT + SHIFT + down", "playerctl position 5-", { locked = true, repeating = true })

hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
exec(mainMod .. " + SHIFT + F", "hyprctl dispatch fullscreenstate 0 3")
exec("CTRL + META + ALT + SHIFT + L", "xdg-open https://www.linkedin.com/", { locked = true })

exec(mainMod .. " + PRINT", shot .. " '-m window -s'")
exec(mainModShift .. " + PRINT", shot .. " '-m window -s'")
exec("PRINT", shot .. " '--freeze -m output'")
exec("SHIFT + PRINT", shot .. " '-m active -m output'")
exec("META + CTRL + SHIFT + S", shot .. " '--freeze -m output -s' '󰉏  saved'")
exec("CTRL + PRINT", shot .. " '-m region -s'")
exec("CTRL + SHIFT + PRINT", shot .. " '-m region -s'")
exec("META + SHIFT + S", shot .. " '-m region -s' '  copied'")
exec("META + F1", "~/.config/hypr/scripts/gamemode.sh")
exec(mainModShift .. " + F1", "hyprctl reload")

exec(mainModShift .. " + SPACE", "uwsm-app -- swaync-client -t -sw")
exec(mainMod .. " + RETURN", "uwsm-app -- " .. terminal .. " --single-instance")
exec(mainMod .. " + L", "uwsm-app -- hyprlock")
exec(mainMod .. " + Z", "uwsm-app -- zen-twilight")
exec(mainMod .. " + H", "uwsm-app -- helium-browser")
exec(mainMod .. " + C", "uwsm-app -- cursor")
exec(mainMod .. " + S", "uwsm-app -- spotify")
exec(mainMod .. " + D", "uwsm-app -- equibop")
exec(mainMod .. " + E", "uwsm-app -- " .. fileManager)

exec(mainMod .. " + Space", "uwsm-app -- vicinae toggle")
exec("CTRL + SUPER + Space", "uwsm-app -- vicinae toggle")
exec(mainMod .. " + V", "uwsm-app -- vicinae vicinae://extensions/vicinae/clipboard/history")
hl.bind(
  "CTRL + SUPER + V",
  hl.dsp.exec_cmd("uwsm-app -- vicinae vicinae://extensions/vicinae/clipboard/history", {
    stayfocused = true,
    dimaround = true,
  }),
  { locked = true }
)
exec(mainMod .. " + TAB", "uwsm-app -- vicinae vicinae://extensions/vicinae/wm/switch-windows")
exec(mainMod .. " + ALT + SPACE", "uwsm-app -- bash ~/dev/dotfiles/scripts/modes_menu.sh")
exec("ALT + CTRL + SHIFT + S", "uwsm-app -- vicinae vicinae://extensions/mattisssa/spotify-player/queue")
exec("ALT + CTRL + SHIFT + G", "uwsm-app -- vicinae vicinae://extensions/thomaslombart/github/notifications")
exec("SUPER + SHIFT + CTRL + SPACE", "vicinae vicinae://extensions/busybox11/rainworkflow/search-discord")
