import { meow, meowLevel } from '../../../../catstypicalframework/utils/catsLogger';
import { defaultInnerRadius } from '../../../../catstypicalframework/utils/ui';
import { meowHistorian } from '../../../../hosts/history/classes/meowHistorian';
import { meowHistoryEntry } from '../../../../hosts/history/classes/meowHistoryEntry';
import { UniContentCard } from '../../../common/UniContentCard';
import { SimpleHistoryShowcase } from './SimpleHistoryShowcase';
import { AppStorageV2 } from '@kit.ArkUI';
import { meowFlexOptions } from '../../../common/constants';

/**
 * History data and operations.
 */
@ComponentV2
struct HistoryDevCard {
  // App
  @Local myMeowHistorian: meowHistorian = AppStorageV2.connect<meowHistorian>(meowHistorian)!; // Should be initialized by flows.
  // Page stuffs
  @Local myTitle: string = 'Title of History entry!';
  @Local myUrl: string = 'https://meow.meow.org';
  @Local myTime: number = Date.now();
  @Local myDelete: number[] = [];
  @Local myHistoryChunk: meowHistoryEntry[] = [];

  build() {

    UniContentCard({ title: 'meowHistorian' }) {
      Flex(meowFlexOptions) {
        Text(`[Ready] ${this.myMeowHistorian.busy ? ' 󰁖 ' : ' 󰀓 '}`);
        Text(`[${this.myMeowHistorian.basePath}] (/history, /history-index)`);
        Text(`[Last Update] ${this.myMeowHistorian.lastUpdate} (${new Date(this.myMeowHistorian.lastUpdate).toLocaleString()})`);
      };

      TextInput({ placeholder: 'Title', text: this.myTitle })
        .onChange((c) => {
          this.myTitle = c;
        });
      TextInput({ placeholder: 'Url', text: this.myUrl })
        .onChange((c) => {
          this.myUrl = c;
        });

      Row({ space: 8 }) {
        TextInput({ placeholder: 'Time', text: this.myTime.toString() })
          .onChange((c) => {
            this.myTime = Number(c);
          })
          .layoutWeight(1);
        SymbolGlyph($r('sys.symbol.arrow_clockwise'))
          .onClick(() => {
            this.myTime = Date.now();
          })
          .padding(10)
          .fontSize(20)
          .aspectRatio(1)
          .height(40)
          .borderRadius(defaultInnerRadius)
          .hoverEffect(HoverEffect.Highlight)
          .fontColor([$r('sys.color.font')]);
      };


      Flex(meowFlexOptions) {
        Button('(Re)Build all')
          .onClick(() => {
            const startTime = Date.now();
            this.myMeowHistorian.rebuildIndex()
              .then(() => {
                meow(`Successfully built index for all chunks. (${Date.now() - startTime} ms)`, 'meowHistorian][buildAllChunkIndexConcurrent', meowLevel.INFO);
              })
              .catch((e: BusinessError) => {
                meow(`Error building index for all chunks: ${e}`, 'meowHistorian][buildAllChunkIndexConcurrent', meowLevel.ERROR);
              });
          });
        Button('Push (and rebuild month)')
          .onClick(() => {
            this.myMeowHistorian.pushHistory(new meowHistoryEntry(this.myTitle, this.myUrl, this.myTime));
          });
        Text('  ' + new Date(this.myTime).toLocaleString());
      }; // timestamp input and push button

      Flex(meowFlexOptions) {
        Button('Delete →')
          .onClick(() => {
            this.myMeowHistorian.deleteHistory(this.myDelete);
            this.myDelete = [];
          });
        SymbolGlyph($r('sys.symbol.clean'))
          .onClick(() => {
            this.myDelete = [];
          })
          .padding(10)
          .fontSize(20)
          .aspectRatio(1)
          .height(40)
          .borderRadius(defaultInnerRadius)
          .hoverEffect(HoverEffect.Highlight)
          .fontColor([$r('sys.color.font')]);
        Text(`Selected: ${this.myDelete.toString()}`)
          .layoutWeight(1);
      }; // Delete

      SimpleHistoryShowcase({
        onDeleteClickActions: (hist: meowHistoryEntry) => {
          // Delete candidate
          this.myDelete.push(hist.time);
        },
      });
    }; // History

  }
}

export { HistoryDevCard };