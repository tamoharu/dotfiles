import Gio from 'gi://Gio';
import Shell from 'gi://Shell';

import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

const FORWARD_KEY = 'switch-group';
const BACKWARD_KEY = 'switch-group-backward';
const SUPER_FORWARD = '<Super>Above_Tab';
const SUPER_BACKWARD = '<Shift><Super>Above_Tab';

function withBinding(bindings, binding) {
    return bindings.includes(binding) ? [...bindings] : [...bindings, binding];
}

function withoutBinding(bindings, binding) {
    return bindings.filter(value => value !== binding);
}

function arraysEqual(left, right) {
    return left.length === right.length &&
        left.every((value, index) => value === right[index]);
}

export default class GhosttyHerdrShortcutExtension extends Extension {
    enable() {
        this._settings = new Gio.Settings({
            schema_id: 'org.gnome.desktop.wm.keybindings',
        });
        this._windowTracker = Shell.WindowTracker.get_default();

        // Re-add the normal GNOME bindings on startup. This also repairs a
        // stale Ghostty-only state after an unclean Shell shutdown.
        this._normalForward = withBinding(
            this._settings.get_strv(FORWARD_KEY), SUPER_FORWARD);
        this._normalBackward = withBinding(
            this._settings.get_strv(BACKWARD_KEY), SUPER_BACKWARD);

        this._focusChangedId = global.display.connect(
            'notify::focus-window', () => this._syncBindings());
        this._syncBindings();
    }

    disable() {
        if (this._focusChangedId) {
            global.display.disconnect(this._focusChangedId);
            this._focusChangedId = 0;
        }

        this._setIfChanged(FORWARD_KEY, this._normalForward);
        this._setIfChanged(BACKWARD_KEY, this._normalBackward);

        this._normalForward = null;
        this._normalBackward = null;
        this._windowTracker = null;
        this._settings = null;
    }

    _isGhosttyFocused() {
        const window = global.display.focus_window;
        if (!window)
            return false;

        const appId = this._windowTracker.get_window_app(window)?.get_id() ?? '';
        const gtkApplicationId = window.get_gtk_application_id?.() ?? '';
        const wmClass = window.get_wm_class?.() ?? '';
        const wmClassInstance = window.get_wm_class_instance?.() ?? '';

        return [appId, gtkApplicationId, wmClass, wmClassInstance]
            .some(value => value.toLowerCase().includes('ghostty'));
    }

    _syncBindings() {
        const ghosttyFocused = this._isGhosttyFocused();
        const forward = ghosttyFocused
            ? withoutBinding(this._normalForward, SUPER_FORWARD)
            : this._normalForward;
        const backward = ghosttyFocused
            ? withoutBinding(this._normalBackward, SUPER_BACKWARD)
            : this._normalBackward;

        this._setIfChanged(FORWARD_KEY, forward);
        this._setIfChanged(BACKWARD_KEY, backward);
    }

    _setIfChanged(key, bindings) {
        if (!this._settings || !bindings)
            return;

        const current = this._settings.get_strv(key);
        if (!arraysEqual(current, bindings))
            this._settings.set_strv(key, bindings);
    }
}
