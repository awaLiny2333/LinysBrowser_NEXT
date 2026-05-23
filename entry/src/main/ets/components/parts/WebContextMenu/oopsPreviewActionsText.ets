import { copyText } from '../../../catstypicalframework/utils/clipboard';
import { isLegalUrl, jumpUrl } from '../../../catstypicalframework/utils/url';
import { concatSearchWithEngine } from '../../../hosts/app/tabs/scripts/searchEngines';
import { MooSymbolButton } from '../../common/MooSymbolButton';

@ComponentV2
export struct oopsPreviewActionsText {
  // Params
  @Param @Require content: string;
  @Local visitable: boolean = isLegalUrl(this.content)[0];
  // Events
  @Event requestCloseMenu: () => void;
  @Event requestVisit: (reqUrl: string) => void;

  build() {
    Scroll() {
      Row() {
        MooSymbolButton({
          icon: $r('sys.symbol.plus_square_on_square'), clickAction: () => {
            copyText(this.content);
            this.requestCloseMenu();
          }
        }); // Copy
        MooSymbolButton({
          icon: $r('sys.symbol.arrow_up_right'), clickAction: () => {
            this.requestVisit(this.content);
            this.requestCloseMenu();
          }, isEnabled: this.visitable
        }); // Visit
        MooSymbolButton({
          icon: $r('sys.symbol.magnifyingglass'), clickAction: () => {
            const result = concatSearchWithEngine(this.content).result;
            if (result) this.requestVisit(result);
            this.requestCloseMenu();
          }
        }); // Search with default engine
        MooSymbolButton({
          icon: $r('sys.symbol.bookmark_book_closed'), clickAction: () => {
            let link: string = 'dictionary://' + this.content;
            try {
              jumpUrl(link);
            } catch (e) {
              console.error(`[linysPreviewTextActions] Search ${link} in dictionary openlink failed: ${e}`);
            }
            this.requestCloseMenu();
          }
        }); // Search in dictionary
        // MooSymbolButton({
        //   icon: $r('sys.symbol.share'), clickAction: () => {
        //     // TODO: share text.
        //   }
        // }); // Share
      }; // Buttons
    }
    .scrollBar(BarState.Off)
    .scrollable(ScrollDirection.Horizontal)
    .edgeEffect(EdgeEffect.Spring);
  }
}
