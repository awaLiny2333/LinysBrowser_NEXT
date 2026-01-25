import { window } from '@kit.ArkUI';
import { BusinessError, deviceInfo, settings } from '@kit.BasicServicesKit';
import { bunch_of_tabs } from '../hosts/bunch_of_tabs';
import { AbilityConstant, common, Want } from '@kit.AbilityKit';
import { bunch_of_settings } from '../hosts/bunch_of_settings';
import { meowPx2vp } from './environment_tools';
import { default_window_decor_height } from '../hosts/bunch_of_defaults';
import { motion } from '@kit.MultimodalAwarenessKit';

// Statuses

/**
 * Gets current tabs style is whether horizontal or not.
 * @returns a boolean. True for is horizontal.
 * */
export function current_tabs_style_is_horizontal(storage: LocalStorage) {
  let tablet_mode = storage.get('tablet_mode') as boolean;
  let tabs_style = AppStorage.get('tabs_style') as string;
  let tabs_style_non_tablet_mode = AppStorage.get('tabs_style_non_tablet_mode') as string;
  if (tablet_mode) {
    return tabs_style == 'horizontal';
  } else {
    return tabs_style_non_tablet_mode == 'horizontal';
  }
}

/**
 * Checks if some dialogs are already opened.
 * @param storage The LocalStorage
 * @returns True or False.
 * */
export function is_some_dialogs_opened(storage: LocalStorage) {
  let opened_dialog_controllers = storage.get('opened_dialog_controllers') as CustomDialogController[];
  if (opened_dialog_controllers && opened_dialog_controllers.length > 0) {
    // console.log('[is_some_dialogs_opened] True! ' + opened_dialog_controllers.length);
    return true;
  }
  return false;
}

// Actions

export function new_window(context: common.UIAbilityContext, instanceKey: string, new_window_alias: string, is_zone: boolean = false) {
  // Open new window
  let wantInfo: Want = {
    deviceId: '', // This device
    bundleName: 'meow.liny.browser.cat.uwu',
    moduleName: 'home',
    abilityName: 'HomeAbility',
    parameters: {
      instanceKey: instanceKey,
    }
  };
  bunch_of_settings.set('my_window_alias_last', new_window_alias);
  AppStorage.setOrCreate('LAST_WINDOW_WINDOW_IS_ZONE', is_zone);
  context.startAbility(wantInfo).then(() => {
    console.log('[meowAppSettings] startAbility success.');
  }).catch((error: BusinessError) => {
    console.log('[meowAppSettings] startAbility failed: ' + error);
  });
}

export function close_window(storage: LocalStorage) {
  let windowClass = storage.get('my_windowClass') as window.Window;
  windowClass.destroyWindow().catch((e: BusinessError) => {
    console.error('[close_window] Failed: ' + e);
  });
}

/**
 * Updates window decor height if is in Free-window Mode.
 * @param window_id The window id.
 * */
export function update_window_decor_height(window_id: string) {
  let free_window_mode = AppStorage.get('free_window_mode') as boolean;
  if (!free_window_mode) {
    console.warn('[free][update_window_decor_height] INTERCEPTED & Executed nothing because not in Free-window Mode!');
    return;
  }
  // Process
  let h = default_window_decor_height(storage_of_id(window_id));
  let windowClass = window_of_id(window_id);
  let storage = storage_of_id(window_id);
  storage.setOrCreate('topAvoidHeight', h);
  console.log('[free][update_window_decor_height] New height: ' + h);
  try {
    windowClass.setWindowDecorHeight(h);
  } catch (error) {
    console.error('[free][update_window_decor_height] setWindowDecorHeight failed: ' + error);
  }
}

/**
 * Pins or unpins a window to the top.
 * @param id The window id.
 * */
export function pin_to_top(id: string) {
  if (!(AppStorage.get('free_window_mode') as boolean)) {
    console.log('[pin_to_top] Didn\'t pin window to top because is not in free window mode. But how did you get here?');
    return;
  }
  let window = window_of_id(id);
  let storage = storage_of_id(id);
  let pin = storage.get('pin_to_top') as boolean;
  pin = !pin;
  storage.set('pin_to_top', pin);
  try {
    window.setWindowTopmost(pin);
  } catch (e) {
    console.error('[pin_to_top] Failed: ' + e);
  }
}

// Continue

/**
 * Determines if the url is ok to be continued on another device.
 * @param url The url.
 * @param storage The LocalStorage. If filled then the result is saved to 'sharable_continuable'.
 * @returns True or false.
 * */
export function is_address_continuable(url: string, storage?: LocalStorage) {
  let result = true;
  if (url.substring(0, 7) == 'meow://') {
    // Is internal page
    console.log('[is_address_continuable] False! [' + url + '].');
    result = false
  } else {
    console.log('[is_address_continuable] True! [' + url + '].');
  }
  storage?.setOrCreate('sharable_continuable', result);
  return result;
}

/**
 * Sets the continuability (?) of current page.
 * @param context
 * @param con
 * */
export function set_continuable(context: common.UIAbilityContext, con: boolean) {
  // console.log('[set_continuable] ' + con);
  let state = con ? AbilityConstant.ContinueState.ACTIVE : AbilityConstant.ContinueState.INACTIVE;
  context.setMissionContinueState(state).catch((e: BusinessError) => {
    console.error('[set_continuable] Failed: ' + JSON.stringify(e));
  });
}

// Environment

/**
 * Returns the window run time in ms.
 * @param storage The LocalStorage.
 * @returns Time in ms.
 * */
export function run_time(storage: LocalStorage) {
  return Date.now() - (storage.get('START_TIME') as number);
}

/**
 * Enables the listeners for avoid area change.
 * @param windowClass The window.Window object.
 * @param storage The LocalStorage of that window.
 * */
export function listen_avoid(windowClass: window.Window, storage: LocalStorage) {
  try {
    windowClass.on('avoidAreaChange', (data) => {
      console.log('[listen_avoid] Changes on avoid areas: ')
      if (data.type == window.AvoidAreaType.TYPE_SYSTEM) {
        // Only refresh top avoid height from here if is not in free window mode.
        if (!(AppStorage.get('free_window_mode') as boolean)) {
          let avoidTop = meowPx2vp(data.area.topRect.height);
          storage.setOrCreate('topAvoidHeight', avoidTop + (avoidTop == 0 ? 0 : 2));
          console.log('\tNew topAvoidHeight: ' + avoidTop + (avoidTop == 0 ? 0 : 2));
        }
      }
      if (data.type == window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
        let avoidBottom = meowPx2vp(data.area.bottomRect.height);
        storage.setOrCreate('bottomAvoidHeight', avoidBottom);
        console.log('\tNew avoidBottomHeight: ' + avoidBottom);
      }
      if (data.type == window.AvoidAreaType.TYPE_CUTOUT) {
        let avoidLeft = meowPx2vp(data.area.leftRect.width);
        storage.setOrCreate('leftAvoidWidth', avoidLeft + (avoidLeft == 0 ? 0 : 2));
        console.log('\tNew leftAvoidWidth: ' + avoidLeft + (avoidLeft == 0 ? 0 : 2));
      }
      if (data.type == window.AvoidAreaType.TYPE_CUTOUT) {
        let avoidRight = meowPx2vp(data.area.rightRect.width);
        storage.setOrCreate('rightAvoidWidth', avoidRight + (avoidRight == 0 ? 0 : 2));
        console.log('\tNew avoidRightWidth: ' + avoidRight + (avoidRight == 0 ? 0 : 2));
      }
    })
  } catch (e) {
    console.error('[listen_avoid] Failed: ' + e);
  }
}

/**
 * Check avoid area and store them in storage.
 * @param windowClass The window.Window object.
 * @param storage The LocalStorage of that window.
 * @param free_window The type of window: true for free windows
 * (PC, 2in1, Free-window mode on Tablets),
 * false for traditional windows (Phones, regular float windows on Tablets).
 * */
export function get_avoid(windowClass: window.Window, storage: LocalStorage) {
  console.log('[get_avoid] Get avoid areas: ');
  try {
    let type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
    let avoidArea = windowClass.getWindowAvoidArea(type);
    let avoidBottom = meowPx2vp(avoidArea.bottomRect.height);
    storage.setOrCreate('bottomAvoidHeight', avoidBottom);
    console.log('\tNew avoidBottomHeight: ' + avoidBottom);

    if (!(AppStorage.get('free_window_mode') as boolean)) {
      // Only refresh top avoid height from here if is not in free window mode.
      type = window.AvoidAreaType.TYPE_SYSTEM;
      avoidArea = windowClass.getWindowAvoidArea(type);
      let avoidTop = meowPx2vp(avoidArea.topRect.height);
      storage.setOrCreate('topAvoidHeight', avoidTop + (avoidTop == 0 ? 0 : 2));
      console.log('\ttopAvoidHeight: ' + avoidTop + (avoidTop == 0 ? 0 : 2));
    }

    type = window.AvoidAreaType.TYPE_CUTOUT;
    avoidArea = windowClass.getWindowAvoidArea(type);
    let avoidLeft = meowPx2vp(avoidArea.leftRect.width);
    storage.setOrCreate('leftAvoidWidth', avoidLeft + (avoidLeft == 0 ? 0 : 2));
    console.log('\tNew leftAvoidWidth: ' + avoidLeft + (avoidLeft == 0 ? 0 : 2));

    type = window.AvoidAreaType.TYPE_CUTOUT;
    avoidArea = windowClass.getWindowAvoidArea(type);
    let avoidRight = meowPx2vp(avoidArea.rightRect.width);
    storage.setOrCreate('rightAvoidWidth', avoidRight + (avoidRight == 0 ? 0 : 2));
    console.log('\tNew avoidRightWidth: ' + avoidRight + (avoidRight == 0 ? 0 : 2));
  } catch (e) {
    console.error('[get_avoid] Failed: ' + e);
  }
}

/**
 * Enables the listeners for avoid area change.
 *
 * Works OK in both window modes (free / traditional).
 *
 * @param windowClass The window.Window object.
 * @param storage The LocalStorage of that window.
 * */
export function listen_focus(windowClass: window.Window, storage: LocalStorage) {
  // Focus Listener
  try {
    windowClass.on("windowEvent", (windowEvent) => {
      if (windowEvent == window.WindowEventType.WINDOW_ACTIVE || windowEvent == window.WindowEventType.WINDOW_SHOWN) {
        // Focused
        storage.setOrCreate('on_focus', true);
        let id = storage.get('my_window_id') as string
        AppStorage.setOrCreate('THE_WANT_HANDLER_OF_THE_WINDOWS', id);
        console.log(`[Meow][listen_focus] Set THE_WANT_HANDLER_OF_THE_WINDOWS to [${id}]!`);
      } else {
        // Lose focus
        storage.setOrCreate('on_focus', false);
      }
    });
  } catch (e) {
    console.error('[listen_focus] Failed: ' + e);
  }
}

/**
 * Checks settings to figure out if currently is in free window mode.
 * @param context The UIAbility Context.
 * @returns A boolean value.
 * */
export function get_free_window_mode(context: Context) {
  if (deviceInfo.deviceType == '2in1') {
    console.log('[free] return true for 2in1 type!');
    AppStorage.setOrCreate('free_window_mode', true);
    return true;
  }
  let free = settings.getValueSync(context, 'window_pcmode_switch_status', 'false', settings.domainName.USER_PROPERTY);
  console.log('[free] settings.getValueSync "window_pcmode_switch_status" = [' + free + ']!\n\treturn ' + (free == 'true') + '!');
  let in_free = free == 'true'
  AppStorage.setOrCreate('free_window_mode', in_free);
  return in_free;
}

/**
 * Listens to the Free-window Mode change and automatically switch modes.
 * @param context
 * @param windowClass
 * @param storage
 * @param id
 * */
export function listen_free_window_mode(context: Context, windowClass: window.Window, storage: LocalStorage, id: string) {
  console.log(`[listen_free_window_mode] ON for window ${id}!`)
  settings.registerKeyObserver(context, 'window_pcmode_switch_status', settings.domainName.USER_PROPERTY,
    () => {
      settings.getValue(context, 'window_pcmode_switch_status', settings.domainName.USER_PROPERTY)
        .then((val) => {
          let free = (val == 'true');

          // Only sets AppStorage if I am the lord of the windows
          if (AppStorage.get('THE_LORD_OF_THE_WINDOWS') as string == id) {
            console.log('[free][listen_free_window_mode] Detected Free-window mode change! [' + val + ']');
            if (free) {
              AppStorage.setOrCreate('free_window_mode', true);
              console.log('[free][listen_free_window_mode] Set AppStorage Free-window mode to true!');
            } else {
              AppStorage.setOrCreate('free_window_mode', false);
              console.log('[free][listen_free_window_mode] Set AppStorage Free-window mode to false!');
            }
          }
        });
    })
}

/**
 * Enters free window mode.
 * @param windowClass The window.Window of that window.
 * @param storage The LocalStorage of that window.
 * @param id The window ID.
 * */
export function enter_free_window_mode(windowClass: window.Window, storage: LocalStorage, id: string) {
  try {
    windowClass.setImmersiveModeEnabledState(false);
  } catch (e) {
    console.error('[free][enter_free_window_mode] 1 Failed: ' + e);
  }
  try {
    windowClass.setWindowDecorVisible(false);
  } catch (e) {
    console.error('[free][enter_free_window_mode] 2 Failed: ' + e);
  }
  try {
    windowClass.on('windowTitleButtonRectChange', (titleButtonRect) => {
      // console.log(`[enter_free_window_mode][windowTitleButtonRectChange] ${titleButtonRect}`);
      if (storage.get('windowDecorHeight') as number != titleButtonRect.height) {
        storage.setOrCreate('windowDecorHeight', titleButtonRect.height);
      }
      if (storage.get('windowDecorWidth') as number != titleButtonRect.width) {
        storage.setOrCreate('windowDecorWidth', titleButtonRect.width);
      }
      // storage.setOrCreate('windowDecorWidth', titleButtonRect.width);
    })
  } catch (e) {
    console.error('[free][enter_free_window_mode] 3 Failed: ' + e);
  }
  try {
    update_window_decor_height(id);
  } catch (e) {
    console.error('[free][enter_free_window_mode] 4 Failed: ' + e);
  }
}

/**
 * Leaves free window mode.
 * @param windowClass The window.Window of that window.
 * @param storage The LocalStorage of that window.
 * @param id The window ID.
 * */
export function enter_traditional_window_mode(windowClass: window.Window, storage: LocalStorage, id: string) {
  try {
    windowClass.setWindowDecorVisible(true);
  } catch (e) {
    console.error('[free][enter_traditional_window_mode] 1 Failed: ' + e);
  }
  try {
    windowClass.off('windowTitleButtonRectChange');
  } catch (e) {
    console.error('[free][enter_traditional_window_mode] 2 Failed: ' + e);
  }
  try {
    windowClass.setImmersiveModeEnabledState(true);
  } catch (e) {
    console.error('[free][enter_traditional_window_mode] 3 Failed: ' + e);
  }
  try {
    get_avoid(windowClass, storage);
  } catch (e) {
    console.error('[free][enter_traditional_window_mode] 4 Failed: ' + e);
  }
}

/**
 * Listens to the holding hand and auto update settings if applicable.
 * */
export function listen_holding_hand() {
  if (canIUse("SystemCapability.MultimodalAwareness.Motion")) {
    try {
      motion.on('holdingHandChanged', (m: motion.HoldingHandStatus) => {
        try {
          if (AppStorage.get('preferred_hand_auto') as boolean == true) {
            // Set preferred hand if recognized
            if (m == motion.HoldingHandStatus.UNKNOWN_STATUS || m == motion.HoldingHandStatus.NOT_HELD || m == motion.HoldingHandStatus.BOTH_HANDS_HELD) {
              // AppStorage.set('preferred_hand_left_or_right', bunch_of_settings.get('preferred_hand_left_or_right') as boolean)
              // Do nothing
            } else {
              let hand = (m == motion.HoldingHandStatus.LEFT_HAND_HELD) ? 'left' : 'right';
              AppStorage.set('preferred_hand_left_or_right', hand);
            }
          }
          console.info('[listen_holding_hand][holdingHandChanged] get succeeded: ' + m);
        } catch (err) {
          console.error("[listen_holding_hand][holdingHandChanged] Failed to get: " + err);
        }
      });
      console.info('[listen_holding_hand][motion.on] succeeded!');

    } catch (err) {
      console.error('[listen_holding_hand][motion.on] Failed: ' + err);
    }
  } else {
    console.error('[listen_holding_hand][canIUse] Rejected. unsupported SystemCapability!');
  }
}

// Windows and their data

/**
 * Gets the last LocalStorage.
 * @returns A LocalStorage.
 * */
export function last_storage() {
  return (AppStorage.get('windowStorages') as LocalStorage[])[(AppStorage.get('windowStorages') as LocalStorage[]).length-1];
}

/**
 * Infers the index of window.
 * @param w The windowClass (window.Window).
 * */
export function window_index_of_windowClass(w: window.Window) {
  let windowClasses = AppStorage.get('windows') as window.Window[];
  let window_idx = windowClasses.indexOf(w);
  return window_idx;
}

/**
 * Infers the index of WindowStage.
 * @param w The windowStages (window.WindowStage).
 * */
export function window_index_of_windowStage(w: window.WindowStage) {
  let windowStages = AppStorage.get('windowStages') as window.WindowStage[];
  let window_idx = windowStages.indexOf(w);
  return window_idx;
}

/**
 * Infers the index of window.
 * @param id The windowClass id (string).
 * */
export function window_index_of_id(id: string) {
  let windowIds = AppStorage.get('windowIds') as string[];
  let window_idx = windowIds.indexOf(id);
  return window_idx;
}

/**
 * Returns window of named by the id.
 * @param id The id.
 * @returns The window.Window.
 * */
export function window_of_id(id: string) {
  let windowClasses = AppStorage.get('windows') as window.Window[];
  let idx = window_index_of_id(id);
  return windowClasses[idx];
}

/**
 * Returns windowStage of named by the id.
 * @param id The id.
 * @returns The window.WindowStage.
 * */
export function windowStage_of_id(id: string) {
  let windowStages = AppStorage.get('windowStages') as window.WindowStage[];
  let idx = window_index_of_id(id);
  return windowStages[idx];
}

/**
 * Returns storage of named by the id.
 * @param id The id.
 * @returns The LocalStorage.
 * */
export function storage_of_id(id: string) {
  let windowStorages = AppStorage.get('windowStorages') as LocalStorage[];
  let idx = window_index_of_id(id);
  return windowStorages[idx];
}

/**
 * Retrieves the storage of the specific id window.
 * @param w The windowClass (window.Window).
 * */
export function storage_of_window(w: window.Window) {
  let windowStorages = AppStorage.get('windowStorages') as LocalStorage[];
  let windowStorage = windowStorages[window_index_of_windowClass(w)];
  return windowStorage;
}

/**
 * Retrieves the storage of the specific index window.
 * @param i The index of windows.
 * */
export function storage_of_index(i: number) {
  let windowStorages = AppStorage.get('windowStorages') as LocalStorage[];
  let windowStorage = windowStorages[i];
  return windowStorage;
}

/**
 * Infers the id of window.
 * @param w The windowClass (window.Window).
 * */
export function window_id_of_windowClass(w: window.Window) {
  let windowIds = AppStorage.get('windowIds') as string[];
  let window_id = windowIds[window_index_of_windowClass(w)];
  return window_id;
}

/**
 * Infers the id of window.
 * @param idx The window index (number).
 * */
export function window_id_at_index(idx: number) {
  let windowIds = AppStorage.get('windowIds') as string[];
  let window_id = windowIds[idx];
  return window_id;
}

/**
 * Retrieves the bunch_of_tabs of the specific id window.
 * @param w The windowClass (window.Window).
 * */
export function bunch_of_tabs_of_window(w: window.Window) {
  let all_bunch_of_tabs = AppStorage.get('all_bunch_of_tabs') as bunch_of_tabs[];
  let tabs = all_bunch_of_tabs[window_index_of_windowClass(w)];
  return tabs;
}

/**
 * Changes the my_window_alias of a window.
 * @param id The window id.
 * @param alias The new alias.
 * */
export function change_window_alias(id: string, alias: string) {
  let storage = storage_of_id(id);
  if (!storage) {
    return;
  }
  storage.set('my_window_alias', alias);

  let is_zone = storage.get('is_zone') as boolean;

  let windowClass = window_of_id(id);
  if (windowClass) {
    windowClass.setWindowTitle((is_zone ? '󰙟 ' : '') + alias).catch((e: BusinessError) => {
      console.error('[change_window_alias] Set alias failed! ' + JSON.stringify(e));
    });
  }

  if (!is_zone && window_index_of_id(id) == 0) {
    bunch_of_settings.set('my_window_alias_last', alias);
  }
}

/**
 * Sets the display orientation of the window.
 * @param orientation window.Orientation
 */
export function set_orientation(window: window.Window | undefined, orientation: window.Orientation) {
  return window?.setPreferredOrientation(orientation)
    .then((data) => {
      console.log('[setOrientation] Set ' + orientation + ', Returned: ' + JSON.stringify(data));
      return true;
    })
    .catch((err: string) => {
      console.error('[setOrientation] Failed: ' + JSON.stringify(err));
    });
}
