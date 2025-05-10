import { get_folder_size_Sync } from './storage_tools';
import { taskpool } from '@kit.ArkTS';
import {
  getGraphicsMemory_sync,
  getPrivateDirty_sync, getPss_sync, getSharedDirty_sync, getVss_sync } from './performance_tools';

@Concurrent
function get_web_cache_size_concurrent(): number {
  return get_folder_size_Sync('/data/storage/el2/base/cache/web/', true);
}

export async function get_web_cache_size(): Promise<number> {
  return await taskpool.execute(get_web_cache_size_concurrent) as number;
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