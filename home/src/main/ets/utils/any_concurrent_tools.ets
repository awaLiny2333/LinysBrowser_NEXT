import { get_folder_size_Sync } from './storage_tools';
import { taskpool } from '@kit.ArkTS';
import { getGraphicsMemory_sync, getPrivateDirty_sync, getPss_sync, getSharedDirty_sync, getVss_sync } from './performance_tools';
import { common } from '@kit.AbilityKit';

let context = AppStorage.get("context") as common.UIAbilityContext;

@Concurrent
function get_sandbox_folder_size_concurrent(path: string): number {
  return get_folder_size_Sync(path, true);
}

/**
 * Get size of any folder, including its contents, in sandbox in a concurrent way.
 * @param folder_path the folder path.
 * @param sandbox_root to set sandbox root as root or not.
 * @returns a number of folder size.
 * */
export async function get_sandbox_folder_size(folder_path: string, sandbox_root: boolean): Promise<number> {
  let path: string;
  if (sandbox_root) {
    const filesDir = context.filesDir;
    path = filesDir + '/' + folder_path;
  } else {
    path = folder_path;
  }
  return await taskpool.execute(get_sandbox_folder_size_concurrent, path) as number;
}

export async function getPss(): Promise<bigint> {
  return await taskpool.execute(getPss_sync) as bigint;
}

export async function getVss(): Promise<bigint> {
  return await taskpool.execute(getVss_sync) as bigint;
}

export async function getSharedDirty(): Promise<bigint> {
  return await taskpool.execute(getSharedDirty_sync) as bigint;
}

export async function getPrivateDirty(): Promise<bigint> {
  return await taskpool.execute(getPrivateDirty_sync) as bigint;
}

export async function getVRAM(): Promise<number> {
  return await taskpool.execute(getGraphicsMemory_sync) as number;
}