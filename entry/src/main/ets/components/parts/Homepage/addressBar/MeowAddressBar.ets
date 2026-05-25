import lazy { url } from '@kit.ArkTS';
import { meowLayout } from '../../../../catstypicalframework/hosts/meowLayout';
import lazy { meow, meowLevel } from '../../../../catstypicalframework/utils/catsLogger';
import lazy { measureTextWidth } from '../../../../catstypicalframework/utils/ui';
import { meowDialogManager } from '../../../../hosts/system/dialogs/classes/meowDialogManager';
import { meowUiHost } from '../../../../hosts/system/windows/classes/meowUiHost';
import { AddressBarStatuses } from '../../../../hosts/system/windows/scripts/addressBarStatuses';
import { MooTextModifier } from '../../../common/MooTextModifier';
import { fontSizeSmall, meowThemeColorType, standardSpacing, textInputSlimHeight } from '../../../constants';
import { getColor, isPreferRightHand, meowButtonsAddressBarAlways, meowButtonsAddressBarOnFocus, showWindowTitle, useEffects, windowTitleOnAddressBar } from '../../../settings';
import { MeowButtonsSlot } from '../../MeowButtons/MeowButtonsSlot';

/**
 * The address bar.
 *
 * @todo FLUENT Switch between wide and non-wide mode. (Perhaps with custom node?)
 */
@ComponentV2
struct MeowAddressBar {
  // Hosts
  @Param @Require myUi: meowUiHost;
  @Param @Require myLayout: meowLayout;
  @Param @Require myDialog: meowDialogManager;
  // Local
  @Local barWidth: number = 10;
  focusBlurTimeoutId: number | undefined = undefined;

  build() {
    Row() {
      if (this.myUi.showAddressBarOverlay && windowTitleOnAddressBar() && showWindowTitle(this.myLayout) && this.myUi.myTabs.currentTab?.url) {
        // Overlay title
        Text(`${this.myUi.myTabs.currentTab?.title || 'Meow'}｜${this.myUi.windowAlias}`)
          .opacity(0.9)
          .backgroundColor(getColor(meowThemeColorType.PRIMARY))
          .textAlign(TextAlign.Center).layoutWeight(1).attributeModifier(new MooTextModifier())
          .padding(standardSpacing).borderRadius(standardSpacing).maxLines(1)
          .hoverEffect(HoverEffect.Highlight)
          .height(useEffects() ? textInputSlimHeight - 1 : textInputSlimHeight)
          .margin(this.myLayout.wideMode ? { left: standardSpacing * 0.5, right: standardSpacing * 0.5 } : 0)
          .onClick(() => {
            this.myUi.requestHideAddressBarOverlay();
          });
      } else {
        // Space
        if (this.myLayout.wideMode) {
          Blank().width(standardSpacing * 0.75);
        }

        // Input
        if (this.myUi.addressBarStatus == AddressBarStatuses.SHIFTED) {
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
            if (this.myUi.searchKeywordEntriesExpanded || it.index == 0) {
              if (this.myUi.searchKeywordEntriesExpanded) {
                Text(`${it.item[0]}`).attributeModifier(new MooTextModifier());
              }
              TextInput({ text: it.item[1], placeholder: '󰒟  ...' })
                .allowDrop(null)
                .addressBarProps()
                .keyboardAppearance(KeyboardAppearance.IMMERSIVE)
                .id(it.index == 0 ? addressBarId : undefined)
                .width(it.index == 0 && this.hasFreeSpace || !this.myUi.searchKeywordEntriesExpanded ? undefined : 'auto')
                .layoutWeight(it.index == 0 && this.hasFreeSpace || !this.myUi.searchKeywordEntriesExpanded ? 1 : undefined)
                .onFocus(() => {
                  this.myUi.setCurrentFieldContent(it.item[1]);
                  this.myUi.reportAddressBarFocus();
                })
                .onBlur(() => {
                  this.myUi.reportAddressBarBlur();
                })
                .onChange((c) => {
                  it.item[1] = c;
                  try {
                    // The safest way to do so...
                    const newUrl = url.URL.parseURL(this.myUi.addressBarContentMajor);
                    newUrl.params.set(it.item[0], c);
                    this.myUi.setCurrentSearchContent(newUrl.toString(), false, true);
                  } catch (e) {
                    meow(`Invalid URL: ${this.myUi.addressBarContentMajor}`, 'MeowAddressBar][Keyword][onChange', meowLevel.WARN);
                  }
                  this.myUi.setCurrentFieldContent(it.item[1]);
                })
                .onSubmit(() => this.go());
            }
          });
      }
      .padding({ right: 2 })
      .width(this.hasFreeSpace ? this.barWidth : undefined);
    }
    .scrollBar(BarState.Off)
    .layoutWeight(1)
    .scrollable(this.hasFreeSpace ? ScrollDirection.None : ScrollDirection.Horizontal)
    .edgeEffect(EdgeEffect.Spring)
    .onAreaChange((oldValue, newValue) => {
      if (newValue.width != oldValue.width) {
        this.barWidth = newValue.width as number;
      }
    });
  }

  @Builder
  AddressInputNormal() {
    // Normal view
    Row() {
      TextInput({ text: this.myUi.addressBarContentMajor, placeholder: '󰀩  ...' })
        .allowDrop(null)
        .addressBarProps()
        .keyboardAppearance(KeyboardAppearance.IMMERSIVE)
        .layoutWeight(1)
        .id(addressBarId)
        .onFocus(() => {
          this.myUi.setCurrentFieldContent(this.myUi.addressBarContentMajor);
          this.myUi.reportAddressBarFocus();
        })
        .onBlur(() => {
          this.myUi.reportAddressBarBlur();
        })
        .onChange((c) => {
          this.myUi.setCurrentSearchContent(c, true, true);
          this.myUi.setCurrentFieldContent(c);
        })
        .onSubmit(() => this.go());
    }
    .layoutWeight(1); // with .border, the bare TextInput would appear to be a little bit longer than the actural length. Therefore we need an outer container to limit its size.
  }

  /**
   * Submit the search / load request.
   */
  go() {
    this.myUi.submitSearchOrLoad();
    this.myUi.requestAddressBarBlur(this.getUIContext());
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
      needLength += measureTextWidth(entry[1] ? entry[1] : '󰒟  ...', this.getUIContext(), fontSizeSmall, FontWeight.Normal);
      needLength += paddingEachInput + spaceEachEntry;
    }
    return this.barWidth - needLength > 0;
  }

  @Computed
  get showOnFocusButtons() {
    return this.myUi.addressBarFocused && meowButtonsAddressBarOnFocus().length > 0;
  }

  @Computed
  get showAlwaysOnButtons() {
    return meowButtonsAddressBarAlways().length > 0;
  }
}

export { MeowAddressBar };

@Extend(TextInput)
function addressBarProps() {
  .padding(useEffects() ? { left: 16, right: 16, top: 8, bottom: 7 } : { left: 16, right: 16, top: 8, bottom: 8 })
  .height(useEffects() ? textInputSlimHeight - 1 : textInputSlimHeight)
  .fontColor(getColor(meowThemeColorType.FONT))
  .caretColor(getColor(meowThemeColorType.FONT))
  .selectedBackgroundColor(getColor(meowThemeColorType.FONT))
  .border(useEffects() ? { width: 1, color: $r('sys.color.icon_fourth') } : { width: 0 })
  .backgroundColor(useEffects() ? $r('app.color.blur_background_contrast') : getColor(meowThemeColorType.PRIMARY));
}

export const addressBarId = 'MeowAddressInput';
