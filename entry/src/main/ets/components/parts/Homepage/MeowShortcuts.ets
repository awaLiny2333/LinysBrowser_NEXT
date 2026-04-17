import { AppStorageV2 } from '@kit.ArkUI';
import { meowLayout } from '../../../catstypicalframework/hosts/meowLayout';
import { defaultInnerRadius } from '../../../catstypicalframework/utils/ui';
import { meowBookmarkItem } from '../../../hosts/bookmarks/classes/meowBookmarkItem';
import { meowBookmarkStash } from '../../../hosts/bookmarks/classes/meowBookmarkStash';
import { meowAppStatuses } from '../../../hosts/env/classes/meowAppStatuses';
import { meowAppMessageType } from '../../../hosts/env/scripts/messaging';
import { meowManagedSettings } from '../../../hosts/settings/classes/meowManagedSettings';
import { MooTextModifier } from '../../common/MooTextModifier';
import { defaultAnimation, meowThemeColorType, getColor, shortcutsShouldBeOnTheRight, standardSpacing, useEffects } from '../../settings';

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
        Repeat(this.getFolder()) // This is sb.
          .each((item) => {
            MeowShortcutItem({ item: item.item });
          });
      }
      .width('100%')
      .alignItems(shortcutsShouldBeOnTheRight() ? HorizontalAlign.End : HorizontalAlign.Start)
      .padding({
        top: (1 - (this.mySettings.settingsData[46].value as number / 100)) * this.myLayout.height,
        // right: shortcutsShouldBeOnTheRight() ? standardSpacing : 0,
        // left: shortcutsShouldBeOnTheRight() ? 0 : standardSpacing
      });
    }
    .edgeEffect(EdgeEffect.Spring)
    .padding(standardSpacing);
  }

  getFolder() {
    this.refreshFlag; // To refresh!
    const folder = this.myBookmarks.getFolder(this.mySettings.settingsData[45].value as string);
    if (folder == undefined) {
      return [];
    }
    const shortcuts = Array.from(folder.children);
    return shortcuts;
  }

  @Monitor('myApp.crossAppMessageTunnel')
  receiveMessage() {
    if (this.myApp.crossAppMessageTunnel?.type == meowAppMessageType.BOOKMARKS_REFRESH) {
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
  @Local children: meowBookmarkItem[] = Array.from(this.item.children);
  @Local refreshFlag: boolean = true;
  // UI
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
        .backgroundColor(this.adjustedColorBackground())
        .fontColor(this.adjustedColorFont())
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
      if (this.item.isFolder && this.showingChildren) {
        Column({ space: standardSpacing * 0.5 }) {
          Repeat(this.children)
            .each((item) => {
              MeowShortcutItem({ item: item.item });
            });
        }
        .alignItems(shortcutsShouldBeOnTheRight() ? HorizontalAlign.End : HorizontalAlign.Start)
        .padding(shortcutsShouldBeOnTheRight() ? { right: standardSpacing * 2.33 } : { left: standardSpacing * 2.33 });
      }
    }
    .alignItems(shortcutsShouldBeOnTheRight() ? HorizontalAlign.End : HorizontalAlign.Start);
  }

  /**
   * Get label.
   * @returns The label of the item.
   */
  getLabel() {
    this.refreshFlag;
    return `${this.item.isFolder ? (this.showingChildren ? '󰃛  ' : '󰃅  ') : ''}${this.item.name}`;
  }

  /**
   * Listen and refresh.
   */
  @Monitor('myApp.crossAppMessageTunnel')
  receiveMessage() {
    if (this.myApp.crossAppMessageTunnel?.type != meowAppMessageType.BOOKMARKS_REFRESH) {
      return;
    }
    this.refreshFlag = !this.refreshFlag;
    if (this.item.isFolder && this.showingChildren) {
      this.children = Array.from(this.item.children);
    }
  }

  adjustedColorFont() {
    return getColor(meowThemeColorType.FONT);
  }

  adjustedColorBackground() {
    return getColor(meowThemeColorType.SECONDARY);
  }
}

export { MeowShortcutsPanel };
