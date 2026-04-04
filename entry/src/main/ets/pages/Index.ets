import { defaultRoundedRadius, meowAvoid, meowFreeWindowModeStatus, meowLayoutModeStatus } from '../catstypicalframework/utils/ui';
import { AppStorageV2 } from '@kit.ArkUI';
import { meowMisc } from '../catstypicalframework/hosts/meowMisc';
import { CatsDevControls } from '../components/developers/CatsDevControls';
import { meow, meowLevel } from '../catstypicalframework/utils/catsLogger';

@Entry
@ComponentV2
struct Index {
  // catsTypicalFramework
  @Local myMeowLayout: meowLayoutModeStatus = AppStorageV2.connect<meowLayoutModeStatus>(meowLayoutModeStatus)!;
  @Local myMeowFreeWindowModeStatus: meowFreeWindowModeStatus = AppStorageV2.connect<meowFreeWindowModeStatus>(meowFreeWindowModeStatus)!;
  @Local myMeowAvoid: meowAvoid = AppStorageV2.connect<meowAvoid>(meowAvoid)!;
  @Local myMeowMisc: meowMisc = AppStorageV2.connect<meowMisc>(meowMisc)!;
  // Runtime
  context: Context = this.getUIContext().getHostContext()!;
  // Render control
  @Local render: boolean = false;

  build() {
    Stack() {
      if (this.render) {
        Row() {
          Scroll() {
            CatsDevControls();
          }
          .border({ radius: defaultRoundedRadius })
          .clip(true)
          .scrollable(ScrollDirection.Vertical)
          .edgeEffect(EdgeEffect.Spring);
        } // Contents
        .alignItems(VerticalAlign.Top)
        .height('100%')
        .width('100%')
        .padding(this.myMeowAvoid);

        if (this.myMeowFreeWindowModeStatus.on || this.myMeowLayout.wideMode) {
          Text($r('app.string.EntryAbility_label'))
            .padding(10);
        } // Title
      }

    } // Base
    .alignContent(Alignment.Top)
    .useEffect(this.myMeowFreeWindowModeStatus.on, EffectType.WINDOW_EFFECT)
    .height('100%')
    .width('100%')
    .onAppear(() => {
      this.myMeowMisc.launchEndTime = Date.now();
      meow(`---`, 'Index][launch', meowLevel.INFO);
      meow(`Successfully launched the app. (${Date.now() - this.myMeowMisc.launchStartTime} ms)`, 'Index][launch', meowLevel.INFO);
      meow(`---`, 'Index][launch', meowLevel.INFO);
      setTimeout(() => {
        this.render = true;
      }, 1);
    })
    .onAreaChange((o, n) => {
      if (o.width != n.width) {
        this.myMeowLayout.width = n.width as number;
        this.myMeowLayout.wideMode = this.myMeowLayout.width > 900;
      }
      if (o.height != n.height) {
        this.myMeowLayout.height = n.height as number;
      }
    });
  }
}