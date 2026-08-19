#!/usr/bin/env bash
set -euo pipefail

EXTENSION_UUID="ghostty-herdr-shortcut@local"
CUSTOM_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/caps-close-search/"
COMMAND_PATH="$HOME/.local/bin/close-gnome-search"

command -v gsettings >/dev/null 2>&1 || {
  echo "gsettings is required." >&2
  exit 1
}

# Preserve unrelated shortcuts, custom keybindings, and enabled extensions.
# Only remove bindings that consume Super combinations assigned by this
# profile, then add the profile's required values. Input sources are the one
# intentional replacement: Mozc must stay active for the Alt selectors.
python3 - "$CUSTOM_PATH" "$EXTENSION_UUID" "$COMMAND_PATH" <<'PY'
import sys

import gi

gi.require_version("Gio", "2.0")
from gi.repository import Gio, GLib

custom_path, extension_uuid, command_path = sys.argv[1:]


def settings(schema):
    return Gio.Settings.new(schema)


def update_strv(setting, key, *, remove=(), add=(), remove_if=None):
    values = list(setting.get_strv(key))
    values = [
        value for value in values
        if value not in remove and not (remove_if and remove_if(value))
    ]
    for value in add:
        if value not in values:
            values.append(value)
    if setting.is_writable(key):
        setting.set_strv(key, values)
    else:
        print(f"    warning: setting is locked: {setting.props.schema_id} {key}")


wm = settings("org.gnome.desktop.wm.keybindings")
shell_keys = settings("org.gnome.shell.keybindings")
mutter = settings("org.gnome.mutter")
mutter_keys = settings("org.gnome.mutter.keybindings")
media_keys = settings("org.gnome.settings-daemon.plugins.media-keys")

# Start/Windows is the macOS-style Command key. Remove GNOME actions that
# collide with explicit Ghostty bindings, while retaining every other binding.
if mutter.is_writable("overlay-key"):
    mutter.set_string("overlay-key", "")
update_strv(wm, "minimize", remove=("<Super>h",))
update_strv(wm, "show-desktop", remove=("<Super>d",))
update_strv(shell_keys, "toggle-application-view", remove=("<Super>a",))
update_strv(shell_keys, "toggle-message-tray", remove=("<Super>v",))
update_strv(shell_keys, "toggle-quick-settings", remove=("<Super>s",))
update_strv(mutter_keys, "switch-monitor", remove=("<Super>p",))
update_strv(
    media_keys,
    "screensaver",
    remove=("<Super>l",),
    add=("<Control><Super>l",),
)

for number in range(1, 10):
    update_strv(
        shell_keys,
        f"switch-to-application-{number}",
        remove=(f"<Super>{number}",),
    )

schema_source = Gio.SettingsSchemaSource.get_default()
dock_schema = schema_source.lookup(
    "org.gnome.shell.extensions.dash-to-dock", True)
if dock_schema is not None:
    dock = settings("org.gnome.shell.extensions.dash-to-dock")
    if dock.is_writable("hot-keys"):
        dock.set_boolean("hot-keys", False)

# Start+Tab switches applications. Start+Above_Tab switches windows belonging
# to one application, except while Ghostty is focused (the extension releases
# that shortcut to Ghostty for Herdr Space navigation).
update_strv(wm, "switch-applications", add=("<Super>Tab",))
update_strv(
    wm,
    "switch-applications-backward",
    add=("<Shift><Super>Tab",),
)
update_strv(wm, "switch-group", add=("<Super>Above_Tab",))
update_strv(
    wm,
    "switch-group-backward",
    add=("<Shift><Super>Above_Tab",),
)

# Keep Mozc active as the only GNOME input source. Muhenkan/Henkan are Mozc
# commands, so retaining an active xkb source would make the Alt selectors
# stop working whenever GNOME switched to that source.
input_sources = settings("org.gnome.desktop.input-sources")
mozc = ("ibus", "mozc-jp")
if input_sources.is_writable("sources"):
    input_sources.set_value("sources", GLib.Variant("a(ss)", [mozc]))

update_strv(wm, "switch-input-source", remove=("<Super>space",))
update_strv(
    wm,
    "switch-input-source-backward",
    remove=("<Shift><Super>space",),
)

ibus = settings("org.freedesktop.ibus.general")
if ibus.is_writable("use-xmodmap"):
    ibus.set_boolean("use-xmodmap", False)
if ibus.is_writable("use-global-engine"):
    ibus.set_boolean("use-global-engine", True)

ibus_hotkey = settings("org.freedesktop.ibus.general.hotkey")
update_strv(
    ibus_hotkey,
    "triggers",
    remove_if=lambda value: "Alt_L" in value or "Alt_R" in value,
    add=("<Super>space",),
)

# Linux KEY_SEARCH is XF86Search in Ubuntu's XKB map.
update_strv(media_keys, "search-static", add=("XF86Search",))

# CapsLock tap emits KEY_F14, which Ubuntu names XF86Launch5. The custom
# shortcut only hides Overview; it is a no-op on the normal desktop.
custom_binding = Gio.Settings.new_with_path(
    "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding",
    custom_path,
)
custom_binding.set_string("name", "Close GNOME search with CapsLock")
custom_binding.set_string("command", command_path)
custom_binding.set_string("binding", "XF86Launch5")

custom = list(media_keys.get_strv("custom-keybindings"))
if custom_path not in custom:
    custom.append(custom_path)
    media_keys.set_strv("custom-keybindings", custom)

shell = Gio.Settings.new("org.gnome.shell")
enabled = list(shell.get_strv("enabled-extensions"))
if extension_uuid not in enabled:
    enabled.append(extension_uuid)
    shell.set_strv("enabled-extensions", enabled)
PY

echo "    GNOME/IBus settings applied"
