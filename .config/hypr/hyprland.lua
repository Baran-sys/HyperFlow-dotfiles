-- Hyprland 0.57+ Lua Configuration
-- Translated from ~/.config/hypr/hyprland.conf & monitors.conf

local home        = os.getenv("HOME") or "/home/bren"
local terminal    = home .. "/.local/bin/launch-app kitty"
local fileManager = home .. "/.local/bin/launch-app dolphin"
local menu        = home .. "/.local/bin/spotlight-menu"
local browser     = home .. "/.local/bin/launch-app firefox"
local notes       = home .. "/.local/bin/launch-app obsidian"
local editor      = home .. "/.local/bin/launch-app gnome-text-editor"
local editorAlt   = home .. "/.local/bin/launch-app code"
local colorPicker = "hyprpicker"

------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@165",
    position = "auto",
    scale    = 1.25,
})

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("PATH", home .. "/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin")
hl.env("XCURSOR_SIZE", "20")
hl.env("HYPRCURSOR_SIZE", "20")
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("HYPRCURSOR_THEME", "Adwaita")

hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("NVD_BACKEND", "direct")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- QT
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_STYLE_OVERRIDE", "kvantum")

-- Toolkit Backend Variables
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")

-- XDG Specifications
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
    hl.exec_cmd("/usr/bin/dunst")
    hl.exec_cmd(home .. "/.local/bin/waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd(home .. "/.local/bin/desktop-manager")
    hl.exec_cmd("hyprlock || hyprctl dispatch 'hl.dsp.exit()'")
    hl.exec_cmd("sleep 1 && hyprctl dismissnotify -1")
    hl.exec_cmd("wl-paste --type text --watch cliphist -max-items 50 store")
    hl.exec_cmd("wl-paste --type image --watch cliphist -max-items 50 store")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("hyprctl setcursor Adwaita 20")
end)

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 5,
        border_size = 2,
        col = {
            active_border   = "rgb(cba6f7)",
            inactive_border = "rgba(585b7080)",
        },
        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding         = 10,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        blur = {
            enabled           = true,
            size              = 3,
            passes            = 3,
            new_optimizations = true,
            vibrancy          = 0.1696,
            ignore_opacity    = true,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        vrr                      = 0,
        disable_watchdog_warning = true,
        focus_on_activate        = true,
    },

    xwayland = {
        force_zero_scaling = true,
    },

    input = {
        kb_layout                   = "tr,us",
        kb_options                  = "grp:alt_shift_toggle",
        kb_variant                  = "",
        kb_model                    = "",
        kb_rules                    = "",
        numlock_by_default          = true,
        follow_mouse                = 1,
        float_switch_override_focus = 0,
        sensitivity                 = 0.42,
        touchpad = {
            natural_scroll = true,
        },
    },

    cursor = {
        no_hardware_cursors  = false,
        enable_hyprcursor    = false,
        sync_gsettings_theme = true,
    },
})

--------------------
---- ANIMATIONS ----
--------------------

hl.curve("wind",   { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("winIn",  { type = "bezier", points = { {0.1, 1.1},  {0.1, 1.1}  } })
hl.curve("winOut", { type = "bezier", points = { {0.3, -0.3}, {0, 1}      } })
hl.curve("liner",  { type = "bezier", points = { {1, 1},      {1, 1}      } })

hl.animation({ leaf = "windows",     enabled = true, speed = 6,  bezier = "wind",    style = "slide" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 6,  bezier = "winIn",   style = "slide" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 5,  bezier = "winOut",  style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5,  bezier = "wind",    style = "slide" })
hl.animation({ leaf = "border",      enabled = true, speed = 1,  bezier = "liner" })
hl.animation({ leaf = "fade",        enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 5,  bezier = "wind" })
hl.animation({ leaf = "layers",      enabled = true, speed = 6,  bezier = "wind",    style = "slide" })
hl.animation({ leaf = "layersIn",    enabled = true, speed = 6,  bezier = "winIn",   style = "slide" })
hl.animation({ leaf = "layersOut",   enabled = true, speed = 5,  bezier = "winOut",  style = "slide" })

----------------------------
---- GESTURES & DEVICES ----
----------------------------

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(notes))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(editor))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(editorAlt))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd(home .. "/.local/bin/toggle-floating"))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + H", hl.dsp.exec_cmd(home .. "/.local/bin/spotlight-menu --manage"))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd(home .. "/.local/bin/toggle-theme"))
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Move window position with mainMod + SHIFT + arrow keys
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9] & Move active window to workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Move/resize windows with mainMod + Z/X
hl.bind(mainMod .. " + Z", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + X", hl.dsp.window.resize(), { mouse = true })

-- Resize windows with mainMod + CTRL + arrow keys
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 30,  y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.resize({ x = -30, y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.resize({ x = 0,   y = -30, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.resize({ x = 0,   y = 30,  relative = true }), { repeating = true })

-- Clipboard, Colour Picker, Screen Locking, Waybar
hl.bind("SUPER + V",     hl.dsp.exec_cmd(home .. "/.local/bin/clipboard-menu"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(colorPicker .. " | wl-copy"))
hl.bind("SUPER + L",     hl.dsp.exec_cmd("hyprlock"))
hl.bind("CTRL + Escape", hl.dsp.exec_cmd("killall waybar || " .. home .. "/.local/bin/waybar"))

-- Windows-Style Snipping Tool & Screenshot Overlay
hl.bind("Print",               hl.dsp.exec_cmd(home .. "/.local/bin/screenshot-menu"))
hl.bind("SUPER + SHIFT + S",   hl.dsp.exec_cmd(home .. "/.local/bin/screenshot-menu"))
hl.bind("SUPER + Print",       hl.dsp.exec_cmd("grimblast --notify copysave active"))
hl.bind("SUPER + ALT + Print", hl.dsp.exec_cmd("grimblast --notify copysave area"))

-- Volume and Media Control
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"),                  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"),                  { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("pamixer --default-source -m"),   { locked = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("pamixer -t"),                    { locked = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"),          { locked = true })
hl.bind("XF86AudioPause",       hl.dsp.exec_cmd("playerctl play-pause"),          { locked = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"),                { locked = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"),            { locked = true })

-- Screen brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(home .. "/.local/bin/change-brightness up"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(home .. "/.local/bin/change-brightness down"), { locked = true, repeating = true })

-- Power button
hl.bind("XF86PowerOff", hl.dsp.exec_cmd(home .. "/.local/bin/power-session"), { locked = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
    name   = "div-acer-manager",
    match  = { class = "^(DivAcerManagerMax)$" },
    float  = true,
    center = true,
})

local floatClasses = {
    "^(jome)$",
    "^(kvantummanager)$",
    "^(qt5ct)$",
    "^(qt6ct)$",
    "^(nwg-look)$",
    "^(org.kde.ark)$",
    "^(pavucontrol)$",
    "^(blueman-manager)$",
    "^(nm-applet)$",
    "^(nm-connection-editor)$",
    "^(org.kde.polkit-kde-authentication-agent-1)$",
}

for idx, cls in ipairs(floatClasses) do
    hl.window_rule({
        name  = "float-app-" .. idx,
        match = { class = cls },
        float = true,
    })
end

-- Waybar Applets Geometry & Placement
hl.window_rule({
    name  = "applet-calendar",
    match = { class = "^(calendar-app|org.antigravity.calendarapp)$" },
    float = true,
    size  = "304 449",
    move  = "6 44",
})

hl.window_rule({
    name  = "applet-media",
    match = { class = "^(media-player|org.antigravity.mediaplayer)$" },
    float = true,
    size  = "291 375",
    move  = "202 44",
})

hl.window_rule({
    name  = "applet-wifi",
    match = { class = "^(wifi-manager|org.antigravity.wifimanager)$" },
    float = true,
    size  = "437 440",
    move  = "755 44",
})

hl.window_rule({
    name  = "applet-bluetooth",
    match = { class = "^(bluetooth-manager|org.antigravity.bluetoothmanager)$" },
    float = true,
    size  = "429 440",
    move  = "877 44",
})

hl.window_rule({
    name  = "applet-power-menu",
    match = { class = "^(power-menu|org.antigravity.powermenu)$" },
    float = true,
    size  = "340 460",
    move  = "1030 44",
})

hl.window_rule({
    name  = "applet-task-manager",
    match = { class = "^(task-manager|org.antigravity.taskmanager)$" },
    float = true,
    size  = "428 441",
    move  = "1076 44",
})

hl.window_rule({
    name  = "applet-audio-mixer",
    match = { class = "^(audio-mixer|org.antigravity.audiomixer)$" },
    float = true,
    size  = "382 410",
    move  = "1144 44",
})

hl.window_rule({
    name  = "applet-power-session",
    match = { class = "^(power-session|org.antigravity.powersession)$" },
    float = true,
    size  = "280 88",
    move  = "1246 44",
})

-- Antigravity IDE Default Floating Geometry
hl.window_rule({
    name   = "antigravity-ide-geom",
    match  = { class = "^(antigravity-ide)$" },
    size   = "76% 78%",
    center = true,
})

-- macOS Popover Consistency for all Waybar Applets
hl.window_rule({
    name        = "waybar-applets-style",
    match       = { class = "^(calendar-app|media-player|wifi-manager|bluetooth-manager|task-manager|power-menu|audio-mixer|power-session)$" },
    border_size = 0,
    rounding    = 12,
    opacity     = "0.94 0.90",
})

-- Opacity rules
local opacityRules = {
    { class = "^(Thorium-browser)$", opacity = "0.90 0.90" },
    { class = "^(Code)$", opacity = "0.80 0.80" },
    { class = "^(Arduino IDE)$", opacity = "0.80 0.80" },
    { class = "^(dev.warp.Warp)$", opacity = "0.80 0.80" },
    { class = "^(obsidian)$", opacity = "0.80 0.80" },
    { class = "^(code-url-handler)$", opacity = "0.80 0.80" },
    { class = "^(code-insiders-url-handler)$", opacity = "0.80 0.80" },
    { class = "^(kitty)$", opacity = "0.85 0.85" },
    { class = "^(org.gnome.Nautilus)$", opacity = "0.80 0.80" },
    { class = "^(org.kde.dolphin)$", opacity = "0.92 0.88" },
    { class = "^(org.kde.ark)$", opacity = "0.80 0.80" },
    { class = "^(nwg-look)$", opacity = "0.80 0.80" },
    { class = "^(qt5ct)$", opacity = "0.80 0.80" },
    { class = "^(qt6ct)$", opacity = "0.80 0.80" },
    { class = "^(kvantummanager)$", opacity = "0.80 0.80" },
    { class = "^(pavucontrol)$", opacity = "0.80 0.70" },
    { class = "^(blueman-manager)$", opacity = "0.80 0.70" },
    { class = "^(nm-applet)$", opacity = "0.80 0.70" },
    { class = "^(Spotify)$", opacity = "0.70 0.70" },
    { class = "^(nm-connection-editor)$", opacity = "0.80 0.70" },
    { class = "^(org.kde.polkit-kde-authentication-agent-1)$", opacity = "0.80 0.70" },
    { class = "^(polkit-gnome-authentication-agent-1)$", opacity = "0.80 0.70" },
    { class = "^(org.freedesktop.impl.portal.desktop.gtk)$", opacity = "0.80 0.70" },
    { class = "^(org.freedesktop.impl.portal.desktop.hyprland)$", opacity = "0.80 0.70" },
}

for idx, rule in ipairs(opacityRules) do
    hl.window_rule({
        name    = "opacity-rule-" .. idx,
        match   = { class = rule.class },
        opacity = rule.opacity,
    })
end

hl.window_rule({
    name    = "opacity-spotify-free",
    match   = { initial_title = "^(Spotify Free)$" },
    opacity = "0.70 0.70",
})

---------------------
---- LAYER RULES ----
---------------------

hl.layer_rule({
    name         = "layer-waybar",
    match        = { namespace = "waybar" },
    blur         = true,
    ignore_alpha = 0.5,
})

hl.layer_rule({
    name  = "layer-dunst",
    match = { namespace = "dunst" },
    blur  = true,
})

hl.layer_rule({
    name         = "layer-mako",
    match        = { namespace = "mako" },
    blur         = true,
    ignore_alpha = 0.2,
})

hl.layer_rule({
    name         = "layer-notifications",
    match        = { namespace = "notifications" },
    blur         = true,
    ignore_alpha = 0.2,
})

hl.layer_rule({
    name         = "layer-rofi",
    match        = { namespace = "rofi" },
    blur         = true,
    ignore_alpha = 0,
    animation    = "slide",
})

hl.layer_rule({
    name         = "layer-tofi",
    match        = { namespace = "tofi" },
    ignore_alpha = 0,
})
