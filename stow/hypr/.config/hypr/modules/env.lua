hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
-- iGPU only: Hyprland never opens the dGPU, so it can drop into RTD3 (0W).
-- Use prime-run / __NV_PRIME_RENDER_OFFLOAD to wake the dGPU on demand (games).
-- Note: external displays wired to the NVIDIA GPU won't work in this mode.
hl.env("AQ_DRM_DEVICES", "/dev/dri/intel-igpu")

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
