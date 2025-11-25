import lazy { fileIo } from '@kit.CoreFileKit';
import lazy { bunch_of_tabs } from '../hosts/bunch_of_tabs';
import lazy { meowContext } from '../utils/environment_tools';
import { sandbox_mkdir_sync, sandbox_rename_sync, sandbox_rmdir_sync } from '../utils/storage_tools';
import lazy { storage_of_id } from '../utils/ui_tools';

/**
 * Checks and discover saved zones on disk.
 * @returns The list of zone names.
 * */
export function scan_zones() {
  try {
    let zones = fileIo.listFileSync(meowContext().filesDir + '/zones', { recursion: false });
    return zones;
  } catch (error) {
    return [];
  }
}

export function modify_zone_name(original: string, after: string) {
  sandbox_rename_sync('zones/' + original, 'zones/' + after);
  refresh_AppStorage_zones();
}

/**
 * Refreshes the zones entries in AppStorage.
 * */
export function refresh_AppStorage_zones() {
  AppStorage.setOrCreate('zones', scan_zones());
}

/**
 * Marks a window to be a zone.
 * @param window_id The id of zone / window.
 * @returns True if success, false if duplicate alias, undefined if already is zone.
 * */
export function set_zone(window_id: string) {
  let storage = storage_of_id(window_id);
  let alias = storage.get('my_window_alias') as string;
  let is_zone = storage.get('is_zone') as boolean;
  // If already is a zone
  // if (is_zone) {
  //   console.log(`[zone_actions][set_zone] Failed, is already a zone!`);
  //   return undefined;
  // }
  // Do not allow duplicate aliases
  if (scan_zones().includes(alias)) {
    console.log(`[zone_actions][set_zone] Failed, duplicated alias!`);
    return false;
  }
  // Save
  let tabs = storage.get('bunch_of_tabs') as bunch_of_tabs;
  // After work
  let lord = AppStorage.get('THE_LORD_OF_THE_WINDOWS') as string;
  if (window_id == lord) {
    // If is lord, Clean current continue file;
    // try {
    let src = meowContext().filesDir + '/continue/';
    let des = meowContext().filesDir + '/zones/' + alias + '/';
    sandbox_mkdir_sync('zones/' + alias);
    console.log(`[set_zone] About to copyDirSync! src=${src}, des=${des}`);
    fileIo.copyDirSync(src, des, 1);
    // } catch (e) {
    //   console.error(`[set_zone] copyDirSync Failed: ` + e);
    // }
    sandbox_rmdir_sync('continue');
    sandbox_mkdir_sync('continue');
  } else {
    // If is other window, then directly save web states to /zone/name
    tabs.re_save_web_state(0, 'zones/' + alias);
  }
  // Mark
  storage.setOrCreate('is_zone', true);
  refresh_AppStorage_zones();
  return true;
}

/**
 * Marks a window to be NO LONGER a zone.
 * @param window_id The id of zone / window.
 * @returns True if success, undefined if is already NOT a zone.
 * */
export function off_zone(window_id: string) {
  let storage = storage_of_id(window_id);
  let alias = storage.get('my_window_alias') as string;
  let is_zone = storage.get('is_zone') as boolean;
  // If is NOT a zone
  // if (!is_zone) {
  //   return undefined;
  // }
  // After work
  sandbox_rmdir_sync('zones/' + alias);
  let lord = AppStorage.get('THE_LORD_OF_THE_WINDOWS') as string;
  if (window_id == lord) {
    // If is lord, resave web states;
    let tabs = storage.get('bunch_of_tabs') as bunch_of_tabs;
    tabs.re_save_web_state(0, 'continue');
  } else {
    // If is other window, then directly save web states to /zone/name
    // Do nothing
  }
  storage.setOrCreate('is_zone', false);
  refresh_AppStorage_zones();
  return true;
}

/**
 * Returns the web state directory for saving.
 * @param storage The LocalStorage of window.
 * @returns The directory or undefined (if is neither a zone nor lord window).
 * */
export function web_state_dir(storage: LocalStorage) {
  let alias = storage.get('my_window_alias') as string;
  let is_zone = storage.get('is_zone') as boolean;
  if (is_zone) {
    return 'zones/' + alias;
  }
  // Not zone, check if is lord
  let is_lord = (storage.get('my_window_id') as string) == (AppStorage.get('THE_LORD_OF_THE_WINDOWS') as string);
  if (is_lord) {
    return 'continue';
  }
  return undefined;
}