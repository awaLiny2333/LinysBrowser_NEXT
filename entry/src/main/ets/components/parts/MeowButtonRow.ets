import { meowAvoid } from '../../catstypicalframework/hosts/meowAvoid';
import { meowUiStatuses } from '../../hosts/env/classes/meowUiStatuses';
import { defaultAnimation, standardSpacing, titleBarPositionBottom, useEffects } from '../settings';
import { MooSymbolButton } from '../common/MooSymbolButton';

@ComponentV2
export struct MeowButtonRow {
  @Param @Require myMeowAvoid: meowAvoid;
  @Param @Require myMeowUiStatuses: meowUiStatuses;

  build() {
    Row({ space: 1 }) {
      /**
       * TODO: More buttons.
       */
      MooSymbolButton({ icon: $r('sys.symbol.rectangle_stack') });
      MooSymbolButton({ icon: $r('sys.symbol.bookmark') });
      MooSymbolButton({ icon: $r('sys.symbol.download') });
      MooSymbolButton({ icon: $r('sys.symbol.gearshape') });
    }
    .width('100%')
    .justifyContent(FlexAlign.End)
    .padding({ left: this.myMeowAvoid.left, right: this.myMeowAvoid.right })
    .visibility(this.myMeowUiStatuses.showMore ? Visibility.Visible : Visibility.None)
    .animation(defaultAnimation());
  }

  constructPadding(): Padding {
    const l = this.myMeowAvoid.left;
    const r = this.myMeowAvoid.right;
    if (useEffects()) {
      if (titleBarPositionBottom()) {
        return { bottom: standardSpacing, left: l, right: r };
      } else {
        return { top: standardSpacing, left: l, right: r };
      }
    } else {
      if (titleBarPositionBottom()) {
        return { top: standardSpacing, left: l, right: r };
      } else {
        return { bottom: standardSpacing, left: l, right: r };
      }
    }
  }
}