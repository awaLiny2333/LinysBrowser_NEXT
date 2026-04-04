import { defaultInnerRadius, defaultRoundedRadius, meowAvoid, meowFreeWindowModeStatus, meowLayoutModeStatus } from '../../catstypicalframework/utils/ui';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { meowMisc } from '../../catstypicalframework/hosts/meowMisc';
import { meow, meowLevel } from '../../catstypicalframework/utils/catsLogger';
import { SimpleHistoryShowcase } from './history/SimpleHistoryShowcase';
import { meowHistorian } from '../../hosts/history/classes/meowHistorian';
import { meowHistoryEntry } from '../../hosts/history/classes/meowHistoryEntry';
import { meowManagedSettings } from '../../hosts/settings/classes/meowManagedSettings';
import { SimpleSettingsExamples } from './settings/SimpleSettingsExamples';

@ComponentV2
struct CatsDevControls {
  // Environment
  context: Context = this.getUIContext().getHostContext()!;
  // catsTypicalFramework
  @Local myMeowLayout: meowLayoutModeStatus = AppStorageV2.connect<meowLayoutModeStatus>(meowLayoutModeStatus)!;
  @Local myMeowFreeWindowModeStatus: meowFreeWindowModeStatus = AppStorageV2.connect<meowFreeWindowModeStatus>(meowFreeWindowModeStatus)!;
  @Local myMeowAvoid: meowAvoid = AppStorageV2.connect<meowAvoid>(meowAvoid)!;
  @Local myMeowMisc: meowMisc = AppStorageV2.connect<meowMisc>(meowMisc)!;
  @Local myMeowHistorian: meowHistorian = AppStorageV2.connect<meowHistorian>(meowHistorian)!; // Should be initialized by flows.
  @Local myMeowManagedSettings: meowManagedSettings = AppStorageV2.connect<meowManagedSettings>(meowManagedSettings)!; // Should be initialized by flows.
  // Page stuffs
  @Local myTitle: string = 'Title of History entry!';
  @Local myUrl: string = 'https://meow.meow.org';
  @Local myTime: number = Date.now();
  @Local myDelete: number[] = [];
  @Local myHistoryChunk: meowHistoryEntry[] = [];

  build() {
    Column({ space: 5 }) {
      uniContentCard({ title: 'Underlying Stuffs' }) {
        Text(`[launchTimeUsage] ${this.myMeowMisc.launchEndTime - this.myMeowMisc.launchStartTime} ms`);
      }; // Underlying stuffs

      uniContentCard({ title: 'Layout (CatsTypicalFramework)' }) {
        Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
          Button('Toggle myMeowFreeWindowModeStatus.on')
            .onClick(() => {
              this.myMeowFreeWindowModeStatus.on = !this.myMeowFreeWindowModeStatus.on;
            })
            .margin({ bottom: 5 });

          Button('Toggle myMeowLayout.wideMode')
            .onClick(() => {
              this.myMeowLayout.wideMode = !this.myMeowLayout.wideMode;
            })
            .margin({ bottom: 5 });
        };

        Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(5), cross: LengthMetrics.vp(8) } }) {
          Text(`[Free Window Mode] ${this.myMeowFreeWindowModeStatus.on ? ' 󰀓 ' : ' 󰁖 '}`);
          Text(`[Wide / Tablet Mode] ${this.myMeowLayout.wideMode ? ' 󰀓 ' : ' 󰁖 '}`);
          Text(`[Avoids]  ↑${this.myMeowAvoid.top}  ↓${this.myMeowAvoid.bottom}  ←${this.myMeowAvoid.left}  →${this.myMeowAvoid.right}`);
        };
      }; // Typical Cats Framework layouts

      uniContentCard({ title: 'meowManagedSettings' }) {
        Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(5), cross: LengthMetrics.vp(8) } }) {
          Text(`[Ready] ${this.myMeowManagedSettings.ready ? ' 󰀓 ' : ' 󰁖 '}`);
          Text(`[${this.myMeowManagedSettings.settingsFileSavePath}]`);
          Text(`[timeoutIdSaveToDisk] ${this.myMeowManagedSettings.timeoutIdSaveToDisk}`);
        }; // Statuses

        Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
          Button('(Re) Load from Disk')
            .onClick(() => {
              this.myMeowManagedSettings?.initFrom(`${this.context.filesDir}/settings.json.browsercatsettings.txt`);
            });
          Button('Save Instantly')
            .onClick(() => {
              this.myMeowManagedSettings.requestSaveToDisk(0);
            });
          Button('Save Through Request in 500 ms')
            .onClick(() => {
              this.myMeowManagedSettings.requestSaveToDisk();
            });
        }; // Load and save buttons

        TextArea({ text: `${this.myMeowManagedSettings.prebuiltReadOnly}` }).height(200); // Settings file

        SimpleSettingsExamples();
      }; // Settings

      uniContentCard({ title: 'meowHistorian' }) {
        Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(5), cross: LengthMetrics.vp(8) } }) {
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


        Row({ space: 8 }) {
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

        Row({ space: 5 }) {
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
    .alignItems(HorizontalAlign.Start)
    .width('100%');
  }
}

@ComponentV2
struct uniContentCard {
  @BuilderParam contentsBuilder: () => void;
  @Param title: ResourceStr = '';
  @Param roundedRadius: number = defaultRoundedRadius;

  build() {
    Column({ space: 8 }) {
      if (this.title) {
        Text(this.title)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .padding({ bottom: 3 });
      }

      this.contentsBuilder();
    }
    .width('100%')
    .backgroundEffect({ color: $r('app.color.blur_background'), radius: 20 })
    .border({ radius: this.roundedRadius, width: 1, color: $r('sys.color.icon_fourth') })
    .padding(12)
    .alignItems(HorizontalAlign.Start);
  }
}

export { CatsDevControls, uniContentCard };