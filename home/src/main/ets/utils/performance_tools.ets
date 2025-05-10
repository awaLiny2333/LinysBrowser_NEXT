import { hidebug } from '@kit.PerformanceAnalysisKit';

@Concurrent
export function getPss_sync(): bigint {
  return hidebug.getPss();
}

@Concurrent
export function getVss_sync(): bigint {
  return hidebug.getVss();
}

@Concurrent
export function getCPU_sync(): number {
  return hidebug.getCpuUsage();
}

@Concurrent
export function getSharedDirty_sync(): bigint {
  return hidebug.getSharedDirty();
}

@Concurrent
export function getPrivateDirty_sync(): bigint {
  return hidebug.getPrivateDirty();
}

@Concurrent
export function getNativeHeapSize_sync(): bigint {
  return hidebug.getNativeHeapSize();
}

@Concurrent
export function getGraphicsMemory_sync(): number {
  return hidebug.getGraphicsMemorySync();
}
