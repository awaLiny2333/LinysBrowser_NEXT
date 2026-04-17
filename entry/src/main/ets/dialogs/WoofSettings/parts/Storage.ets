import { AppStorageV2 } from '@kit.ArkUI';
import lazy { addUnitsToSize } from '../../../catstypicalframework/utils/storage';
import { MooCapsuleButton } from '../../../components/common/MooCapsuleButton';
import { MooTextModifier } from '../../../components/common/MooTextModifier';
import { UniContentCard } from '../../../components/common/UniContentCard';
import { UniRowOfCapsuleButtons } from '../../../components/common/UniRowOfCapsuleButtons';
import lazy { mooTextType, standardSpacing } from '../../../components/settings';
import lazy { scanHistoryIndexSize } from '../../../hosts/data/history/scripts/storage';
import { meowManagedSettings } from '../../../hosts/data/settings/classes/meowManagedSettings';
import lazy { removeWebCache, scanWebCacheSize } from '../../../hosts/system/env/scripts/storage';
import { meowAppStatuses } from '../../../hosts/system/windows/classes/meowAppStatuses';

@ComponentV2
struct SettingsStorage {
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
  @Local myApp: meowAppStatuses = AppStorageV2.connect(meowAppStatuses)!;

  build() {
    Column({ space: standardSpacing }) {
      Text($r('app.string.Settings_category_storage'))
        .attributeModifier(new MooTextModifier(mooTextType.TITLE))
        .width('100%')
        .opacity(0.8)
        .padding({ left: standardSpacing / 2 });

      // Web cache
      UniContentCard({ title: $r('app.string.Settings_category_storage_webCache'), icon: $r('sys.symbol.doc_plaintext_and_compass') }) {
        Text(addUnitsToSize(this.mySettings.settingsData[68].value as number)).attributeModifier(new MooTextModifier(mooTextType.TITLE));
        UniRowOfCapsuleButtons() {
          MooCapsuleButton({
            text: $r('app.string.General_refresh'),
            clickAction: () => {
              this.refreshWebCache();
            },
            isEnabled: !this.myApp.refreshingWebCacheSize
          });
          MooCapsuleButton({
            text: $r('app.string.General_clear'),
            needDoubleConfirm: true,
            clickAction: () => {
              // Clear web cache.
              removeWebCache();
            }
          });
        };
      };

      // History index
      UniContentCard({ title: $r('app.string.Settings_category_storage_historyIndex'), icon: $r('sys.symbol.doc_text_badge_clock') }) {
        Text(addUnitsToSize(this.mySettings.settingsData[70].value as number)).attributeModifier(new MooTextModifier(mooTextType.TITLE));
        MooCapsuleButton({
          text: $r('app.string.General_refresh'),
          clickAction: () => {
            this.refreshHistoryIndex();
          }
        });
      };
    };
  }

  async refreshWebCache() {
    // Reject if already refreshing. Although we set this button to be disabled if is refreshing, this adds more insurance. :P
    if (this.myApp.refreshingWebCacheSize) return;

    // Refresh web cache size.
    this.myApp.refreshingWebCacheSize = true;
    const size = await scanWebCacheSize(this.getUIContext().getHostContext()!);
    this.mySettings.setByIndex(68, size);

    // Recover flag
    this.myApp.refreshingWebCacheSize = false;
  }

  async refreshHistoryIndex() {
    // Reject if already refreshing. Although we set this button to be disabled if is refreshing, this adds more insurance. :P
    if (this.myApp.refreshingHistoryIndexSize) return;

    // Refresh index files size.
    this.myApp.refreshingHistoryIndexSize = true;
    const size = await scanHistoryIndexSize();
    this.mySettings.setByIndex(70, size);

    // Recover flag
    this.myApp.refreshingHistoryIndexSize = false;
  }
}

export { SettingsStorage };
