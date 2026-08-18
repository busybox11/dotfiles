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
    force_no_accel = true,
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

-- proart touchpad
hl.device({
  name = "ascp1a01:00-093a:3014-touchpad",
  natural_scroll = true,
  sensitivity = 1,
})

local function gesture_exec(command)
  return function()
    hl.dispatch(hl.dsp.exec_cmd(command))
  end
end

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

local volume_gesture = function(change) hl.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. math.abs(change) .. "%" .. (change<0 and "-" or "+")) end
hl.gesture({
  fingers = 3,
  direction = "vertical",
  action = {
    start = function(e) volume_gesture(-0.25 * e.delta.y) end,
    update = function(e) volume_gesture(-0.25 * e.delta.y) end
  }
})

hl.gesture({ fingers = 3, direction = "left", mods = "SUPER", action = gesture_exec("wtype -k XF86Back")})
hl.gesture({ fingers = 3, direction = "right", mods = "SUPER", action = gesture_exec("wtype -k XF86Forward")})

hl.gesture({ fingers = 4, direction = "left", action = gesture_exec("playerctl previous") })
hl.gesture({ fingers = 4, direction = "right", action = gesture_exec("playerctl next") })

hl.gesture({ fingers = 4, direction = "left", mods = "SUPER", action = gesture_exec("playerctl position 10-") })
hl.gesture({ fingers = 4, direction = "right", mods = "SUPER", action = gesture_exec("playerctl position 10+") })