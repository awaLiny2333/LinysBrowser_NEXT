import { meowAvoid } from '../../../catstypicalframework/hosts/meowAvoid';
import { MooSymbolButton } from '../../common/MooSymbolButton';
import { standardSpacing, titleBarPositionBottom, useEffects } from '../../settings';

@ComponentV2
export struct MeowButtonRow {
  @Param @Require myAvoid: meowAvoid;

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
    .padding({ left: this.myAvoid.left, right: this.myAvoid.right })
  }

  constructPadding(): Padding {
    const l = this.myAvoid.left;
    const r = this.myAvoid.right;
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