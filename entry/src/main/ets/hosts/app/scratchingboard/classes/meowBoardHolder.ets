import { unifiedDataChannel } from '@kit.ArkData';
import { unifiedRecord2BoardData } from '../scripts/data';

export enum MeowScratchingBoardDataType {
  TEXT = 'TXT',
  URL = 'URL',
  IMAGE = 'IMG'
}

@ObservedV2
export class MeowScratchingBoardData {
  @Trace type: MeowScratchingBoardDataType;
  @Trace textContent: string; // May be the text, the url or the url to the image
  @Trace extraContent: string; // e.g. the image file extension
  @Trace payload: object | undefined;

  constructor(type: MeowScratchingBoardDataType, content: string, extra?: string) {
    this.type = type;
    this.textContent = content;
    this.extraContent = extra || '';
  }
}

@ObservedV2
export class meowBoardHolder {
  @Trace records: MeowScratchingBoardData[] = [];

  addEntries(records: unifiedDataChannel.UnifiedRecord[]) {
    const newRecords: MeowScratchingBoardData[] = unifiedRecord2BoardData(records, true);
    this.records.unshift(...newRecords);
  }
}
