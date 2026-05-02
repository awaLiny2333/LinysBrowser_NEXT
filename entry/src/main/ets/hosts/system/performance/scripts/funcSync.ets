import lazy { hidebug } from '@kit.PerformanceAnalysisKit';
import lazy { meow, meowLevel } from '../../../../catstypicalframework/utils/catsLogger';

@Concurrent
export function getCPU_sync(): number {
  return hidebug.getCpuUsage();
}

@Concurrent
export function getGraphicsMemory_sync(): number {
  try {
    return hidebug.getGraphicsMemorySync();
  } catch (e) {
    meow(`hidebug.getGraphicsMemorySync(); failed: ${e}`, `getGraphicsMemory_sync`, meowLevel.ERROR);
    return 0;
  }
}

@Concurrent
export function getPss_sync(): bigint {
  return hidebug.getPss();
}

@Concurrent
export function getVss_sync(): bigint {
  return hidebug.getVss();
}

@Concurrent
export function getNativeHeapSize_sync(): bigint {
  return hidebug.getNativeHeapSize();
}

@Concurrent
export function getSharedDirty_sync(): bigint {
  return hidebug.getSharedDirty();
}

@Concurrent
export function getPrivateDirty_sync(): bigint {
  return hidebug.getPrivateDirty();
}
