local function read_hostname()
	local hostname = os.getenv("HOSTNAME")
	if hostname and hostname ~= "" then
		return hostname
	end

	local file = io.open("/etc/hostname", "r")
	if not file then
		return ""
	end

	hostname = file:read("*l") or ""
	file:close()

	return hostname
end

local function set_env(vars)
	for key, value in pairs(vars) do
		hl.env(key, value)
	end
end

local hostname = read_hostname()

set_env({
	XCURSOR_THEME = "elementary",
	HYPRCURSOR_THEME = "hyprelementary",
	XCURSOR_SIZE = "12",
	HYPRCURSOR_SIZE = "24",

	CLUTTER_BACKEND = "wayland",
	GDK_BACKEND = "wayland,x11,*",

	QT_AUTO_SCREEN_SCALE_FACTOR = "1",
	QT_QPA_PLATFORM = "wayland;xcb",
	QT_QPA_PLATFORMTHEME = "qt6ct",
	QT_SCALE_FACTOR = "1",
	QT_WAYLAND_DISABLE_WINDOWDECORATION = "1",

	XDG_CURRENT_DESKTOP = "Hyprland",
	XDG_SESSION_DESKTOP = "Hyprland",
	XDG_SESSION_TYPE = "wayland",

	MOZ_ENABLE_WAYLAND = "1",
	ELECTRON_OZONE_PLATFORM_HINT = "auto",
	WLR_RENDERER_ALLOW_SOFTWARE = "1",

	SDL_VIDEODRIVER = "wayland",
	EGL_PLATFORM = "wayland",
})

local gpu_profiles = {
	chaeri = {
		LIBVA_DRIVER_NAME = "radeonsi",
		GBM_BACKEND = "drm",
	},
	default = {
		LIBVA_DRIVER_NAME = "nvidia",
		GBM_BACKEND = "nvidia-drm",
		__GLX_VENDOR_LIBRARY_NAME = "nvidia",
		__NV_PRIME_RENDER_OFFLOAD = "1",

		MOZ_DISABLE_RDD_SANDBOX = "1",
		NVD_BACKEND = "direct",
		__EGL_VENDOR_LIBRARY_FILENAMES = "/usr/share/glvnd/egl_vendor.d/10_nvidia.json",
		CUDA_DISABLE_PERF_BOOST = "1",

		__GL_SHADER_DISK_CACHE = "1",
		__GL_SHADER_DISK_CACHE_CLEANUP = "1",
		__GL_SHADER_DISK_CACHE_SIZE = "10",
		__GL_GSYNC_ALLOWED = "1",
		__GL_VRR_ALLOWED = "1",
	},
}

set_env(gpu_profiles[hostname] or gpu_profiles.default)
