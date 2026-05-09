import { getRandomEmoticon } from '../../catstypicalframework/utils/meow';
import { getButtonIcon, meowThemeColorType, standardSpacing } from '../constants';
import { defaultAnimation, getColor, useEffects } from '../settings';
import mooMenuButton from './MooMenuButton';
import { MooSymbolButton } from './MooSymbolButton';
import { MooTextInputV2 } from './MooTextInputV2';
import { MooTextModifier } from './MooTextModifier';

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
  @Param @Require hasParam: boolean; // Params for each button is like the links for some buttons to open a web page in the side bar.
  @Param extraIcon: string | undefined = undefined; // Icon linked to type has a HIGHER priority than this iconId.
  @Param extraParam: string = '';
  // Meow
  @BuilderParam menuExtra?: () => void;
  // Local
  @Local menuSubmitted: boolean = false; // This is purely for animation :P
  @Local isMenu: boolean = false;
  @Local paramEdit: string = this.extraParam;
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

  @Monitor('param')
  refreshParamEdit() {
    this.paramEdit = this.extraParam;
  }

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
        if (this.menuExtra) {
          this.menuExtra();
        }
        if (this.hasParam) {
          // Param edit
          MooTextInputV2({
            text: this.extraParam,
            icon: this.myIcon,
            placeholder: '󰁫',
            autoLength: true,
            onChange: (value) => {
              this.paramEdit = value;
            },
            onSubmit: () => {
              this.editParamSubmit(this.paramEdit);
              animateToImmediately(defaultAnimation(), () => {
                this.menuSubmitted = true;
              });
              setTimeout(() => {
                this.isMenu = false;
              }, 1000);
            }
          })
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
    return getButtonIcon(this.type, $r('sys.symbol.'.concat(this.extraIcon || 'link')) || $r('sys.symbol.questionmark_circle'));
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
