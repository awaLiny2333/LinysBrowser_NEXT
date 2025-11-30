import { fileIo } from '@kit.CoreFileKit';
import { bunch_of_extensions, extension } from '../hosts/bunch_of_extensions';
import { meowContext } from '../utils/environment_tools';
import { sandbox_read_text_sync } from '../utils/storage_tools';
import { common } from '@kit.AbilityKit';

export function scan_extensions(context?: common.UIAbilityContext) {
  // Scan
  let extensions_ids: string[] = [];
  try {
    extensions_ids = fileIo.listFileSync(meowContext().filesDir + '/extensions', { recursion: false });
  } catch (error) {
    return [];
  }
  // Put into bunch
  let exts: bunch_of_extensions = new bunch_of_extensions();
  for (let index = 0; index < extensions_ids.length; index++) {
    let path = path_of_extension(extensions_ids[index]);
    if (path) {
      let path_full = context?.filesDir + path;
      try {
        // This is an extension
        let extension_obj = new extension(extensions_ids[index], path, path_full);
        exts.extensions.push(extension_obj);
      } catch (e) {
        console.error('[scan_extensions][' + path + '] Failed: ' + e);
      }
    }
  }
  AppStorage.setOrCreate('bunch_of_extensions', exts);
  console.log('[zone_actions][scan_extensions] Result: ' + extensions_ids);
  return extensions_ids;
}

export function refresh_AppStorage_extensions(context?: common.UIAbilityContext) {
  try {
    let xts = scan_extensions(context);
    AppStorage.setOrCreate('extensions', xts);
  } catch (e) {
    console.error('[refresh_AppStorage_extensions] Failed: ' + e);
  }
}

/**
 * Reads the manifest of extension.
 * @param id The id of extension.
 * @returns The manifest object.
 * */
export function manifest_of_extension(path: string | undefined) {
  if (!path) {
    return undefined;
  }
  let manifest = sandbox_read_text_sync(`${path}/manifest.json`);
  let m: object = JSON.parse(manifest);
  console.log(`[extension_actions][manifest_of_extension] Read manifest.json! "name"=${m?.['name']}` + '\n' + m);
  return m;
}

/**
 * Reads the locale JSON object of extension.
 * @param path The path of the extension root directory.
 * @param locale The locale code, like 'en'.
 * @returns The JSON object or undefined, if not found.
 * */
export function locale_messages_of_extension(path: string | undefined, locale: string) {
  let messages: object | undefined;
  if (!path) {
    return undefined;
  }
  let locale_text = sandbox_read_text_sync(`${path}/_locales/${locale}/messages.json`);
  if (locale_text == 'undefined') {
    // Locale not found
    return undefined;
  }
  messages = JSON.parse(locale_text);
  return messages;
}

/**
 * Gets the path of extension.
 * @param id
 * @returns
 * */
export function path_of_extension(id: string) {
  let versions: string[] = [];
  try {
    versions = fileIo.listFileSync(meowContext().filesDir + '/extensions/' + id, { recursion: false });
  } catch (e) {
    return undefined;
  }
  if (versions.length == 0) {
    return undefined;
  }
  let path = `/extensions/${id}/${versions[0]}`
  console.log('[path_of_extension]' + path);
  return path;
}

// i18n

export function get_message_of_extension(messages: object, message_name: string) {
  return (messages?.[message_name])?.['message'] as string;
}

export function message_of_manifest_key(messages: object, key: string): string {
  let message_name = key.substring(6, key.length - 2);
  return get_message_of_extension(messages, message_name);
}