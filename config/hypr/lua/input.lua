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

-- volume gesture debounce for perf
local vol_pending = 0
local vol_last_ms = 0
local VOL_MIN_MS = 50

local function volume_flush(time_ms, force)
  local elapsed = time_ms - vol_last_ms
  if not force and elapsed < VOL_MIN_MS then
    return
  end
  local step = vol_pending >= 0 and math.floor(vol_pending + 0.5) or math.ceil(vol_pending - 0.5)
  if step == 0 then
    if force then
      vol_pending = 0
    end
    return
  end
  vol_pending = vol_pending - step
  vol_last_ms = time_ms
  hl.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. math.abs(step) .. "%" .. (step < 0 and "-" or "+"))
end

local function volume_gesture(e)
  vol_pending = vol_pending + (-0.25 * e.delta.y)
  volume_flush(e.time_ms, false)
end

hl.gesture({
  fingers = 3,
  direction = "vertical",
  action = {
    start = function(e)
      vol_pending = 0
      vol_last_ms = e.time_ms - VOL_MIN_MS
      volume_gesture(e)
    end,
    update = function(e)
      volume_gesture(e)
    end,
    finish = function(e)
      volume_flush(e.time_ms, true)
    end,
  },
})

hl.gesture({ fingers = 3, direction = "left", mods = "SUPER", action = gesture_exec("wtype -k XF86Back")})
hl.gesture({ fingers = 3, direction = "right", mods = "SUPER", action = gesture_exec("wtype -k XF86Forward")})

hl.gesture({ fingers = 4, direction = "left", action = gesture_exec("playerctl previous") })
hl.gesture({ fingers = 4, direction = "right", action = gesture_exec("playerctl next") })

hl.gesture({ fingers = 4, direction = "left", mods = "SUPER", action = gesture_exec("playerctl position 10-") })
hl.gesture({ fingers = 4, direction = "right", mods = "SUPER", action = gesture_exec("playerctl position 10+") })