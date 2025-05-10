import { get_folder_size_Sync } from "./storage_tools";
import { taskpool } from "@kit.ArkTS";
import { get_RAM_sync } from "./performance_tools";

@Concurrent
function get_web_cache_size_concurrent(): number {
  return get_folder_size_Sync('/data/storage/el2/base/cache/web/', true);
}

export async function get_web_cache_size(): Promise<number> {
  return await taskpool.execute(get_web_cache_size_concurrent) as number;
}

@Concurrent
function get_RAM_concurrent(): bigint {
  return get_RAM_sync();
}

export async function get_RAM(): Promise<number> {
  return await taskpool.execute(get_RAM_concurrent) as number;
}