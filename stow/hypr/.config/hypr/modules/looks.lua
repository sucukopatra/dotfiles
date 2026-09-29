hl.config({
    general = {
	snap = {
	    enabled = true,
	    window_gap = 20,
	    monitor_gap = 20
	},
        gaps_in  = 5,
        gaps_out = 20,
        border_size = 0,
        resize_on_border = true,
        layout = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = false,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled   = false,
            size      = 3,
            passes    = 1,
            vibrancy  = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

