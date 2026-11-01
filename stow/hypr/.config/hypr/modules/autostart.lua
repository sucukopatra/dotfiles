hl.on("hyprland.start", function()
  -- share the .zprofile env with systemd/dbus-launched apps so they stay out of ~ too
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
  hl.exec_cmd("~/.config/hypr/scripts/random-wallpaper.sh")
end)
