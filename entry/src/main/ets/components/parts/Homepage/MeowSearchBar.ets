import lazy { url } from '@kit.ArkTS';
import { AppStorageV2 } from '@kit.ArkUI';
import { meowLayout } from '../../../catstypicalframework/hosts/meowLayout';
import lazy { meow, meowLevel } from '../../../catstypicalframework/utils/catsLogger';
import lazy { measureTextWidth } from '../../../catstypicalframework/utils/ui';
import { meowDialogManager } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import { meowUiStatuses } from '../../../hosts/system/windows/classes/meowUiStatuses';
import { SearchBarStatuses } from '../../../hosts/system/windows/scripts/searchBarStatuses';
import { meowManagedSettings } from '../../../hosts/userdata/settings/classes/meowManagedSettings';
import { MooTextModifier } from '../../common/MooTextModifier';
import { searchBarId } from '../../constants';
import { defaultAnimation, fontSizeSmall, getColor, isPreferRightHand, meowThemeColorType, standardSpacing, useEffects } from '../../settings';
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
  // Local
  @Local searchBarWidth: number = 10;
  focusBlurTimeoutId: number | undefined = undefined;

  build() {
    Row() {
      if (this.myLayout.wideMode) {
        Blank().width(standardSpacing * 0.75);
      }

      // Input
      if (this.myUi.searchBarStatus == SearchBarStatuses.SHIFTED) {
        this.AddressInputKeyword();
      } else {
        this.AddressInputNormal();
      }

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

      if (!(this.showOnFocusButtons || this.showAlwaysOnButtons) && this.myLayout.wideMode) {
        Blank().width(standardSpacing * 0.75);
      }
    }
    .layoutWeight(this.myLayout.wideMode ? 1 : undefined)
    .direction(isPreferRightHand() ? Direction.Ltr : Direction.Rtl);
  }

  @Builder
  AddressInputKeyword() {
    // Keyword view
    Scroll() {
      Row({ space: standardSpacing }) {
        Repeat(this.myUi.searchKeywordEntries)
          .each((it) => {
            if (this.myUi.searchKeywordEntriesShowAll || it.index == 0) {
              if (this.myUi.searchKeywordEntriesShowAll) {
                Text(`${it.item[0]}`).attributeModifier(new MooTextModifier());
              }
              TextInput({ text: it.item[1], placeholder: '󰒟' })
                .addressBarProps()
                .focusBlur()
                .id(it.index == 0 ? searchBarId : undefined)
                .width(it.index == 0 && this.hasFreeSpace || !this.myUi.searchKeywordEntriesShowAll ? undefined : 'auto')
                .layoutWeight(it.index == 0 && this.hasFreeSpace || !this.myUi.searchKeywordEntriesShowAll ? 1 : undefined)
                .onChange((c) => {
                  it.item[1] = c;
                  try {
                    const newUrl = url.URL.parseURL(this.myUi.searchContent);
                    newUrl.params.set(it.item[0], c);
                    this.myUi.setCurrentSearchContent(newUrl.toString(), false);
                  } catch (e) {
                    meow(`Invalid URL: ${this.myUi.searchContent}`, 'MeowSearchBar][Keyword][onChange', meowLevel.WARN);
                  }
                })
                .onSubmit(() => this.go());
            }
          });
      }
      .padding({ right: 2 })
      .width(this.hasFreeSpace ? this.searchBarWidth : undefined);
    }
    .scrollBar(BarState.Off)
    .onAreaChange((oldValue, newValue) => {
      if (newValue.width != oldValue.width) {
        this.searchBarWidth = newValue.width as number;
      }
    })
    .layoutWeight(1)
    .scrollable(ScrollDirection.Horizontal)
    .edgeEffect(EdgeEffect.Spring);
  }

  @Builder
  AddressInputNormal() {
    // Normal view
    Row() {
      TextInput({ text: this.myUi.searchContent, placeholder: '󰀩 ...' })
        .addressBarProps()
        .focusBlur()
        .layoutWeight(1)
        .id(searchBarId)
        .onChange((c) => {
          this.myUi.setCurrentSearchContent(c, true);
        })
        .onSubmit(() => this.go());
    }
    .layoutWeight(1); // with .border, the bare TextInput would appear to be a little bit longer than the actural length. Therefore we need an outer container to limit its size.
  }

  setOnFocus() {
    animateToImmediately(defaultAnimation(), () => {
      this.myUi.searchBarFocused = true;
    });
  }

  setBlur() {
    // Currently no work. Like SaaS without the Internet.
  }

  go() {
    // TODO: Handle input submission (Visit the site for SearchBar!)
    meow(`Visit / load [${this.myUi.searchContent}]!`, 'MeowSearchBar][Keyword][GOs', meowLevel.WARN);
  }

  @Styles
  focusBlur() {
    .onFocus(() => this.setOnFocus())
    .onBlur(() => this.setBlur());
  }

  // Getters

  @Computed
  get hasFreeSpace() {
    if (this.myUi.searchKeywordEntries.length == 0) {
      return true;
    }
    let needLength = 0;
    const paddingEachInput = 16 * 2;
    const spaceEachEntry = standardSpacing * 2;
    for (const entry of this.myUi.searchKeywordEntries) {
      needLength += measureTextWidth(entry[0], this.getUIContext(), fontSizeSmall, FontWeight.Normal);
      needLength += measureTextWidth(entry[1] ? entry[1] : '󰒟', this.getUIContext(), fontSizeSmall, FontWeight.Normal);
      needLength += paddingEachInput + spaceEachEntry;
    }
    return this.searchBarWidth - needLength > 0;
  }

  @Computed
  get showOnFocusButtons() {
    return this.myUi.searchBarFocused && (this.mySettings.settingsData[77].value as meowButtonsType[]).length > 0;
  }

  @Computed
  get showAlwaysOnButtons() {
    return (this.mySettings.settingsData[78].value as meowButtonsType[]).length > 0;
  }
}

@Extend(TextInput)
function addressBarProps() {
  .padding(useEffects() ? { left: 16, right: 16, top: 8, bottom: 7 } : { left: 16, right: 16, top: 8, bottom: 8 })
  .height(useEffects() ? MeowTitleBarHeight - 1 : MeowTitleBarHeight)
  .fontColor(getColor(meowThemeColorType.FONT))
  .caretColor(getColor(meowThemeColorType.FONT))
  .selectedBackgroundColor(getColor(meowThemeColorType.FONT))
  .border(useEffects() ? { width: 1, color: $r('sys.color.icon_fourth') } : { width: 0 })
  .backgroundColor(useEffects() ? $r('app.color.blur_background_contrast') : getColor(meowThemeColorType.PRIMARY));
}


export { MeowSearchBar };
