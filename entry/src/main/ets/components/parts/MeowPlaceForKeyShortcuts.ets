import { meowKeyboardMan } from '../../hosts/userdata/keyshortcuts/classes/meowKeyboardMan';
import { AppStorageV2 } from '@kit.ArkUI';
import { meow, meowLevel } from '../../catstypicalframework/utils/catsLogger';

@ComponentV2
struct MeowPlaceForKeyShortcuts {
  @Local myKey: meowKeyboardMan = AppStorageV2.connect(meowKeyboardMan)!;

  build() {
    Row() {
      Blank().keyboardShortcut(this.myKey.newTab.value, this.myKey.newTab.keys, () => {
        meow(`New Tab!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      });
      Blank().keyboardShortcut(this.myKey.closeTab.value, this.myKey.closeTab.keys, () => {
        meow(`Close Tab!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      });
      Blank().keyboardShortcut(this.myKey.showTabs.value, this.myKey.showTabs.keys, () => {
        meow(`Show Tabs!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      });
      Blank().keyboardShortcut(this.myKey.focusAddress.value, this.myKey.focusAddress.keys, () => {
        meow(`Focus Address!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      });
      Blank().keyboardShortcut(this.myKey.searchInPage.value, this.myKey.searchInPage.keys, () => {
        meow(`Search in Page!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      });
      Blank().keyboardShortcut(this.myKey.fullscreen.value, this.myKey.fullscreen.keys, () => {
        meow(`Fullscreen!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      });
      Blank().keyboardShortcut(this.myKey.history.value, this.myKey.history.keys, () => {
        meow(`History!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      });
      Blank().keyboardShortcut(this.myKey.refresh.value, this.myKey.refresh.keys, () => {
        meow(`Refresh!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      });
      Blank().keyboardShortcut(this.myKey.print.value, this.myKey.print.keys, () => {
        meow(`Print Page!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      });
      Blank().keyboardShortcut(this.myKey.newWindow.value, this.myKey.newWindow.keys, () => {
        meow(`New Window!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      });
      Blank().keyboardShortcut(this.myKey.pin.value, this.myKey.pin.keys, () => {
        meow(`Pin window to top!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      });
      Blank().keyboardShortcut(this.myKey.save.value, this.myKey.save.keys, () => {
        meow(`Save Page!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      });
      Blank().keyboardShortcut(this.myKey.zones.value, this.myKey.zones.keys, () => {
        meow(`Zones!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      });
      Blank().keyboardShortcut(this.myKey.fullscreenWindowed.value, this.myKey.fullscreenWindowed.keys, () => {
        meow(`Windowed Fullscreen!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      });
    }
  }
}

export { MeowPlaceForKeyShortcuts };
