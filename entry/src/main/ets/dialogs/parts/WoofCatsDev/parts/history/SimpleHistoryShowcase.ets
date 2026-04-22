import { defaultInnerRadius, defaultMenuItemRadius } from '../../../../../catstypicalframework/utils/ui';
import { meowHistorian } from '../../../../../hosts/userdata/history/classes/meowHistorian';
import { AppStorageV2 } from '@kit.ArkUI';
import { meowHistoryChunk } from '../../../../../hosts/userdata/history/classes/meowHistoryChunk';
import { meowHistoryEntry } from '../../../../../hosts/userdata/history/classes/meowHistoryEntry';
import { UniContentCard } from '../../../../../components/common/UniContentCard';
import { meowFlexOptions } from '../../../../../components/settings';

/**
 * A simple history showcase component. Includes history entries of all different months and a request field to search for history.
 */
@ComponentV2
struct SimpleHistoryShowcase {
  @Local myHistoryChunk: meowHistoryChunk | undefined;
  @Local myHistoryChunkEntries: meowHistoryEntry[] = [];
  @Local myMeowHistorian: meowHistorian = AppStorageV2.connect<meowHistorian>(meowHistorian)!; // Should be initialized by flow.
  @Local requestKey: string = ''; // The key to seearch in current month's index.
  @Local requestResult: meowHistoryEntry[] = [];
  @Local requestTime: number = -1;
  // Actions
  @Event onClickActions: (history: meowHistoryEntry) => void;
  @Event onDeleteClickActions: (history: meowHistoryEntry) => void;

  build() {
    UniContentCard({ roundedRadius: defaultInnerRadius }) {
      Text(`[Entries] of ${this.myHistoryChunk?.year}-${this.myHistoryChunk?.month} (${this.myHistoryChunkEntries.length})`);

      List() {
        Repeat(this.myHistoryChunkEntries)
          .each((obj: RepeatItem<meowHistoryEntry>) => {
            Flex(meowFlexOptions) {
              SymbolGlyph($r('sys.symbol.xmark'))
                .fontSize(20)
                .opacity(0.7)
                .onClick(() => {
                  this.onDeleteClickActions(obj.item);
                })
                .padding(3)
                .borderRadius(defaultMenuItemRadius)
                .hoverEffect(HoverEffect.Highlight)
                .fontColor([$r('sys.color.font')]);
              Text(`${obj.item.title}`)
                .fontWeight(FontWeight.Medium)
                .wordBreak(WordBreak.BREAK_ALL)
                .maxLines(1);
              Text(`${new Date(obj.item.time)
                .toLocaleString()} (${obj.item.time})`)
                .fontWeight(FontWeight.Medium)
                .opacity(0.7);
              Text(`${obj.item.url}`)
                .wordBreak(WordBreak.BREAK_ALL)
                .maxLines(1)
                .opacity(0.7);
            }
            .onClick(() => {
              this.onClickActions(obj.item);
            })
            .padding(8)
            .borderRadius(defaultInnerRadius)
            .hoverEffect(HoverEffect.Highlight);
          })
          .key((obj: meowHistoryEntry) => {
            return obj.time.toString();
          })
          .virtualScroll();
        if (this.myHistoryChunkEntries.length == 0) {
          ListItem() {
            Text('No history found. ヽ（´ー｀）┌')
              .fontWeight(FontWeight.Medium)
              .opacity(0.7)
              .padding(8)
              .borderRadius(defaultInnerRadius)
              .hoverEffect(HoverEffect.Highlight);
          };
        }
      }
      .listDirection(Axis.Vertical)
      .height(200)
      .width('100%');

      List() {
        Repeat(this.myMeowHistorian.getChunks())
          .each((obj: RepeatItem<meowHistoryChunk>) => {
            Text(`${obj.item.year}-${obj.item.month}`)
              .padding(8)
              .borderRadius(defaultInnerRadius)
              .hoverEffect(HoverEffect.Highlight)
              .fontWeight(FontWeight.Bold)
              .onClick(async () => {
                this.myHistoryChunk = this.myMeowHistorian.getChunk(obj.index);
                this.myHistoryChunkEntries = await this.myMeowHistorian.getHistoryEntries(obj.index);
                await this.request();
              });
          })
          .virtualScroll();
      }
      .listDirection(Axis.Horizontal)
      .height(35)
      .width('100%');

      TextInput({ placeholder: 'Request Key' })
        .onChange(async (value: string) => {
          this.requestKey = value;
          await this.request();
        })
        .onSubmit(async () => {
          await this.request();
        });
      Text(`[Result] of ${this.requestKey} (${this.requestResult.length}) (${this.requestTime} ms):${'\n\n'}${this.requestResult.join(',\n\n')}`);
    };
  }

  async request() {
    const startTime = Date.now();
    this.requestResult = await this.myMeowHistorian.lookUpHistoryEntries(this.requestKey, 20) ?? [];
    this.requestTime = Date.now() - startTime;
  }
}

export { SimpleHistoryShowcase };