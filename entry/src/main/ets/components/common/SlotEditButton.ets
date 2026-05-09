import { AppStorageV2 } from '@kit.ArkUI';
import { getRandomEmoticon } from '../../catstypicalframework/utils/meow';
import { defaultInnerRadius } from '../../catstypicalframework/utils/ui';
import mooMenuButton from './MooMenuButton';
import { MooSymbolButton } from './MooSymbolButton';
import { MooTextInputV2 } from './MooTextInputV2';
import { MooTextModifier } from './MooTextModifier';
import { defaultMooSymbolSize, getButtonIcon } from './constants';
import { defaultAnimation, getColor, meowThemeColorType, standardSpacing, useEffects } from '../settings';
import { meowUiHost } from '../../hosts/system/windows/classes/meowUiHost';
import { meowManagedSettings } from '../../hosts/userdata/settings/classes/meowManagedSettings';

/**
 * An edit button that has two modes (isEditing?)
 *
 * When isEditing is off, it's a normal button.
 * When isEditing is on, clicks on it would call a menu to delete it.
 *
 * This is also used in sidebar editing.
 * @see entry/src/main/ets/components/parts/Sidebar/MeowSidebar.ets
 */
@ComponentV2
struct SlotEditButton {
  // Params
  @Param @Require isEditing: boolean;
  @Param @Require type: string;
  @Param @Require hasParam: boolean; // Params for each button. like the links for some buttons to open a web page in the side bar.
  @Param @Once paramIconId: string | undefined = undefined;
  @Param @Once param: string = '';
  // Hosts
  @Param myUi: meowUiHost | undefined = undefined;
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
  // Local
  @Local isMenu: boolean = false;
  @Local isSelectingIcon: boolean = this.paramIconId !== undefined;
  @Local menuSubmitted: boolean = false; // This is purely for animation :P
  // Events
  @Event myOnHold: () => boolean = () => {
    return false;
  };
  /**
   * Triggered if not editing!
   */
  @Event clickAction: () => void;
  @Event requestDelete: () => void;
  @Event editParamSubmit: (result: string) => void;
  @Event editParamIconIdSubmit: (result: string) => void;

  build() {
    MooSymbolButton({
      icon: this.myIcon,
      onHold: this.myOnHold(),
      clickAction: () => {
        if (this.isEditing) {
          if (!this.isMenu) {
            this.menuSubmitted = false;
          }
          this.isMenu = !this.isMenu;
        } else {
          this.clickAction();
        }
      }
    })
      .bindContextMenu(this.isMenu && this.isEditing, this.contextMenuBuilder(), {
        aboutToDisappear: () => {
          this.isMenu = false;
        },
        backgroundColor: useEffects() ? undefined : getColor(meowThemeColorType.PRIMARY)
      });
  }

  @Builder
  contextMenuBuilder() {
    Column({ space: standardSpacing * 0.5 }) {
      if (this.menuSubmitted) {
        Text(`󰀓 ${getRandomEmoticon()}`).attributeModifier(new MooTextModifier()).padding(standardSpacing);
      } else {
        mooMenuButton({
          text: $r('app.string.General_delete'),
          clickAction: () => {
            this.isMenu = false;
            setTimeout(() => {
              this.requestDelete();
            }, 1);
          }
        });
        if (this.hasParam) {
          // Icon array
          if (this.isSelectingIcon) {
            Flex({ wrap: FlexWrap.Wrap }) {
              Repeat(symbolIconOptions)
                .each((item) => {
                  MooSymbolButton({
                    icon: $r('sys.symbol.'.concat(item.item)),
                    clickAction: () => {
                      animateToImmediately(defaultAnimation(), () => {
                        this.paramIconId = item.item;
                      });
                      this.editParamIconIdSubmit(this.paramIconId || 'link');
                    }
                  });
                });
            }
            .constraintSize({ maxWidth: 10 * defaultMooSymbolSize + standardSpacing })
            .padding(standardSpacing * 0.5)
            .backgroundColor(getColor(meowThemeColorType.SECONDARY))
            .border({ radius: defaultInnerRadius, width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth') });

            MooTextInputV2({
              text: this.paramIconId,
              icon: $r('sys.symbol.rename'),
              placeholder: '󰊄',
              autoLength: true,
              onChange: (value) => {
                this.paramIconId = value;
              },
              onSubmit: () => {
                this.editParamIconIdSubmit(this.paramIconId || 'link');
              }
            })
              .padding({ left: standardSpacing * 0.5 });
          }

          // Param edit
          Row({ space: standardSpacing * 0.5 }) {
            MooSymbolButton({
              icon: this.myIcon,
              clickAction: () => {
                animateToImmediately(defaultAnimation(), () => {
                  this.isSelectingIcon = !this.isSelectingIcon;
                });
              }
            });
            MooTextInputV2({
              text: this.param,
              placeholder: '󰁫',
              autoLength: true,
              onChange: (value) => {
                this.param = value;
              },
              onSubmit: () => {
                this.editParamSubmit(this.param);
                animateToImmediately(defaultAnimation(), () => {
                  this.menuSubmitted = true;
                });
                setTimeout(() => {
                  this.isMenu = false;
                }, 1000);
              }
            });
          }
          .padding({ left: standardSpacing * 0.5 });
        }
      }
    }
    .alignItems(HorizontalAlign.End)
    .onTouch((event) => {
      event.stopPropagation(); // Prevent event propagation, allowing the menu to remain open when clicked
    });
  }

  get myIcon() {
    return getButtonIcon(this.type, $r('sys.symbol.'.concat(this.paramIconId || 'link')) || $r('sys.symbol.questionmark_circle'));
  }
}

export { SlotEditButton };

/**
 * Available pre-set options for link icons in the menu.
 * Selected based on Liny's personal interests! ┐(￣ヮ￣)┌
 */
export const symbolIconOptions: string[] = [
  'link', 'checkmark', 'xmark', 'pawprint', 'lock',
  'cup', 'battery', 'bookmark', 'doc', 'doc_text',
  'hobbyhorse', 'cloud_and_stars', 'fork_knife', 'message', 'paintpalette',
  'bookmark_book_closed', 'satellite', 'flag', 'figure_roll', 'local_and_rectangle',
  'airplayaudio', 'ranking', 'medal', 'free_circle', 'diamond',
  'coins', 'paperclip', 'cloud_and_arrow_down', 'airplane_1', 'questionmark_circle',
  'rectangle_below_heat_waves', 'externaldrive', 'balloon_2', 'exclamationmark_triangle', 'wallet',
  'bolt_2', 'gift', 'hand_below_star', 'mapleleave', 'swipe',
  'satellite_1', 'umbrella', 'keyboard', 'identify_song', 'gamecontroller',
  'worldclock', 'camera', 'hourglass', 'key_horizontal', 'fish_fill',
  'cheers', 'leaf', 'wrench_and_screwdriver', 'basketball', 'toilet',
  'warning', 'person_crop_circle_fill', 'stickers', 'virtual_background', 'headphones'
];
