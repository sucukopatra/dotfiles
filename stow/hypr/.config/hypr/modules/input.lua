hl.config({
    input = {
        kb_layout  = "us,tr",
        kb_variant = "",
        kb_model   = "",
        kb_options = "grp:alt_shift_toggle",
        kb_rules   = "",
--	kb_options = "caps:swapescape",
        follow_mouse = 1,
	repeat_rate = 35,
	repeat_delay = 200,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})
