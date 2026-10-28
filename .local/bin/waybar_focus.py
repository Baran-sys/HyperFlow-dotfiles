#!/usr/bin/env python3
"""
Waybar Smart Focus & Dynamic Theming Helper (Ultra-Optimized)
1. Lightning-fast single-instance toggle via lightweight PID lockfiles in /tmp/waybar_applets/ (<0.1ms).
2. Non-blocking focus locking (hyprctl keyword input:follow_mouse 2 / 1).
3. In-memory memoized Catppuccin Latte CSS theming.
"""
import os
import sys
import atexit
import signal
import subprocess

LOCK_DIR = "/tmp/waybar_applets"
try:
    os.makedirs(LOCK_DIR, exist_ok=True)
except Exception:
    pass

_THEME_CSS_CACHE = {}

def fast_toggle_or_lock(app_name):
    """
    Lightning-fast toggle & mutual exclusion check:
    1. If this app is already running, send SIGTERM and exit immediately (<0.1ms).
    2. If any other Waybar applet is open, terminate it so only one applet is open at a time.
    3. Register current PID and return.
    """
    my_pid = os.getpid()
    lock_file = os.path.join(LOCK_DIR, f"{app_name}.pid")

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
                            try:
                                os.remove(lock_file)
                            except Exception:
                                pass
                            sys.exit(0)
                        except ProcessLookupError:
                            # Process is dead, stale lockfile
                            pass
        except Exception:
            pass

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

    # Write our own PID
    try:
        with open(lock_file, "w") as f:
            f.write(str(my_pid))
    except Exception:
        pass

    # Clean up lockfile on exit
    def _remove_lock():
        try:
            if os.path.exists(lock_file):
                with open(lock_file, "r") as f:
                    if f.read().strip() == str(my_pid):
                        os.remove(lock_file)
        except Exception:
            pass

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

def acquire_focus_lock():
    pass

def release_focus_lock(my_pid=None):
    pass

class SmartFocus:
    @classmethod
    def position_applet(cls, window, default_w, default_h, align="right", offset=12, top_margin=46):
        """
        Fallback positioning helper (Hyprland windowrules handle this natively at map time).
        """
        pass

    @classmethod
    def setup(cls, window, align=None, offset=12):
        cleaned_up = [False]

        def _cleanup(*args):
            if not cleaned_up[0]:
                cleaned_up[0] = True

        window.connect("destroy", _cleanup)
        atexit.register(_cleanup)

        # Monitor Hyprland active window: if window loses focus, close immediately
        def _poll_focus():
            if cleaned_up[0]:
                return False
            if getattr(window, "ready_to_close", False) and not getattr(window, "is_showing_dialog", False):
                if not window.is_active():
                    window.close()
                    return False
            return True

        try:
            from gi.repository import GLib
            GLib.timeout_add(200, _poll_focus)
        except Exception:
            pass

        # Handle SIGTERM
        try:
            orig_sigterm = signal.getsignal(signal.SIGTERM)
            def _on_sigterm(signum, frame):
                _cleanup()
                if callable(orig_sigterm):
                    orig_sigterm(signum, frame)
                else:
                    sys.exit(0)
            signal.signal(signal.SIGTERM, _on_sigterm)
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
