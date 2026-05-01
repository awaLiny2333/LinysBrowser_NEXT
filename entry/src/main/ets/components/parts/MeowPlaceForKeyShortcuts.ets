import { meowKeyboardMan } from '../../hosts/userdata/keyshortcuts/classes/meowKeyboardMan';
import { AppStorageV2 } from '@kit.ArkUI';
import { meow, meowLevel } from '../../catstypicalframework/utils/catsLogger';
import { meowUiGoBackSource, meowUiStatuses } from '../../hosts/system/windows/classes/meowUiStatuses';
import { searchBarId } from './Homepage/MeowSearchBar';
import { meowDialogManager, openDialogRequestType } from '../../hosts/system/dialogs/classes/meowDialogManager';
import { requestDialog } from '../../hosts/system/dialogs/scripts/dialog';
import { newWindow } from '../../hosts/system/windows/scripts/multiwindows';
import { common } from '@kit.AbilityKit';

@ComponentV2
struct MeowPlaceForKeyShortcuts {
  @Param @Require myDialog: meowDialogManager;
  @Param @Require myUi: meowUiStatuses;
  @Local myKey: meowKeyboardMan = AppStorageV2.connect(meowKeyboardMan)!;

  build() {
    Row() {
      if (!(this.myKey.esc.value == FunctionKey.ESC && this.myKey.esc.keys.length == 0)) {
        Blank().keyboardShortcut(FunctionKey.ESC, [], () => {
          // To block ESC.
        });
      }
      Blank().keyboardShortcut(this.myKey.esc.value, this.myKey.esc.keys, () => {
        this.myUi.goBackUni(meowUiGoBackSource.ESC, this.getUIContext());
        meow(`ESC!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      });
      Blank().keyboardShortcut(this.myKey.newTab.value, this.myKey.newTab.keys, () => {
        meow(`New Tab!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      });
      Blank().keyboardShortcut(this.myKey.closeTab.value, this.myKey.closeTab.keys, () => {
        meow(`Close Tab!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      });
      Blank().keyboardShortcut(this.myKey.showTabs.value, this.myKey.showTabs.keys, () => {
        this.myUi.showTabs = !this.myUi.showTabs;
        if (this.myUi.showTabs) {
          meow(`Show Tabs!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
        } else {
          meow(`Hide Tabs!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
        }
      });
      Blank().keyboardShortcut(this.myKey.focusAddress.value, this.myKey.focusAddress.keys, () => {
        try {
          this.getUIContext().getFocusController().requestFocus(searchBarId);
          meow(`Focus Address!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
        } catch (e) {
          meow(`Focus Address Failed: ${e}`, `MeowPlaceForShortcuts`, meowLevel.WARN);
        }
      });
      Blank().keyboardShortcut(this.myKey.searchInPage.value, this.myKey.searchInPage.keys, () => {
        meow(`Search in Page!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      });
      Blank().keyboardShortcut(this.myKey.fullscreen.value, this.myKey.fullscreen.keys, () => {
        meow(`Fullscreen!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      });
      Blank().keyboardShortcut(this.myKey.history.value, this.myKey.history.keys, () => {
        requestDialog(this.myDialog, openDialogRequestType.HISTORY);
        meow(`History!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      });
      Blank().keyboardShortcut(this.myKey.refresh.value, this.myKey.refresh.keys, () => {
        meow(`Refresh!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      });
      Blank().keyboardShortcut(this.myKey.print.value, this.myKey.print.keys, () => {
        meow(`Print Page!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      });
      Blank().keyboardShortcut(this.myKey.newWindow.value, this.myKey.newWindow.keys, () => {
        newWindow(this.getUIContext().getHostContext() as common.UIAbilityContext);
        meow(`New Window!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      });
      Blank().keyboardShortcut(this.myKey.pin.value, this.myKey.pin.keys, () => {
        this.myUi.togglePin();
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
    };
  }
}

export { MeowPlaceForKeyShortcuts };
