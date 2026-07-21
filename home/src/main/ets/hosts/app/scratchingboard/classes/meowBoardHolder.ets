import { unifiedDataChannel } from '@kit.ArkData';
import { defaultAnimation } from '../../../../components/settings';
import lazy { unifiedRecord2BoardData } from '../scripts/data';

export enum MeowScratchingBoardDataType {
  TEXT = 'TXT',
  URL = 'URL',
  IMAGE = 'IMG'
}

@ObservedV2
export class MeowScratchingBoardData {
  @Trace type: MeowScratchingBoardDataType;
  @Trace textContent: string; // The text for TEXT; The url for URL; The file name for IMAGE.
  @Trace extraContent: string; // Empty for TEXT & URL; The file extension name for IMAGE.
  @Trace payload: object | undefined; // Empty for TEXT & URL; [ArrayBuffer, image.PixelMap, copiedFilePath: string, image.ImageInfo] for IMAGE.

  constructor(type: MeowScratchingBoardDataType, content: string, extra?: string, payload?: object) {
    this.type = type;
    this.textContent = content;
    this.extraContent = extra || '';
    this.payload = payload;
  }
}

@ObservedV2
export class meowBoardHolder {
  @Trace records: MeowScratchingBoardData[] = [];

  async addEntries(records: unifiedDataChannel.UnifiedRecord[], imgTempDir: string) {
    const newRecords: MeowScratchingBoardData[] = await unifiedRecord2BoardData(records, true, imgTempDir);
    this.records.unshift(...newRecords);
  }

  /**
   * Clears everything in the board. Releases all pixelMaps.
   * @author DeepSeek Web @ Jul 21 2026.
   */
  async clearBoard(): Promise<void> {
    // 显式声明为 Promise<void>[]，通过条件过滤掉所有非法的项
    const releaseTasks: Promise<void>[] = [];
    for (const rec of this.records) {
      if (rec.type === MeowScratchingBoardDataType.IMAGE && rec.payload?.[1]?.release) {
        // 这里确保 release 存在，push 的必定是 Promise<void>
        releaseTasks.push(rec.payload[1].release());
      }
    }

    await Promise.allSettled(releaseTasks);

    animateToImmediately(defaultAnimation(), () => {
      this.records = [];
    });
  }
}
