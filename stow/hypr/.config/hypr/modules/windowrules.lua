-- separate rules
hl.window_rule({
    name = "pulsemixer",
    match = { initial_title = "pulsemixer" },
    float = true,
    center = true,
    size = { 900, 600 },
    stay_focused = true,
    dim_around = true,
})

hl.window_rule({
    name = "bluetui",
    match = { initial_title = "bluetui" },
    float = true,
    center = true,
    size = { 900, 600 },
    stay_focused = true,
    dim_around = true,
})

hl.window_rule({
    name = "impala",
    match = { initial_title = "impala" },
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
