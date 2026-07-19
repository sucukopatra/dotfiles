local terminal = "kitty"
local menu = "fuzzel"
local browser = "zen-browser"
local fileManager = "nautilus"
local mainMod = "SUPER"
local altMod = "ALT"

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("pgrep -x tty-clock && pkill tty-clock || kitty --title tty-clock -e tty-clock -s -S -c -b -n"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("pgrep -x bluetui && pkill bluetui || kitty --title bluetui -e bluetui"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("pgrep -x impala && pkill impala || kitty --title impala -e impala"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(altMod  .. " + space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + U", hl.dsp.layout("togglesplit"))
hl.bind(altMod .. "+W", hl.dsp.exec_cmd("pgrep -x waypaper && pkill waypaper || waypaper"))
hl.bind(mainMod .. "+G", hl.dsp.exec_cmd("pgrep -x pulsemixer && pkill pulsemixer || kitty --title pulsemixer -e pulsemixer"))

-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd("pidof slurp || if area=$(slurp); then grim -g \"$area\" - | tee >(wl-copy) > $(xdg-user-dir PICTURES)/screenshots/$(date +'%s_grim.png') && dunstify \"Screenshot of the region taken\" -t 1000; fi"))
hl.bind("SHIFT+Print", hl.dsp.exec_cmd("pidof slurp || if area=$(slurp); then grim -g \"$area\" - | tesseract stdin stdout quiet | wl-copy && dunstify \"OCR text copied\" -t 1000; fi"))
hl.bind(altMod .. "+Print", hl.dsp.exec_cmd("grim - | tee >(wl-copy) > $(xdg-user-dir PICTURES)/screenshots/$(date +'%s_grim.png') && dunstify \"Screenshot of the screen taken\" -t 1000"))

-- Clipboard
hl.bind(mainMod .. "+ C", hl.dsp.exec_cmd("cliphist list | cliphist decode | fuzzel --dmenu | cliphist encode | wl-copy"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

hl.bind(altMod .. " + h", hl.dsp.window.move({ direction = "left" }))
hl.bind(altMod .. " + l", hl.dsp.window.move({ direction = "right" }))
hl.bind(altMod .. " + k", hl.dsp.window.move({ direction = "up" }))
hl.bind(altMod .. " + j", hl.dsp.window.move({ direction = "down" }))

-- Fullscreen
hl.bind(mainMod .. " + f",  hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle"}))
hl.bind(mainMod .. " + SHIFT + f",  hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle"}))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end
--
-- To switch between windows in a floating workspace:
hl.bind(altMod .. " + TAB", function()
    hl.dispatch(hl.dsp.window.cycle_next())    -- Change focus to another window
    hl.dispatch(hl.dsp.window.bring_to_top()) -- Bring it to the top
end)

hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.resize({ x = 10, y = 0, relative = true}), { repeating = true })
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.resize({ x = -10, y = 0, relative = true}), { repeating = true })
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.resize({ x = 0, y = 10, relative = true}), { repeating = true })
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.resize({ x = 0, y = -10, relative = true}), { repeating = true })
    --
-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + SHIFT + S",         hl.dsp.workspace.toggle_special("magic"))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + TAB", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + SHIFT + TAB",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -d *_backlight -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -d *_backlight -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
