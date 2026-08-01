hl.config({
  dwindle = {
    preserve_split = true,
    smart_split = true,
    split_width_multiplier = 1.3,
  },
  master = {
    new_status = "master",
  },
  misc = {
    force_default_wallpaper = -1,
    disable_hyprland_logo = true,
    vrr = 0,
  },
  binds = {
    workspace_back_and_forth = true,
    allow_workspace_cycles = true,
    pass_mouse_when_bound = false,
    scroll_event_delay = 0,
    workspace_center_on = 1,
  },
  opengl = {
    nvidia_anti_flicker = true,
  },
  render = {
    direct_scanout = 0,
    new_render_scheduling = true,
    send_content_type = false,
  },
  xwayland = {
    force_zero_scaling = true,
  },
})
