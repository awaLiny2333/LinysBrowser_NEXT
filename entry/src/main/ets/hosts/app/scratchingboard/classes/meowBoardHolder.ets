import { unifiedDataChannel } from '@kit.ArkData';
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
}
