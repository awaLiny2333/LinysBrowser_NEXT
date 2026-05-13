import { unifiedDataChannel } from '@kit.ArkData';
import { unifiedRecord2BoardData } from '../scripts/helpers';

export enum MeowScratchingBoardDataType {
  TEXT = 'TXT',
  URL = 'URL',
  IMAGE = 'IMG'
}

export interface MeowScratchingBoardData {
  type: MeowScratchingBoardDataType;
  content: string; // May be the text, the url or the url to the image
}

@ObservedV2
export class meowBoardHolder {
  @Trace records: MeowScratchingBoardData[] = [];

  addEntries(records: unifiedDataChannel.UnifiedRecord[], tempDir: string) {
    const newRecords: MeowScratchingBoardData[] = unifiedRecord2BoardData(records, true, tempDir);
    this.records.push(...newRecords);
  }
}
