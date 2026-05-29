import { getPss_sync, getVss_sync, getSharedDirty_sync, getPrivateDirty_sync, getGraphicsMemory_sync, getCPU_sync, getNativeHeapSize_sync } from "./funcSync";
import { taskpool } from "@kit.ArkTS";
import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";

/**
 * Get the process's CPU usage.
 * @returns The CPU usage.
 */
export async function getCPU(): Promise<number> {
  return getCPU_sync();
}

/**
 * Get the process's VRAM (Graphics Memory, gl + graph) in Bytes.
 * @returns The VRAM in Bytes.
 */
export async function getVRAM(): Promise<number> {
  try {
    return await taskpool.execute(getGraphicsMemory_sync) as number * 1000;
  } catch (e) {
    meow(`taskpool.execute(getGraphicsMemory_sync); failed: ${e}`, `getVRAM`, meowLevel.ERROR);
    return 0;
  }
}

/**
 * Get the process's PSS (Physical Set Size) in Bytes.
 * @returns The PSS in Bytes.
 */
export async function getPss(): Promise<bigint> {
  try {
    return await taskpool.execute(getPss_sync) as bigint * 1000n;
  } catch (e) {
    meow(`taskpool.execute(getPss_sync); failed: ${e}`, `getPss`, meowLevel.ERROR);
    return 0n;
  }
}

/**
 * Get the process's VSS (Virtual Set Size) in Bytes.
 * @returns The VSS in Bytes.
 */
export async function getVss(): Promise<bigint> {
  try {
    return await taskpool.execute(getVss_sync) as bigint * 1000n;
  } catch (e) {
    meow(`taskpool.execute(getVss_sync); failed: ${e}`, `getVss`, meowLevel.ERROR);
    return 0n;
  }
}

/**
 * Get the process's native heap size in Bytes.
 * @returns The native heap size in Bytes.
 */
export async function getNativeHeapSize(): Promise<bigint> {
  return getNativeHeapSize_sync();
}

/**
 * Get the process's shared dirty size in Bytes.
 * @returns The shared dirty size in Bytes.
 */
export async function getSharedDirty(): Promise<bigint> {
  try {
    return await taskpool.execute(getSharedDirty_sync) as bigint * 1000n;
  } catch (e) {
    meow(`taskpool.execute(getSharedDirty_sync); failed: ${e}`, `getSharedDirty`, meowLevel.ERROR);
    return 0n;
  }
}

/**
 * Get the process's private dirty size in Bytes.
 * @returns The private dirty size in Bytes.
 */
export async function getPrivateDirty(): Promise<bigint> {
  try {
    return await taskpool.execute(getPrivateDirty_sync) as bigint * 1000n;
  } catch (e) {
    meow(`taskpool.execute(getPrivateDirty_sync); failed: ${e}`, `getPrivateDirty`, meowLevel.ERROR);
    return 0n;
  }
}
