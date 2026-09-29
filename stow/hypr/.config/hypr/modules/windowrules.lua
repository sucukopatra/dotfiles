hl.window_rule({
    name = "tui-popups",
    match = { initial_title = "pulsemixer|bluetui|tty-clock|impala" },
    float = true,
    center = true,
    size = { 900, 600 },
    stay_focused = true,
    dim_around = true,
})

hl.window_rule({
    name = "waypaper",
    match = { class = "waypaper" },
    float = true,
    center = true,
    size = { 900, 600 },
    stay_focused = true,
    dim_around = true,
})

hl.window_rule({
    name = "file-roller",
    match = { class = "org.gnome.FileRoller" },
    float = true
})
