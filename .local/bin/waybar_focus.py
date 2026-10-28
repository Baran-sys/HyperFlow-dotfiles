#!/usr/bin/env python3
"""
Waybar Smart Focus & Dynamic Theming Helper (Ultra-Optimized)
1. Lightning-fast single-instance toggle via lightweight PID lockfiles in /tmp/waybar_applets/ (<0.1ms).
2. Non-blocking focus locking (hyprctl keyword input:follow_mouse 2 / 1).
3. In-memory memoized Catppuccin Latte CSS theming.
"""
import os
import sys
import time
import atexit
import signal
import subprocess

LOCK_DIR = "/tmp/waybar_applets"
try:
    os.makedirs(LOCK_DIR, exist_ok=True)
except Exception:
    pass

_THEME_CSS_CACHE = {}
_CURRENT_APP_NAME = None

def record_closed(app_name):
    if not app_name:
        return
    try:
        closed_file = os.path.join(LOCK_DIR, f"{app_name}.closed")
        with open(closed_file, "w") as f:
            f.write(str(time.time()))
    except Exception:
        pass

def fast_toggle_or_lock(app_name):
    """
    Lightning-fast toggle & mutual exclusion check:
    1. If this app was closed within the last 450ms (e.g. by clicking Waybar widget while open),
       exit immediately so it does NOT close and reopen.
    2. If this app is already running, send SIGTERM, record closed timestamp, and exit immediately (<0.1ms).
    3. If any other Waybar applet is open, terminate it so only one applet is open at a time.
    4. Register current PID and return.
    """
    global _CURRENT_APP_NAME
    _CURRENT_APP_NAME = app_name
    my_pid = os.getpid()
    lock_file = os.path.join(LOCK_DIR, f"{app_name}.pid")
    closed_file = os.path.join(LOCK_DIR, f"{app_name}.closed")

    # If the app was closed within the last 450ms, this launch was triggered by the same
    # Waybar click that dismissed the open applet. Exit immediately!
    if os.path.exists(closed_file):
        try:
            with open(closed_file, "r") as f:
                content = f.read().strip()
            if content:
                closed_time = float(content)
                if (time.time() - closed_time) < 0.45:
                    try:
                        os.remove(closed_file)
                    except Exception:
                        pass
                    release_focus_lock(my_pid)
                    sys.exit(0)
        except Exception:
            pass

    # Clean up any lingering Hyprland mouse binds
    try:
        subprocess.Popen(["hyprctl", "keyword", "unbind", ",mouse:272"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        subprocess.Popen(["hyprctl", "keyword", "unbind", ",mouse:273"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        pass

    if os.path.exists(lock_file):
        try:
            with open(lock_file, "r") as f:
                content = f.read().strip()
                if content:
                    old_pid = int(content)
                    if old_pid != my_pid:
                        try:
                            # Test if process exists
                            os.kill(old_pid, 0)
                            # If alive, toggle off: terminate it and exit immediately!
                            os.kill(old_pid, signal.SIGTERM)
                            record_closed(app_name)
                            try:
                                os.remove(lock_file)
                            except Exception:
                                pass
                            release_focus_lock(my_pid)
                            sys.exit(0)
                        except ProcessLookupError:
                            # Process is dead, stale lockfile
                            pass
        except Exception:
            pass

    # Write our own PID first so other applets know we are running
    try:
        with open(lock_file, "w") as f:
            f.write(str(my_pid))
    except Exception:
        pass

    # Acquire focus lock (input:follow_mouse 0) immediately
    acquire_focus_lock(my_pid)

    # Close any OTHER running Waybar applets so only one applet is open at a time
    try:
        if os.path.exists(LOCK_DIR):
            for fname in os.listdir(LOCK_DIR):
                if fname.endswith(".pid") and fname != f"{app_name}.pid":
                    other_lock = os.path.join(LOCK_DIR, fname)
                    try:
                        with open(other_lock, "r") as f:
                            other_pid_str = f.read().strip()
                        if other_pid_str:
                            other_pid = int(other_pid_str)
                            if other_pid != my_pid:
                                try:
                                    os.kill(other_pid, signal.SIGTERM)
                                except ProcessLookupError:
                                    pass
                        os.remove(other_lock)
                    except Exception:
                        pass
    except Exception:
        pass

    # Clean up lockfile on exit
    def _remove_lock():
        record_closed(app_name)
        try:
            if os.path.exists(lock_file):
                with open(lock_file, "r") as f:
                    if f.read().strip() == str(my_pid):
                        os.remove(lock_file)
        except Exception:
            pass
        release_focus_lock(my_pid)

    atexit.register(_remove_lock)

def is_any_other_applet_running(my_pid=None):
    if my_pid is None:
        my_pid = os.getpid()
    try:
        if os.path.exists(LOCK_DIR):
            for fname in os.listdir(LOCK_DIR):
                if fname.endswith(".pid"):
                    fpath = os.path.join(LOCK_DIR, fname)
                    try:
                        with open(fpath, "r") as f:
                            pid = int(f.read().strip())
                            if pid != my_pid:
                                try:
                                    os.kill(pid, 0)
                                    return True
                                except ProcessLookupError:
                                    try:
                                        os.remove(fpath)
                                    except Exception:
                                        pass
                    except Exception:
                        pass
    except Exception:
        pass
    return False

def acquire_focus_lock(my_pid=None):
    if my_pid is None:
        my_pid = os.getpid()
    try:
        subprocess.Popen(["hyprctl", "keyword", "input:follow_mouse", "0"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if my_pid:
            subprocess.Popen(["hyprctl", "dispatch", "focuswindow", f"pid:{my_pid}"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        pass

def release_focus_lock(my_pid=None):
    if my_pid is None:
        my_pid = os.getpid()
    if not is_any_other_applet_running(my_pid):
        try:
            subprocess.Popen(["hyprctl", "keyword", "input:follow_mouse", "1"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except Exception:
            pass

class SmartFocus:
    @classmethod
    def position_applet(cls, window, default_w, default_h, align="right", offset=12, top_margin=46):
        """
        Universal monitor-aware positioning helper:
        Computes the target x, y for the currently focused monitor.
        Also dispatches movewindowpixel if needed to guarantee exact placement.
        """
        try:
            import json
            res = subprocess.check_output(["hyprctl", "monitors", "-j"], timeout=0.3).decode()
            monitors = json.loads(res)
            if monitors:
                mon = next((m for m in monitors if m.get("focused")), monitors[0])
                scale = float(mon.get("scale", 1.0)) or 1.0
                eff_w = int(round(float(mon.get("width", 1920)) / scale))
                if align == "left":
                    x = max(8, int(offset))
                elif align == "center":
                    x = max(8, (eff_w - default_w) // 2 + int(offset))
                else:
                    x = max(8, eff_w - default_w - int(offset))
                y = int(top_margin)
                window._applet_x = x
                window._applet_y = y
                window._applet_w = default_w
                window._applet_h = default_h
                subprocess.Popen(
                    ["hyprctl", "dispatch", "movewindowpixel", f"exact {x} {y},pid:{os.getpid()}"],
                    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
                )
                return x, y
        except Exception:
            pass
        return None, None

    @classmethod
    def setup(cls, window, align=None, offset=12):
        cleaned_up = [False]
        my_pid = os.getpid()

        acquire_focus_lock(my_pid)

        # Calculate coordinates dynamically if align is specified
        if align is not None:
            w, h = window.get_size()
            cls.position_applet(window, w or 380, h or 440, align=align, offset=offset)

        def _cleanup(*args):
            if not cleaned_up[0]:
                cleaned_up[0] = True
                record_closed(_CURRENT_APP_NAME)
                try:
                    subprocess.Popen(["hyprctl", "keyword", "unbind", ",mouse:272"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                    subprocess.Popen(["hyprctl", "keyword", "unbind", ",mouse:273"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                except Exception:
                    pass
                release_focus_lock(my_pid)

        window.connect("destroy", _cleanup)
        atexit.register(_cleanup)

        # Handle SIGTERM & SIGINT
        try:
            orig_sigterm = signal.getsignal(signal.SIGTERM)
            def _on_signal(signum, frame):
                _cleanup()
                if signum == signal.SIGTERM and callable(orig_sigterm):
                    orig_sigterm(signum, frame)
                else:
                    sys.exit(0)
            signal.signal(signal.SIGTERM, _on_signal)
            signal.signal(signal.SIGINT, _on_signal)
        except Exception:
            pass

        # Handle Outside Clicks:
        # Non-consuming Hyprland binds send SIGUSR1 to our process on mouse click anywhere.
        def _on_mouse_click(signum, frame):
            if cleaned_up[0]:
                return
            if not getattr(window, "ready_to_close", False):
                return
            if getattr(window, "is_showing_dialog", False):
                return
            try:
                pos_raw = subprocess.check_output(["hyprctl", "cursorpos"], timeout=0.15).decode().strip()
                parts = [int(p.strip()) for p in pos_raw.split(",")]
                cx, cy = parts[0], parts[1]

                wx = getattr(window, "_applet_x", None)
                wy = getattr(window, "_applet_y", 46)
                ww = getattr(window, "_applet_w", None)
                wh = getattr(window, "_applet_h", None)

                if wx is None or ww is None:
                    cur_w, cur_h = window.get_size()
                    ww = ww or cur_w or 380
                    wh = wh or cur_h or 440
                    import json
                    res = subprocess.check_output(["hyprctl", "clients", "-j"], timeout=0.15).decode()
                    clients = json.loads(res)
                    for c in clients:
                        if c.get("pid") == my_pid:
                            wx, wy = c.get("at", [wx, wy])
                            ww, wh = c.get("size", [ww, wh])
                            window._applet_x = wx
                            window._applet_y = wy
                            window._applet_w = ww
                            window._applet_h = wh
                            break

                if wx is not None and wy is not None and ww is not None and wh is not None:
                    if (wx - 4) <= cx <= (wx + ww + 4) and (wy - 4) <= cy <= (wy + wh + 4):
                        # Click was inside applet bounds
                        return

                # Click was OUTSIDE applet bounds: dismiss!
                record_closed(_CURRENT_APP_NAME)
                from gi.repository import GLib
                GLib.idle_add(window.close)
            except Exception:
                pass

        try:
            signal.signal(signal.SIGUSR1, _on_mouse_click)
        except Exception:
            pass

        # Bind non-consuming mouse clicks in Hyprland after window is ready
        def _init_mouse_binds():
            if cleaned_up[0]:
                return False
            window.ready_to_close = True
            try:
                subprocess.Popen(["hyprctl", "keyword", "bindn", f",mouse:272,exec,kill -USR1 {my_pid}"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                subprocess.Popen(["hyprctl", "keyword", "bindn", f",mouse:273,exec,kill -USR1 {my_pid}"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                subprocess.Popen(["hyprctl", "dispatch", "focuswindow", f"pid:{my_pid}"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            except Exception:
                pass
            return False

        try:
            from gi.repository import GLib
            GLib.timeout_add(150, _init_mouse_binds)
        except Exception:
            pass

    @classmethod
    def is_light_theme(cls):
        try:
            mode_file = os.path.expanduser("~/.config/theme-mode")
            if os.path.exists(mode_file):
                with open(mode_file, "r") as f:
                    return f.read().strip() == "light"
        except Exception:
            pass
        return False

    @classmethod
    def get_themed_css(cls, css_data):
        is_light = cls.is_light_theme()
        if not is_light:
            return css_data if isinstance(css_data, bytes) else css_data.encode('utf-8')

        cache_key = id(css_data)
        if cache_key in _THEME_CSS_CACHE:
            return _THEME_CSS_CACHE[cache_key]

        text = css_data.decode('utf-8') if isinstance(css_data, bytes) else css_data

        mapping = [
            ('#1e1e2e', '#eff1f5'),  # base
            ('#181825', '#e6e9ef'),  # mantle
            ('#11111b', '#dce0e8'),  # crust
            ('#252538', '#e6e9ef'),  # card / header bg
            ('#313244', '#ccd0da'),  # surface0
            ('#3b3d57', '#bcc0cc'),  # surface0 active
            ('#45475a', '#bcc0cc'),  # surface1
            ('#585b70', '#acb0be'),  # surface2
            ('#6c7086', '#8c8fa1'),  # overlay0
            ('#cdd6f4', '#4c4f69'),  # text
            ('#a6adc8', '#5c5f77'),  # subtext0
            ('#89b4fa', '#1e66f5'),  # blue / accent
            ('#b4befe', '#7287fd'),  # lavender
            ('#74c7ec', '#209fb5'),  # sapphire
            ('#cba6f7', '#8839ef'),  # mauve
            ('#f5c2e7', '#ea76cb'),  # pink
            ('#eba0ac', '#e64553'),  # maroon
            ('#f38ba8', '#d20f39'),  # red
            ('#a6e3a1', '#40a02b'),  # green
            ('#f9e2af', '#df8e1d'),  # yellow
            ('#ffffff', '#4c4f69'),  # text in buttons
            ('rgba(255, 255, 255, 0.04)', 'rgba(0, 0, 0, 0.04)'),
            ('rgba(255, 255, 255, 0.07)', 'rgba(0, 0, 0, 0.06)'),
            ('rgba(255, 255, 255, 0.08)', 'rgba(0, 0, 0, 0.07)'),
            ('rgba(255, 255, 255, 0.1)',  'rgba(0, 0, 0, 0.08)'),
            ('rgba(255, 255, 255, 0.12)', 'rgba(0, 0, 0, 0.10)'),
            ('rgba(255, 255, 255, 0.15)', 'rgba(0, 0, 0, 0.12)'),
            ('rgba(255, 255, 255, 0.18)', 'rgba(0, 0, 0, 0.14)'),
            ('rgba(255, 255, 255, 0.2)',  'rgba(0, 0, 0, 0.16)'),
            ('rgba(255, 255, 255, 0.3)',  'rgba(0, 0, 0, 0.22)'),
            ('rgba(203, 166, 247,', 'rgba(136, 57, 239,'),
            ('rgba(137, 180, 250,', 'rgba(30, 102, 245,'),
            ('rgba(166, 227, 161,', 'rgba(64, 160, 43,'),
            ('rgba(249, 226, 175,', 'rgba(223, 142, 29,'),
        ]
        for src, dst in mapping:
            text = text.replace(src, dst)
        res = text.encode('utf-8')
        _THEME_CSS_CACHE[cache_key] = res
        return res
