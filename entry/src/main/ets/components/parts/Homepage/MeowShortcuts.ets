/**
 * This is the bookmark shortcuts to be displayed on the home page.
 */

import { AppStorageV2 } from '@kit.ArkUI';
import { meowLayout } from '../../../catstypicalframework/hosts/meowLayout';
import { defaultInnerRadius } from '../../../catstypicalframework/utils/ui';
import { meowBookmarkItem } from '../../../hosts/data/bookmarks/classes/meowBookmarkItem';
import { meowBookmarkStash } from '../../../hosts/data/bookmarks/classes/meowBookmarkStash';
import { meowManagedSettings } from '../../../hosts/data/settings/classes/meowManagedSettings';
import { meowAppStatuses } from '../../../hosts/system/windows/classes/meowAppStatuses';
import { meowAppMessageType } from '../../../hosts/system/windows/scripts/messaging';
import { MooTextModifier } from '../../common/MooTextModifier';
import { defaultAnimation, getColor, meowThemeColorType, shortcutsShouldBeOnTheRight, standardSpacing, useEffects } from '../../settings';

@ComponentV2
struct MeowShortcutsPanel {
  @Param @Require myLayout: meowLayout;
  // Host
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
  @Local myBookmarks: meowBookmarkStash = AppStorageV2.connect(meowBookmarkStash)!;
  @Local myApp: meowAppStatuses = AppStorageV2.connect(meowAppStatuses)!; // For event receiving.
  // Local
  @Local refreshFlag: boolean = true;

  build() {
    Scroll() {
      Column({ space: standardSpacing * 0.5 }) {
        Repeat(this.getFolder())
          .each((item) => {
            MeowShortcutItem({ item: item.item });
          });
      }
      .padding({ top: (1 - (this.mySettings.settingsData[46].value as number / 100)) * this.myLayout.height });
    }
    .scrollBar(BarState.Off)
    .align(Alignment.Bottom)
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.Spring)
    .padding(standardSpacing);
  }

  getFolder() {
    this.refreshFlag; // To trigger refresh!
    const folder = this.myBookmarks.getFolder(this.mySettings.settingsData[45].value as string);
    if (folder == undefined) {
      return []; // Wrong path. Return empty array.
    }
    return Array.from(folder.children);
  }

  @Monitor('myApp.crossAppMessageTunnel')
  receiveMessage() {
    const msgType = this.myApp.crossAppMessageTunnel?.type;
    if (msgType == meowAppMessageType.BOOKMARKS_REFRESH || msgType == meowAppMessageType.BOOKMARKS_PICKED) {
      this.refreshFlag = !this.refreshFlag;
    }
  }
}

@ComponentV2
struct MeowShortcutItem {
  @Param @Require item: meowBookmarkItem;
  // Host
  @Local myApp: meowAppStatuses = AppStorageV2.connect(meowAppStatuses)!; // For event receiving.
  // Data
  @Local showingChildren: boolean = false;
  @Local refreshFlag: boolean = true;
  // UI
  @Param paddingValue: number = 0;
  @Local myBrightness: number = 1;

  build() {
    Column({ space: standardSpacing * 0.75 }) {
      Text(this.getLabel()).attributeModifier(new MooTextModifier())
        .brightness(this.myBrightness)
        .animation(defaultAnimation())
        .padding(standardSpacing * 1.25)
        .border({
          width: (useEffects() ? 1 : 0),
          color: $r('sys.color.icon_fourth'),
          radius: defaultInnerRadius
        })
        .onHover((isHover) => {
          if (isHover && this.myBrightness == 1 || !isHover && this.myBrightness == 1.1) {
            this.myBrightness = isHover ? 1.1 : 1;
          }
        })
        .useEffect(useEffects(), EffectType.WINDOW_EFFECT)
        .backgroundColor(getColor(meowThemeColorType.SECONDARY))
        .fontColor(getColor(meowThemeColorType.FONT))
        .onClick(() => {
          if (this.item.isFolder) {
            animateToImmediately(defaultAnimation(), () => {
              this.showingChildren = !this.showingChildren;
            });
          } else {
            // Visit!
          }
        });

      // Children of folder
      if (this.item.isFolder && this.showingChildren && this.item.children.length > 0) {
        Repeat(this.getChildren())
          .each((item) => {
            MeowShortcutItem({ item: item.item, paddingValue: standardSpacing * 2.33 });
          });
      }
    }
    .padding(shortcutsShouldBeOnTheRight() ? { right: this.paddingValue } : { left: this.paddingValue })
    .alignItems(shortcutsShouldBeOnTheRight() ? HorizontalAlign.End : HorizontalAlign.Start)
    .animation(defaultAnimation())
    .width('100%');
  }

  /**
   * Get the item's label (name).
   * @returns The label of the item.
   */
  getLabel() {
    this.refreshFlag;
    return `${this.item.isFolder ? (this.showingChildren ? '󰃛  ' : '󰃅  ') : ''}${this.item.name}`;
  }

  getChildren() {
    this.refreshFlag;
    return Array.from(this.item.children);
  }

  @Monitor('myApp.crossAppMessageTunnel')
  receiveMessage() {
    const msgType = this.myApp.crossAppMessageTunnel?.type;
    if (msgType == meowAppMessageType.BOOKMARKS_REFRESH || msgType == meowAppMessageType.BOOKMARKS_PICKED) {
      this.refreshFlag = !this.refreshFlag;
    }
  }
}

export { MeowShortcutsPanel };
