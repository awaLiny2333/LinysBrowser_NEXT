import { hidebug } from '@kit.PerformanceAnalysisKit';

export function get_RAM_sync(): bigint {
  return hidebug.getPss();
}