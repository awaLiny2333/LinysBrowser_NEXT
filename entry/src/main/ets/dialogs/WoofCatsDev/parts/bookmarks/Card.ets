import { UniContentCard } from '../../../../components/common/UniContentCard';
import { AppStorageV2 } from '@kit.ArkUI';
import { meowFlexOptions } from '../../../../components/settings';
import { meowBookmarkStash } from '../../../../hosts/userdata/bookmarks/classes/meowBookmarkStash';
import { SimpleBookmarksShowcase } from './SimpleBookmarksShowcase';

/**
 * meowBookmarkStash stuffs.
 */
@ComponentV2
struct BookmarksDevCard {
  @Local myMeowBookmarkStash: meowBookmarkStash = AppStorageV2.connect(meowBookmarkStash)!;
  @Local updateFlag: boolean = false;

  build() {
    UniContentCard({ title: 'meowBookmarkStash' }) {
      Text(`[defaultBookmarksPath] ${this.myMeowBookmarkStash.defaultBookmarksPath}`);
      Flex(meowFlexOptions) {
        Text(`[lastImportTimeCost] ${this.myMeowBookmarkStash.lastImportTimeCost} ms`);
        Text(`[lastSaveTimeCost] ${this.myMeowBookmarkStash.lastSaveTimeCost} ms`);
        Text(`[timeoutIdSaveToDisk] ${this.myMeowBookmarkStash.timeoutIdSaveToDisk}`);
      };

      Flex(meowFlexOptions) {
        Button('Request Save To Disk')
          .onClick(() => {
            this.myMeowBookmarkStash.requestSaveToDisk();
          });
        Button('Import From HTML')
          .onClick(async () => {
            const result = await this.myMeowBookmarkStash.importHTMLfromDocuments();
            if (result) {
              this.updateFlag = !this.updateFlag;
            }
          });
        Button('Export To HTML')
          .onClick(() => {
            this.myMeowBookmarkStash.exportHTMLtoDocuments();
          });
      };
      
      SimpleBookmarksShowcase({
        updateFlag: this.updateFlag,
        folder: this.myMeowBookmarkStash.root,
        saveAction: () => {
          this.myMeowBookmarkStash.requestSaveToDisk();
        }
      });
    };
  }
}

export { BookmarksDevCard };
