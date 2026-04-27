import { meowAvoid } from '../../../catstypicalframework/hosts/meowAvoid';
import { standardSpacing, getColor, meowThemeColorType, fontSizeMedium, useEffects, isPreferRightHand, defaultAnimation } from '../../settings';
import { MeowButtonsSlot } from '../Buttons/MeowButtonsSlot';
import { meowButtons } from '../Buttons/constants';
import { heightMeowTitleBar } from './MeowTitleBar';
import { meowDialogManager } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import { meowUiStatuses } from '../../../hosts/system/windows/classes/meowUiStatuses';
import { meowManagedSettings } from '../../../hosts/userdata/settings/classes/meowManagedSettings';
import { AppStorageV2 } from '@kit.ArkUI';

/**
 * The search bar.
 *
 * @todo FLUENT Switch between wide and non-wide mode. (Perhaps with custom node?)
 */
@ComponentV2
struct MeowSearchBar {
  @Param @Once needFullPadding: boolean = false; // .padding({ left: standardSpacing * 0.5, right: standardSpacing * 0.5 });
  // Hosts
  @Param @Require myAvoid: meowAvoid;
  @Param @Require myUi: meowUiStatuses;
  @Param @Require myDialog: meowDialogManager;
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;

  build() {
    Row() {
      AddressInput({
        placeholder: ' 󰀩 ...',
        myAvoid: this.myAvoid,
        onBarFocus: () => {
          this.onBarFocus();
        },
        onBarBlur: () => {
          this.onBarBlur();
        }
      });
      Row().width(standardSpacing);
      if (this.myUi.searchBarFocused) {
        // On focus
        MeowButtonsSlot({
          myUi: this.myUi,
          myDialog: this.myDialog,
          buttons: this.mySettings.settingsData[77].value as meowButtons[]
        });
      }
      // Always on
      MeowButtonsSlot({
        myUi: this.myUi,
        myDialog: this.myDialog,
        buttons: this.mySettings.settingsData[78].value as meowButtons[]
      });
    }
    .padding(this.needFullPadding ? { left: standardSpacing, right: standardSpacing } : 0)
    .direction(isPreferRightHand() ? Direction.Ltr : Direction.Rtl);
  }

  onBarFocus() {
    animateToImmediately(defaultAnimation(), () => {
      this.myUi.searchBarFocused = true;
    });
  }

  onBarBlur() {
    animateToImmediately(defaultAnimation(), () => {
      this.myUi.searchBarFocused = false;
    });
  }
}

export { MeowSearchBar };

/**
 * Basically the same as MooTextInputV2 but with some modifications on color and style.
 *
 * @see entry/src/main/ets/components/common/MooTextInputV2.ets
 */
@ComponentV2
struct AddressInput {
  // Configs
  @Param @Once placeholder: string | undefined = undefined;
  @Param icon: Resource | undefined = undefined;
  @Param text: string = '';
  // Hosts
  @Param @Require myAvoid: meowAvoid;
  // Events
  @Event onChange: (c: string) => void;
  @Event onSubmit: () => void;
  @Event onBarFocus: () => void;
  @Event onBarBlur: () => void;

  build() {
    Row({ space: standardSpacing }) {
      if (this.icon) {
        SymbolGlyph(this.icon)
          .fontColor([getColor(meowThemeColorType.FONT)])
          .fontSize(fontSizeMedium);
      }
      TextInput({ text: this.text as string, placeholder: this.placeholder })
        .height(heightMeowTitleBar)
        .fontColor(getColor(meowThemeColorType.FONT))
        .caretColor(getColor(meowThemeColorType.FONT))
        .selectedBackgroundColor(getColor(meowThemeColorType.FONT))
        .border(useEffects() ? { width: 1, color: $r('sys.color.icon_fourth') } : { width: 0 })
        .backgroundColor(useEffects() ? $r('app.color.blur_background_contrast') : getColor(meowThemeColorType.PRIMARY))
        .layoutWeight(1)
        .id(searchBarId)
        .onFocus(() => {
          this.onBarFocus();
        })
        .onBlur(() => {
          this.onBarBlur();
        })
        .onChange((c) => {
          this.onChange(c);
        })
        .onSubmit(() => {
          this.onSubmit();
        });
    }
    .height(heightMeowTitleBar)
    .layoutWeight(1);
  }
}

export const searchBarId = 'MeowAddressInput';
