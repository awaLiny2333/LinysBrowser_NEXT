import { common } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import lazy { meow, meowLevel } from '../../catstypicalframework/utils/catsLogger';
import { meowTabsBunch } from '../../hosts/app/tabs/classes/meowTabsBunch';
import lazy { meowDialogManager, openDialogRequestType } from '../../hosts/system/dialogs/classes/meowDialogManager';
import lazy { requestDialog } from '../../hosts/system/dialogs/scripts/dialog';
import { meowUiGoBackSource, meowUiHost } from '../../hosts/system/windows/classes/meowUiHost';
import lazy { newWindow } from '../../hosts/system/windows/scripts/multiwindows';
import { meowKeyboardMan } from '../../hosts/userdata/keyshortcuts/classes/meowKeyboardMan';
import { searchInPageInputId } from '../constants';
import lazy { defaultAnimation, getMySettings } from '../settings';

@Builder
export function MeowPlaceForKeyShortcuts(
  myDialog: meowDialogManager,
  myUi: meowUiHost,
  myKey: meowKeyboardMan,
  myTabs: meowTabsBunch,
  context: UIContext
) {
  Row() {
    if (!(myKey.esc.value == FunctionKey.ESC && myKey.esc.keys.length == 0)) {
      Blank().keyboardShortcut(FunctionKey.ESC, [], () => {
        // To block ESC.
      });
    }
    Blank().keyboardShortcut(myKey.esc.value, myKey.esc.keys, () => {
      myUi.goBackUni(meowUiGoBackSource.ESC, context);
      meow(`ESC!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
    });
    Blank().keyboardShortcut(myKey.newTab.value, myKey.newTab.keys, () => {
      meow(`New Tab!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      const myTabs = AppStorageV2.connect(meowTabsBunch, `meowTabsBunch_${myUi.windowId}`)!;
      animateToImmediately(defaultAnimation(), () => {
        myTabs.newTabWrapped();
      });
    });
    Blank().keyboardShortcut(myKey.closeTab.value, myKey.closeTab.keys, () => {
      meow(`Close Tab!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      const myTabs = AppStorageV2.connect(meowTabsBunch, `meowTabsBunch_${myUi.windowId}`)!;
      animateToImmediately(defaultAnimation(), () => {
        myTabs.closeCurrent();
      });
    });
    Blank().keyboardShortcut(myKey.showTabs.value, myKey.showTabs.keys, () => {
      animateToImmediately(defaultAnimation(), () => {
        myUi.showTabs = !myUi.showTabs;
      });
      getMySettings().setByIndex(22, myUi.showTabs);
      if (myUi.showTabs) {
        meow(`Show Tabs!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      } else {
        meow(`Hide Tabs!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      }
    });
    Blank().keyboardShortcut(myKey.focusAddress.value, myKey.focusAddress.keys, () => {
      try {
        myUi.requestAddressBarFocus(context);
        meow(`Focus Address!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      } catch (e) {
        meow(`Focus Address Failed: ${e}`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      }
    });
    Blank().keyboardShortcut(myKey.searchInPage.value, myKey.searchInPage.keys, () => {
      if (!myUi.inPageSearchShow) {
        animateToImmediately(defaultAnimation(), () => {
          myUi.inPageSearchShow = true;
        });
      } else {
        // Focus
        focusControl.requestFocus(searchInPageInputId);
      }
      meow(`Search in Page!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
    });
    Blank().keyboardShortcut(myKey.fullscreen.value, myKey.fullscreen.keys, () => {
      myUi.fullscreenFull();
      meow(`Fullscreen!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
    });
    Blank().keyboardShortcut(myKey.history.value, myKey.history.keys, () => {
      requestDialog(myDialog, openDialogRequestType.HISTORY);
      meow(`History!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
    });
    Blank().keyboardShortcut(myKey.refresh.value, myKey.refresh.keys, () => {
      myTabs.refreshStopCurrent();
      meow(`Refresh!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
    });
    Blank().keyboardShortcut(myKey.print.value, myKey.print.keys, () => {
      meow(`Print Page!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      myTabs.printCurrent();
    });
    Blank().keyboardShortcut(myKey.newWindow.value, myKey.newWindow.keys, () => {
      newWindow(context.getHostContext() as common.UIAbilityContext);
      meow(`New Window!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
    });
    Blank().keyboardShortcut(myKey.pin.value, myKey.pin.keys, () => {
      myUi.togglePin();
      meow(`Pin window to top!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
    });
    Blank().keyboardShortcut(myKey.save.value, myKey.save.keys, () => {
      myTabs.saveCurrent();
      meow(`Save Page!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
    });
    Blank().keyboardShortcut(myKey.zones.value, myKey.zones.keys, () => {
      requestDialog(myDialog, openDialogRequestType.ZONES);
      meow(`Zones!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
    });
    Blank().keyboardShortcut(myKey.fullscreenWindowed.value, myKey.fullscreenWindowed.keys, () => {
      myUi.fullscreenWindowed();
      meow(`Windowed Fullscreen!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
    });
    Blank().keyboardShortcut(myKey.sidebar.value, myKey.sidebar.keys, () => {
      animateToImmediately(defaultAnimation(), () => {
        myUi.showSidebar = !myUi.showSidebar;
      });
      getMySettings().setByIndex(82, myUi.showSidebar);
      if (myUi.showSidebar) {
        meow(`Show Sidebar!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      } else {
        meow(`Hide Sidebar!`, `MeowPlaceForShortcuts`, meowLevel.WARN);
      }
    });
  };
}
