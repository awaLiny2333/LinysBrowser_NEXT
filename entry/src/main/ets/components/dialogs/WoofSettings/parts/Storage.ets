import { AppStorageV2 } from '@kit.ArkUI';
import lazy { addUnitsToSize } from '../../../../catstypicalframework/utils/storage';
import { meowUiStatuses } from '../../../../hosts/env/classes/meowUiStatuses';
import lazy { removeWebCache, scanWebCacheSize } from '../../../../hosts/env/scripts/storage';
import lazy { scanHistoryIndexSize } from '../../../../hosts/history/scripts/storage';
import { meowManagedSettings } from '../../../../hosts/settings/classes/meowManagedSettings';
import lazy { mooTextType, standardSpacing } from '../../../settings';
import { MooCapsuleButton } from '../../../common/MooCapsuleButton';
import { MooTextModifier } from '../../../common/MooTextModifier';
import { UniContentCard } from '../../../common/UniContentCard';
import { UniRowOfCapsuleButtons } from '../../../common/UniRowOfCapsuleButtons';

@ComponentV2
struct SettingsStorage {
  @Local myMeowManagedSettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
  @Local myMeowUiStatuses: meowUiStatuses = AppStorageV2.connect(meowUiStatuses)!;

  build() {
    Column({ space: standardSpacing }) {
      Text($r('app.string.Settings_category_storage'))
        .attributeModifier(new MooTextModifier(mooTextType.TITLE))
        .width('100%')
        .opacity(0.8)
        .padding({ left: standardSpacing / 2 });

      // Web cache
      UniContentCard({ title: $r('app.string.Settings_category_storage_webCache'), icon: $r('sys.symbol.doc_plaintext_and_compass') }) {
        Text(addUnitsToSize(this.myMeowManagedSettings.settingsData[68].value as number)).attributeModifier(new MooTextModifier(mooTextType.TITLE));
        UniRowOfCapsuleButtons() {
          MooCapsuleButton({
            text: $r('app.string.General_refresh'),
            clickAction: () => {
              this.refreshWebCache();
            },
            isEnabled: !this.myMeowUiStatuses.refreshingWebCacheSize
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
        Text(addUnitsToSize(this.myMeowManagedSettings.settingsData[70].value as number)).attributeModifier(new MooTextModifier(mooTextType.TITLE));
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
    if (this.myMeowUiStatuses.refreshingWebCacheSize) return;

    // Refresh web cache size.
    this.myMeowUiStatuses.refreshingWebCacheSize = true;
    const size = await scanWebCacheSize(this.getUIContext().getHostContext()!);
    this.myMeowManagedSettings.setByIndex(68, size);

    // Recover flag
    this.myMeowUiStatuses.refreshingWebCacheSize = false;
  }

  async refreshHistoryIndex() {
    // Reject if already refreshing. Although we set this button to be disabled if is refreshing, this adds more insurance. :P
    if (this.myMeowUiStatuses.refreshingHistoryIndexSize) return;

    // Refresh index files size.
    this.myMeowUiStatuses.refreshingHistoryIndexSize = true;
    const size = await scanHistoryIndexSize();
    this.myMeowManagedSettings.setByIndex(70, size);

    // Recover flag
    this.myMeowUiStatuses.refreshingHistoryIndexSize = false;
  }
}

export { SettingsStorage };
