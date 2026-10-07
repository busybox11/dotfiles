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

local hostname = read_hostname()
local is_chaeri = hostname == "chaeri"

local AOC_CU34 = "desc:AOC CU34G2XP 1Q1Q7HA012666"
local CHAERI_EDP = "desc:Samsung Display Corp. ATNA60HR07-0"

-- home monitors
-- HP 23" | AOC 34" | chaeri eDP
hl.monitor({ output = "desc:Hewlett Packard HP E232 3CQ6030YX6", mode = "1920x1080@60", position = "0x0", scale = 1 })
hl.monitor({
	output = AOC_CU34,
	mode = is_chaeri and "3440x1440@144" or "3440x1440@180",
	position = "1920x0",
	scale = 1,
	bitdepth = 10,
})

-- work monitors
hl.monitor({
	output = "desc:LG Display 0x0738",
	mode = "1920x1080@120",
	scale = 1,
	position = "0x0",
})
hl.monitor({
	output = "desc:Dell Inc. DELL E2211H NJ91T19Q584U",
	mode = "1920x1080@60",
	position = "2400x0",
})
hl.monitor({
	output = "desc:Philips Consumer Electronics Company 222S9 UK02435068302",
	mode = "1920x1080@75",
	position = "1920x0",
})
hl.monitor({
	output = "desc:Dell Inc. DELL E2210H D553R0961DJU",
	mode = "1920x1080@60",
	position = "3840x0",
})

-- sunshine monitors
hl.monitor({ output = "tablet", mode = "2944x1840@120", position = "auto", scale = 1.6 })
hl.monitor({ output = "laptop", mode = "2560x1440@165", position = "0x0", scale = 1 })
hl.monitor({ output = "work", mode = "1920x1080@120", position = "auto", scale = 1 })

-- fallbacks
-- hl.monitor({ output = "eDP-1", mode = "2560x1440@165.00301", position = "0x0", scale = 1, bitdepth = 8, vrr = 1 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.monitor({ output = "Unknown-1", disabled = true })

-- chaeri eDP: 1.333 when AOC is docked, 1.2 solo
if is_chaeri then
	local scale_with_aoc = 1.333
	local scale_solo = 1.2
	local last_scale

	local function aoc_connected()
		local needle = AOC_CU34:match("^desc:(.+)$")
		for _, monitor in ipairs(hl.get_monitors()) do
			if monitor.description == needle then
				return true
			end
		end
		return false
	end

	local function apply_chaeri_edp()
		local scale = aoc_connected() and scale_with_aoc or scale_solo
		if scale == last_scale then
			return
		end
		last_scale = scale
		hl.monitor({
			output = CHAERI_EDP,
			mode = "2880x1800@120",
			position = "5360x0",
			scale = scale,
			bitdepth = 10,
			vrr = 1,
			cm = "dcip3",
		})
	end

	local sync_timer = hl.timer(apply_chaeri_edp, { timeout = 200, type = "oneshot" })
	sync_timer:set_enabled(false)

	local function schedule_chaeri_edp()
		sync_timer:set_enabled(false)
		sync_timer:set_enabled(true)
	end

	hl.on("monitor.added", schedule_chaeri_edp)
	hl.on("monitor.removed", schedule_chaeri_edp)
	hl.on("hyprland.start", schedule_chaeri_edp)
	hl.on("config.reloaded", function()
		last_scale = nil
		schedule_chaeri_edp()
	end)

	apply_chaeri_edp()
end

hl.config({
	cursor = {
		no_hardware_cursors = 0,
		default_monitor = AOC_CU34,
	},
})
