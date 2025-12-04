import { fileIo } from '@kit.CoreFileKit';
import { bunch_of_extensions, extension } from '../hosts/bunch_of_extensions';
import { meowContext } from '../utils/environment_tools';
import {
  copy_from_uri_to_sandbox_temp_with_timestamp,
  document_pick_to_uri,
  sandbox_access,
  sandbox_mkdir_sync,
  sandbox_read_text_sync,
  sandbox_rmdir_sync,
  uri_2_path
} from '../utils/storage_tools';
import lazy { common } from '@kit.AbilityKit';
import lazy { cryptoFramework } from '@kit.CryptoArchitectureKit';
import lazy { buffer } from '@kit.ArkTS';
import lazy { zlib } from '@kit.BasicServicesKit';

export function scan_extensions(context: common.UIAbilityContext) {
  // Scan
  let extensions_ids: string[] = [];
  try {
    extensions_ids = fileIo.listFileSync(meowContext().filesDir + '/extensions', { recursion: false });
  } catch (error) {
    return [];
  }
  // Put into bunch
  let exts: bunch_of_extensions = new bunch_of_extensions();
  AppStorage.setOrCreate('bunch_of_extensions', exts);

  for (let index = 0; index < extensions_ids.length; index++) {
    try_add_extension_to_bunch(extensions_ids[index], exts, context);
  }
  console.log('[zone_actions][scan_extensions] Result: ' + extensions_ids);
  return extensions_ids;
}

export function refresh_AppStorage_extensions(context: common.UIAbilityContext) {
  try {
    let xts = scan_extensions(context);
    AppStorage.setOrCreate('extensions_ids', xts);
  } catch (e) {
    console.error('[refresh_AppStorage_extensions] Failed: ' + e);
  }
}

// Load and Uninstall

/**
 * Calculates the id for locally installed extension.
 * @param path The path.
 * @returns The ID.
 * */
export function extension_id_for_path(path: string) {
  let mdAlgName = 'SHA256';
  let message = path;
  let md = cryptoFramework.createMd(mdAlgName);
  md.updateSync({ data: new Uint8Array(buffer.from(message, 'utf-8').buffer) });
  let mdResult = md.digestSync();
  console.info('[id_for_path][Sync] Md result:' + mdResult.data);

  let text_result = Array.from(mdResult.data)
    .map(byte => byte.toString(16).padStart(2, '0'))
    .join('');

  console.info('[id_for_path][Sync] Text result:' + text_result);
  const result = Array.from(text_result)
    .slice(0, 32)
    .map(i => String.fromCharCode(parseInt(i, 16) + 'a'.charCodeAt(0)))
    .join('');

  console.info('[id_for_path][Sync] ID result:' + result);
  return result;
}

/**
 * Selects and installs a zip or crx.
 * @returns True if success, false if failed, undefined for a duplicated id.
 * */
export function select_install_extension() {
  return document_pick_to_uri(['zip', 'crx']).then(async (result) => {
    if (!result) {
      // storage.set('universal_fail_prompt_desc_gateway', $r('app.string.Fail_select_bad_file'));
      return false;
    }
    console.log(`[select_install_extension] ${result}`);
    let path = uri_2_path(result);
    let id = extension_id_for_path(path);

    // Same ID, block
    let block = sandbox_access('extensions/' + id + '/');
    if (block) {
      return undefined;
    }

    // Copy
    let uri_zip_crx = copy_from_uri_to_sandbox_temp_with_timestamp(result, 'extensions');
    // sandbox_mkdir_sync('extensions/' + id);
    sandbox_mkdir_sync('extensions/' + id + '/meow');

    // Decompress
    let inFile = uri_2_path(uri_zip_crx);
    let outFileDirBase = meowContext().filesDir + '/extensions/' + id;
    let outFileDir = outFileDirBase + '/meow';
    console.log(`[select_install_extension] Decompress from ${inFile}, to ${outFileDir}`);
    let options: zlib.Options = {
      level: zlib.CompressLevel.COMPRESS_LEVEL_DEFAULT_COMPRESSION,
      // parallel: zlib.ParallelStrategy.PARALLEL_STRATEGY_PARALLEL_DECOMPRESSION
    };
    try {
      return zlib.decompressFile(inFile, outFileDir, options).then(() => {

        let files = fileIo.listFileSync(outFileDir);
        console.log(`[Extension] listFileSync: ${files}`);
        if (files.length > 1) {
          // It's OK
        } else {
          // The zip file includes another layer of folder!
          try {
            fileIo.moveDirSync(outFileDir + '/' + files[0], outFileDirBase);
            sandbox_rmdir_sync('extensions/' + id + '/meow');
          } catch (e) {
            console.error(`[Extension] Reduce layer failed! from ${outFileDir + '/' + files[0]} to ${outFileDirBase}: ` + e);
          }
        }

        // Update extensions
        let result = try_add_extension_to_bunch(id);
        if (!result) {
          sandbox_rmdir_sync('extensions/' + id);
          console.error(`[Extension] Try add extension failed! Deleting directory [${'extensions/' + id}]!`);
          return false;
        }

        let extensions_ids = AppStorage.get('extensions_ids') as string[];
        extensions_ids.push(id);
        return true;
      })
    } catch (e) {
      console.error('[Extension][select_install_extension][decompressFile] zip error: ' + e);
      return false;
    }
  })
}

/**
 * Uninstalls an extension.
 * @param id The ID of extension.
 * @returns True if success.
 * */
export function uninstall_extension(id: string) {
  console.log(`[uninstall_extension] Try to uninstall extension id=${id}`);
  let path = path_of_extension(id);
  if (path) {
    let exts = AppStorage.get('bunch_of_extensions') as bunch_of_extensions;

    for (let index = 0; index < exts.extensions.length; index++) {
      if (exts.extensions[index].id == id) {
        // The last bit of your life! Take it!
        terminate_extension(id);
        exts.extensions.splice(index, 1);
        let extensions_ids = AppStorage.get('extensions_ids') as string[];
        extensions_ids.splice(index, 1);
        exts.update_timestamp();
        break;
      }
    }

    sandbox_rmdir_sync(`extensions/${id}`);
    return true;
  }
  return false;
}

/**
 * All jobs to be done right before uninstallation.
 * @param id The id of extension.
 * */
function terminate_extension(id: string) {
  console.log(`[terminate_extension][${id}] About to be uninstalled!`);
}

/**
 * Try to add an extension of id to bunch_of_tabs of the app.
 * @param id The id of extension.
 * @param exts The bunch_of_extensions. If left blank, then the one from AppStorage would be used.
 * @param context The common.UIAbilityContext. If left blank, then meowContext() would be used.
 * @returns True if success, false otherwise.
 * */
function try_add_extension_to_bunch(id: string, boe_provided?: bunch_of_extensions, context?: common.UIAbilityContext) {
  console.log(`[try_add_extension_to_bunch] Try to add extension id=${id}`);
  let exts = boe_provided || AppStorage.get('bunch_of_extensions') as bunch_of_extensions;
  // Update extensions
  let path = path_of_extension(id);
  if (path) {
    let path_full = (context || meowContext()).filesDir + path;
    try {
      console.log(`[try_add_extension_to_bunch] Found at path_full=${path_full}`);
      // This is an extension
      let extension_obj = new extension(id, path, path_full);
      exts.extensions.push(extension_obj);
      if (boe_provided) {
        // No update timestamp, because of a boe provided => This is in initialization stage.
      } else {
        exts.update_timestamp();
        welcome_extension(id);
      }
      return true;
    } catch (e) {
      console.error('[try_add_extension_to_bunch][' + id + '][' + path + '] Failed: ' + e);
    }
  }
  return false;
}

/**
 * All jobs executed on extension installed.
 * @param id The id of extension.
 * */
function welcome_extension(id: string) {
  console.log(`[terminate_extension][${id}] Just installed!`);
}

// i18n

export function get_message_from_messages(messages: object, message_name: string) {
  return (messages?.[message_name])?.['message'] as string;
}

export function message_of_manifest_key(messages: object, key: string): string {
  let message_name = key.substring(6, key.length - 2);
  return get_message_from_messages(messages, message_name);
}

// Data

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
 * @param id The ID of extension.
 * @returns /extensions/${id}/${versions[0]}.
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