local colors = require("lua/colors")

local function layer(rule)
  hl.layer_rule(rule)
end

local function window(rule)
  hl.window_rule(rule)
end

layer({ name = "bubbles", match = { namespace = "class:(bubbles.scr)" }, blur = true })
layer({ name = "control-center", match = { namespace = "(swaync-control-center|quickshell-notifications-center)" }, blur = true, dim_around = true, ignore_alpha = 0.1 })
layer({ name = "notifications", match = { namespace = "(swaync-notification-window|quickshell-notifications)" }, blur = true, animation = "slide", ignore_alpha = 0.25 })
layer({ name = "osd", match = { namespace = "^(swayosd|quickshell-osd)$" }, blur = true, ignore_alpha = 0.3, above_lock = 2 })
layer({ name = "selection", match = { namespace = "^(hyprpicker|selection)$" }, no_anim = true })
layer({ name = "wallpaper", match = { namespace = "^(hyprpaper|wallpaper)$" }, animation = "popin 80%" })
layer({ name = "bars", match = { namespace = "^(waybar|eww|quickshell)$" }, blur = true, ignore_alpha = 0.9 })

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
  stay_focused = true,
  dim_around = true,
  center = true,
})

hl.window_rule({
  name = "fake-fullscreen",
  match = {
    class = "cursor"
  },
  fullscreen_state = "0 3"
})

hl.workspace_rule({
  workspace = "w[tv1]s[false]",
  gaps_out = 0,
  gaps_in = 0,
})
window({
  name = "smart-gaps-tiled",
  match = { float = false, workspace = "w[tv1]s[false]" },
  border_size = 0,
  rounding = 0,
})

window({
  name = "bitwarden",
  match = { class = "chrome-nngceckbapebfimnlniiiahkandclblb-Default" },
  float = true,
  -- for some reason the initial paint renders only 480px width, transparent after or cuts if lesser than 480
  -- the window properly rerenders with the right size if it is manually resized
  -- good enough workaround for now
  size = "480 800",
  center = true,
  dim_around = true,
})

hl.on("window.title", function(w)
  local prefix = "Extension: (Bitwarden Password Manager)"
  if w.title:sub(1, #prefix) == prefix then
      local monitor = hl.get_active_monitor()
      if monitor == nil then
          return
      end

      local win = { width = 500, height = 800 }
      local pos = { x = monitor.width - win.width - 40, y = 160 }

      hl.dispatch(hl.dsp.window.float({ action = "enable", window = w }))
      hl.dispatch(hl.dsp.window.resize({ x = win.width, y = win.height, relative = false, window = w }))
      hl.dispatch(hl.dsp.window.center({ window = w }))
      hl.dispatch(hl.dsp.window.set_prop({ prop = "dim_around", value = "true", window = w }))
  end
end)


local barMonitor
local barGapsRule
local barSmartGapsRule

local function syncBarGaps()
  local name
  for _, layer in ipairs(hl.get_layers()) do
    if layer.namespace == "quickshell" and layer.mapped and layer.monitor then
      name = layer.monitor.name
      break
    end
  end
  if name == barMonitor then
    return
  end
  barMonitor = name
  if barGapsRule then
    barGapsRule:set_enabled(false)
    barGapsRule = nil
  end
  if barSmartGapsRule then
    barSmartGapsRule:set_enabled(false)
    barSmartGapsRule = nil
  end
  if not name then
    return
  end
  barGapsRule = hl.workspace_rule({
    workspace = "m[" .. name .. "]",
    gaps_out = { top = 0, bottom = 8, left = 8, right = 8 },
  })
  barSmartGapsRule = hl.workspace_rule({
    workspace = "w[tv1]s[false]m[" .. name .. "]",
    gaps_out = 0,
  })
end

local function onBarLayer(layer)
  if layer and layer.namespace == "quickshell" then
    syncBarGaps()
  end
end

hl.on("layer.opened", onBarLayer)
hl.on("layer.closed", onBarLayer)
hl.on("monitor.added", syncBarGaps)
hl.on("monitor.removed", syncBarGaps)
hl.on("monitor.layout_changed", syncBarGaps)
hl.on("hyprland.start", syncBarGaps)
hl.on("config.reloaded", syncBarGaps)
syncBarGaps()

hl.workspace_rule({ workspace = "1", monitor = "DP-1", default_name = "󰖟" })
hl.workspace_rule({ workspace = "2", default = true, default_name = "" })
hl.workspace_rule({ workspace = "3", default_name = "󰨞" })
hl.workspace_rule({ workspace = "4", default_name = "" })
hl.workspace_rule({ workspace = "10", default_name = "󰍥" })
