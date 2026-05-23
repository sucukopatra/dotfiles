hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- NVIDIA: VA-API hardware video decode via libva-nvidia-driver
hl.env("LIBVA_DRIVER_NAME", "iHD")
--hl.env("NVD_BACKEND", "direct")

-- NVIDIA: XWayland apps use NVIDIA GLX
--hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-- Native Wayland for Electron and Firefox
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- Toolkit backends: prefer Wayland, fall back to X11
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- XDG: needed for desktop portals (screen share, file picker, etc.)
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

