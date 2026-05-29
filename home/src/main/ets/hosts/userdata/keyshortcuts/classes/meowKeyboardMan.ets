import { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import { getMySettings } from "../../../../components/settings";
import { keyShortcutsString } from "../settings";
import { meowKeyBind } from "./meowKeyBind";

@ObservedV2
export class meowKeyboardMan {
  @Trace newTab: meowKeyBind = new meowKeyBind('t', [ModifierKey.CTRL]);
  @Trace closeTab: meowKeyBind = new meowKeyBind('w', [ModifierKey.CTRL]);
  @Trace showTabs: meowKeyBind = new meowKeyBind('a', [ModifierKey.CTRL, ModifierKey.SHIFT]);
  @Trace focusAddress: meowKeyBind = new meowKeyBind('d', [ModifierKey.ALT]);
  @Trace searchInPage: meowKeyBind = new meowKeyBind('f', [ModifierKey.CTRL]);
  @Trace fullscreen: meowKeyBind = new meowKeyBind(FunctionKey.F11, []);
  @Trace history: meowKeyBind = new meowKeyBind('h', [ModifierKey.CTRL]);
  @Trace refresh: meowKeyBind = new meowKeyBind(FunctionKey.F5, []);
  @Trace print: meowKeyBind = new meowKeyBind('p', [ModifierKey.CTRL]);
  @Trace newWindow: meowKeyBind = new meowKeyBind('n', [ModifierKey.CTRL]);
  @Trace pin: meowKeyBind = new meowKeyBind('p', [ModifierKey.ALT]);
  @Trace save: meowKeyBind = new meowKeyBind('s', [ModifierKey.CTRL]);
  @Trace zones: meowKeyBind = new meowKeyBind('z', [ModifierKey.ALT]);
  @Trace fullscreenWindowed: meowKeyBind = new meowKeyBind(FunctionKey.F11, [ModifierKey.SHIFT]);
  @Trace esc: meowKeyBind = new meowKeyBind(FunctionKey.ESC, []);
  @Trace sidebar: meowKeyBind = new meowKeyBind('z', [ModifierKey.CTRL, ModifierKey.SHIFT]);

  // Put them all in one place
  @Trace shortcuts: meowKeyBind[] = [
    this.newTab, this.closeTab, this.showTabs, this.focusAddress, this.searchInPage,
    this.fullscreen, this.history, this.refresh, this.print, this.newWindow,
    this.pin, this.save, this.zones, this.fullscreenWindowed, this.esc,
    this.sidebar
  ];
  @Trace shortcutsStrings: ResourceStr[] = [
    $r('app.string.KeyShortcuts_newTab'),
    $r('app.string.KeyShortcuts_closeTab'),
    $r('app.string.KeyShortcuts_showTabs'),
    $r('app.string.KeyShortcuts_focusAddress'),
    $r('app.string.KeyShortcuts_searchInPage'),
    $r('app.string.KeyShortcuts_fullscreen'),
    $r('app.string.KeyShortcuts_history'),
    $r('app.string.KeyShortcuts_refresh'),
    $r('app.string.KeyShortcuts_print'),
    $r('app.string.KeyShortcuts_newWindow'),
    $r('app.string.KeyShortcuts_pin'),
    $r('app.string.KeyShortcuts_save'),
    $r('app.string.KeyShortcuts_zones'),
    $r('app.string.KeyShortcuts_fullscreenWindowed'),
    $r('app.string.KeyShortcuts_esc'),
    $r('app.string.KeyShortcuts_showSidebar'),
  ];

  /**
   * Load from settings.
   */
  initFromSettings() {
    const settingsStrings = keyShortcutsString();
    if (!settingsStrings) {
      meow(`No settings found for key shortcuts.`, 'meowKeyboardMan][initFromSettings', meowLevel.WARN);
      return;
    }

    // Process each shortcut.
    for (let i = 0; i < settingsStrings.length; i++) {
      const settingsString = settingsStrings[i].split(' ');
      this.shortcuts[i].fromArray(settingsString);
      meow(`#${i}: ${settingsString} => ${this.shortcuts[i]}`, 'meowKeyboardMan][initFromSettings', meowLevel.INFO);
    }
  }

  /**
   * Save to settings.
   */
  private saveToSettings() {
    const mySettings = getMySettings();
    const newSettingsStrings = this.shortcuts.map(shortcut => shortcut.toArray().join(' '));
    mySettings.setByIndex(29, newSettingsStrings);
    mySettings.requestSaveToDisk();
  }

  /**
   * Apply the key bindings.
   * Note that this function really does its job 100 ms after calling it,
   * as it needs some time to flush (unbind) the existing component key shortcuts.
   */
  apply(index: number, fromStrings: string[]) {
    if (fromStrings.length == 0) {
      meow(`fromStrings is empty. meowKeyboardMan.apply() REJECTED!`, 'meowKeyboardMan][apply', meowLevel.WARN);
      return;
    }

    this.shortcuts[index].fromArray([]); // Unbind existing key binds
    setTimeout(() => {
      this.shortcuts[index].fromArray(fromStrings);
      this.saveToSettings();
    }, 100);
  }
}
