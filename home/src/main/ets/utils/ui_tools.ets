import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { bunch_of_tabs } from '../hosts/bunch_of_tabs';
import { common, Want } from '@kit.AbilityKit';

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

// Actions

export function new_window(context: common.UIAbilityContext, instanceKey: string, new_window_alias: string) {
  // Open new window
  let wantInfo: Want = {
    deviceId: '', // This device
    bundleName: 'com.next.liny.linysbrowserNEXT',
    moduleName: 'home',
    abilityName: 'HomeAbility',
    parameters: {
      instanceKey: instanceKey,
    }
  };
  AppStorage.setOrCreate('LAST_WINDOW_WINDOW_NAME', new_window_alias);
  context.startAbility(wantInfo).then(() => {
    console.log('[meowAppSettings] startAbility success.');
  }).catch((error: BusinessError) => {
    console.log('[meowAppSettings] startAbility failed: ' + error);
  });
}

/**
 * Updates window decor height.
 * @param windowClass The windowClass.
 * */
export function update_window_decor_height(windowClass: window.Window) {
  try {
    let showing_my_window_alias = AppStorage.get('showing_my_window_alias') as boolean;
    windowClass.setWindowDecorHeight(showing_my_window_alias ? 45 : 40);
  } catch (error) {
    console.error('[window_load_content] setWindowDecorHeight failed: ' + error);
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
 * Retrieves the storage of the specific id window.
 * @param w The windowClass (window.Window).
 * */
export function storage_of_window(w: window.Window) {
  let windowStorages = AppStorage.get('windowStorages') as LocalStorage[];
  let windowStorage = windowStorages[window_index_of_windowClass(w)];
  return windowStorage;
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

  let windowClass = window_of_id(id);
  if (windowClass) {
    windowClass.setWindowTitle(alias).catch((e: BusinessError) => {
      console.error('[change_window_alias] Set alias failed!' + JSON.stringify(e));
    });
  }
}
