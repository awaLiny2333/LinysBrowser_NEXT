import { meowLayout } from '../../../../catstypicalframework/hosts/meowLayout';
import { defaultInnerRadius } from '../../../../catstypicalframework/utils/ui';
import { MooTextButton } from '../../../../components/common/MooTextButton';
import { MooTextModifier } from '../../../../components/common/MooTextModifier';
import { defaultAnimation, getColor, isPreferRightHand, meowThemeColorType, mooTextType, standardSpacing, useEffects } from '../../../../components/settings';
import { meowHistoryEntry } from '../../../../hosts/userdata/history/classes/meowHistoryEntry';
import { HistoryEntryButton } from './HistoryEntryButton';

@ComponentV2
struct DayCard {
  // Host
  @Param @Require myLayout: meowLayout;
  // Params
  @Param @Require obj: meowHistoryEntry[];
  @Param @Require isSelecting: boolean;
  @Param @Require selectedTimeStamps: Set<number>;
  // Local
  @Local showFull: boolean = this.obj.length <= 5;
  // Events
  @Event requestVisit: (url: string) => void;

  @Monitor('obj')
  onObjChange() {
    this.showFull = this.obj.length <= 5;
  }

  build() {
    Column({ space: standardSpacing * 0.5 }) {
      Row() {
        // Title
        Text(`${new Date(this.obj[0].time).toLocaleDateString()} (${this.obj.length})`)
          .attributeModifier(new MooTextModifier(mooTextType.TITLE))
          .padding(standardSpacing * 0.75)
          .opacity(this.showFull ? 0.75 : 0.5)
          .layoutWeight(1);

        // Hide button
        if (this.obj.length > 5) {
          MooTextButton({
            text: this.showFull ? $r('app.string.General_collapse') : $r('app.string.General_expand'),
            clickAction: () => {
              animateToImmediately(defaultAnimation(), () => {
                this.showFull = !this.showFull;
              });
            }
          });
        }
      }.direction(isPreferRightHand() ? Direction.Ltr : Direction.Rtl);

      List() {
        Repeat(this.obj)
          .each((obj: RepeatItem<meowHistoryEntry>) => {
            HistoryEntryButton({
              myLayout: this.myLayout,
              item: obj.item,
              isSelecting: this.isSelecting,
              isSelected: this.selectedTimeStamps.has(obj.item.time),
              clickAction: () => {
                if (!this.isSelecting) {
                  // Request visit
                  this.requestVisit(obj.item.url);
                  return;
                }

                // Select / Deselect
                if (this.selectedTimeStamps.has(obj.item.time)) {
                  this.selectedTimeStamps.delete(obj.item.time);
                } else {
                  this.selectedTimeStamps.add(obj.item.time);
                }
              }
            }).opacity(this.showFull ? 1 : 0.75);
          })
          .virtualScroll();
      }
      .scrollBar(BarState.Off)
      .enableScrollInteraction(this.showFull)
      .backgroundColor(useEffects() ? getColor(meowThemeColorType.PRIMARY) : getColor(meowThemeColorType.SECONDARY))
      .border({ radius: defaultInnerRadius, width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth') })
      .padding(standardSpacing * 0.75)
      .nestedScroll({ scrollForward: NestedScrollMode.SELF_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })
      .height('auto')
      .constraintSize(this.showFull ? { maxHeight: undefined } : { maxHeight: Math.max(Math.min(this.myLayout.height * 0.125, 168), 40) }) // Prevent lag. As if we don't limit the height, all items would be rendered at once as they are thought to be visible!
      .width('100%');
    }
    .alignItems(HorizontalAlign.Start);
  }
}

export { DayCard };
