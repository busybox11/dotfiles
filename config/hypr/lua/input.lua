hl.config({
  input = {
    kb_layout = "fr",
    kb_variant = "",
    kb_model = "",
    kb_options = "",
    kb_rules = "",
    numlock_by_default = true,
    follow_mouse = 1,
    sensitivity = 1,
    accel_profile = "flat",
    touchpad = {
      natural_scroll = true,
    },
  },
})

hl.device({
  name = "usb-optical-mouse-",
  sensitivity = -0.05,
})

hl.device({
  name = "mouse-passthrough",
  natural_scroll = true,
})

local function gesture_exec(command)
  return function()
    hl.dispatch(hl.dsp.exec_cmd(command))
  end
end

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "up", action = gesture_exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+") })
hl.gesture({ fingers = 3, direction = "down", action = gesture_exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-") })
hl.gesture({ fingers = 4, direction = "left", action = gesture_exec("playerctl previous") })
hl.gesture({ fingers = 4, direction = "right", action = gesture_exec("playerctl next") })
hl.gesture({ fingers = 4, direction = "left", mods = "SUPER", action = gesture_exec("playerctl position 10-") })
hl.gesture({ fingers = 4, direction = "right", mods = "SUPER", action = gesture_exec("playerctl position 10+") })
