local colors = require("lua/colors")

local function layer(rule)
  hl.layer_rule(rule)
end

local function window(rule)
  hl.window_rule(rule)
end

layer({ name = "bubbles", match = { namespace = "class:(bubbles.scr)" }, blur = true })
layer({ name = "control-center", match = { namespace = "swaync-control-center" }, blur = true, dim_around = true, ignore_alpha = 0 })
layer({ name = "notifications", match = { namespace = "swaync-notification-window" }, blur = true, animation = "slide", ignore_alpha = 0 })
layer({ name = "osd", match = { namespace = "^(swayosd|quickshell-osd)$" }, blur = true, ignore_alpha = 0.3, above_lock = 2 })
layer({ name = "selection", match = { namespace = "^(hyprpicker|selection)$" }, no_anim = true })
layer({ name = "wallpaper", match = { namespace = "^(hyprpaper|wallpaper)$" }, animation = "popin 80%" })
layer({ name = "bars", match = { namespace = "^(waybar|eww|quickshell)$" }, blur = true, ignore_alpha = 0 })

window({ name = "genshin", match = { class = "genshinimpact.exe" }, immediate = true })
window({
  name = "pip",
  match = { title = "^(Picture-in-Picture|Picture in picture)$" },
  pin = true,
  float = true,
  size = "(monitor_w*0.25) (monitor_h*0.25)",
  move = "((monitor_w*0.72)) ((monitor_h*0.07))",
})
window({
  name = "xwaylandvideobridge",
  match = { class = "^(xwaylandvideobridge)$" },
  opacity = "0.0 override 0.0 override",
  no_anim = true,
  no_initial_focus = true,
  max_size = "1 1",
  no_blur = true,
})
window({
  name = "xdgfilepicker-tag",
  match = { title = "^(Open File(s)?|Open Folder(s)?|File Upload(.*)|Select Folder to Upload(.*))$" },
  tag = "+xdgfilepicker",
})
window({
  name = "xdgfilepicker",
  match = { tag = "xdgfilepicker" },
  center = true,
  float = true,
  dim_around = true,
  size = "(monitor_w*0.45) (monitor_h*0.6)",
})
window({
  name = "suppress-maximize-events",
  match = { class = ".*" },
  suppress_event = "maximize",
})
window({ name = "errored-window", match = { tag = "bell" }, border_color = colors.error .. " " .. colors.error })
window({ name = "urgent-window", match = { tag = "urgent" }, border_color = colors.error_container .. " " .. colors.error_container })
window({
  name = "vicinae",
  match = { class = "vicinae" },
  float = true,
  size = "622 652",
  stay_focused = true,
  dim_around = true,
  center = true,
})

hl.workspace_rule({ workspace = "1", monitor = "DP-1", default_name = "󰖟" })
hl.workspace_rule({ workspace = "2", default = true, default_name = "" })
hl.workspace_rule({ workspace = "3", default_name = "󰨞" })
hl.workspace_rule({ workspace = "4", default_name = "" })
hl.workspace_rule({ workspace = "10", default_name = "󰍦" })
