hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.monitor({
	output = "desc:Samsung Display Corp. ATNA60HR07-0",
	mode = "2880x1800@120",
	position = "5360x0",
	scale = 1.6,
	bitdepth = 10,
	vrr = 1,
})
local hostname = os.getenv("HOSTNAME")
hl.monitor({
	output = "desc:AOC CU34G2XP 1Q1Q7HA012666",
	mode = hostname == "chaeri" and "3440x1440@100" or "3440x1440@180",
	position = "1920x0",
	scale = 1,
	bitdepth = 10,
})
hl.monitor({ output = "desc:Hewlett Packard HP E232 3CQ6030YX6", mode = "1920x1080@60", position = "0x0", scale = 1 })
hl.monitor({ output = "desc:NEC Corporation NP-MC332W G98000022", mode = "1280x720@60", position = "2560x0", scale = 1 })
hl.monitor({ output = "desc:NEC Corporation NP-ME383W 0x01010101", mode = "1920x1080@60", position = "0x0", scale = 1 })
-- hl.monitor({ output = "eDP-1", mode = "2560x1440@165.00301", position = "0x0", scale = 1, bitdepth = 8, vrr = 1 })
hl.monitor({ output = "desc:LG Electronics LG TV 0x01010101", mode = "1920x1080@60", position = "auto", scale = 1 })
hl.monitor({ output = "desc:AOC 24B2W1 0x00000D8C", mode = "1920x1080@74.97", position = "auto", scale = 1 })
hl.monitor({
	output = "desc:Xiaomi Corporation Mi monitor 5505610034644",
	mode = "3440x1440@100",
	position = "auto",
	scale = 1,
})
hl.monitor({
	output = "desc:Shenzhen KTC Technology Group H27S17 0x00000001",
	mode = "2560x1440@144",
	position = "auto",
	scale = 1,
})
hl.monitor({ output = "desc:___ LCD TV", mode = "1920x1080@60", position = "0x0", scale = 1 })
hl.monitor({ output = "desc:NEC Corporation NP-ME402X G14000130", mode = "1280x720@60", position = "auto", scale = 1 })
hl.monitor({ output = "Unknown-1", disabled = true })
hl.monitor({ output = "tablet", mode = "2944x1840@120", position = "auto", scale = 1.6 })
hl.monitor({ output = "laptop", mode = "2560x1440@165", position = "0x0", scale = 1 })
hl.monitor({ output = "work", mode = "1920x1080@120", position = "auto", scale = 1 })

hl.config({
	cursor = {
		no_hardware_cursors = false,
		default_monitor = "DP-1",
	},
})
