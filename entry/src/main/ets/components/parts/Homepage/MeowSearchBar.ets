import { AppStorageV2 } from '@kit.ArkUI';
import { meowLayout } from '../../../catstypicalframework/hosts/meowLayout';
import lazy { meow } from '../../../catstypicalframework/utils/catsLogger';
import { meowDialogManager } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import { meowUiStatuses } from '../../../hosts/system/windows/classes/meowUiStatuses';
import { meowManagedSettings } from '../../../hosts/userdata/settings/classes/meowManagedSettings';
import { defaultAnimation, getColor, isPreferRightHand, meowThemeColorType, standardSpacing, useEffects } from '../../settings';
import { meowButtonsType } from '../Buttons/constants';
import { MeowButtonsSlot } from '../Buttons/MeowButtonsSlot';
import { MeowTitleBarHeight } from './MeowTitleBar';

/**
 * The search bar.
 *
 * @todo FLUENT Switch between wide and non-wide mode. (Perhaps with custom node?)
 */
@ComponentV2
struct MeowSearchBar {
  // Hosts
  @Param @Require myUi: meowUiStatuses;
  @Param @Require myLayout: meowLayout;
  @Param @Require myDialog: meowDialogManager;
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;

  build() {
    Row() {
      if (this.myLayout.wideMode) {
        Blank().width(standardSpacing * 0.75);
      }

      this.AddressInput(); // Input

      if (this.showOnFocusButtons || this.showAlwaysOnButtons) {
        Blank().width(standardSpacing * 0.75);
      }

      // On focus
      if (this.showOnFocusButtons) {
        MeowButtonsSlot(this.myUi, this.myDialog, 77);
      }
      // Always on
      if (this.showAlwaysOnButtons) {
        MeowButtonsSlot(this.myUi, this.myDialog, 78);
      }

      if (!this.showOnFocusButtons && !this.showAlwaysOnButtons && this.myLayout.wideMode) {
        Blank().width(standardSpacing * 0.75);
      }
    }
    .direction(isPreferRightHand() ? Direction.Ltr : Direction.Rtl);
  }

  @Computed
  get showOnFocusButtons() {
    return this.myUi.searchBarFocused && (this.mySettings.settingsData[77].value as meowButtonsType[]).length > 0;
  }

  @Computed
  get showAlwaysOnButtons() {
    return (this.mySettings.settingsData[78].value as meowButtonsType[]).length > 0;
  }

  @Builder
  AddressInput() {
    TextInput({ text: this.myUi.searchContent, placeholder: ' 󰀩 ...' })
      .height(MeowTitleBarHeight)
      .fontColor(getColor(meowThemeColorType.FONT))
      .caretColor(getColor(meowThemeColorType.FONT))
      .selectedBackgroundColor(getColor(meowThemeColorType.FONT))
      .border(useEffects() ? { width: 1, color: $r('sys.color.icon_fourth') } : { width: 0 })
      .backgroundColor(useEffects() ? $r('app.color.blur_background_contrast') : getColor(meowThemeColorType.PRIMARY))
      .layoutWeight(1)
      .id(searchBarId)
      .onFocus(() => {
        animateToImmediately(defaultAnimation(), () => {
          this.myUi.searchBarFocused = true;
        });
      })
      .onBlur(() => {
        animateToImmediately(defaultAnimation(), () => {
          this.myUi.searchBarFocused = false;
        });
      })
      .onChange((c) => {
        this.myUi.searchContent = c;
        // TODO: Handle input change
      })
      .onSubmit(() => {
        // TODO: Handle input submission (Visit the site for SearchBar!)
        meow(`Visit / load [${this.myUi.searchContent}]!`);
      });
  }
}

export { MeowSearchBar };

export const searchBarId = 'MeowAddressInput';
