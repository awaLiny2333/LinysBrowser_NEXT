import { AppStorageV2, SegmentButtonV2Items } from '@kit.ArkUI';
import { meowManagedSettings } from '../../../hosts/settings/classes/meowManagedSettings';
import { mooTextType, standardSpacing } from '../../../components/settings';
import { MooTabSegmentV2 } from '../../../components/common/MooTabSegmentV2';
import { MooTextModifier } from '../../../components/common/MooTextModifier';
import { UniContentCard } from '../../../components/common/UniContentCard';

@ComponentV2
struct SettingsOnStartUp {
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;

  build() {
    Column({ space: standardSpacing }) {
      Text($r('app.string.Settings_category_onStartUp'))
        .attributeModifier(new MooTextModifier(mooTextType.TITLE))
        .opacity(0.8)
        .padding({ left: standardSpacing / 2 });
      UniContentCard() {
        Text($r('app.string.Settings_category_onStartUp_page')).attributeModifier(new MooTextModifier());
        MooTabSegmentV2({
          initSelected: this.selectedOptionFromSettings(),
          items: new SegmentButtonV2Items([
            { text: $r('app.string.Settings_category_onStartUp_page_newTab') },
            { text: $r('app.string.Settings_category_onStartUp_page_home') },
            { text: $r('app.string.Settings_category_onStartUp_page_continue') }
          ]),
          onSelected: (index) => {
            // 'new tab' | 'home' | 'continue'
            switch (index) {
              case 0:
                this.mySettings.setByIndex(32, 'new tab');
                break;
              case 1:
                this.mySettings.setByIndex(32, 'home');
                break;
              case 2:
                this.mySettings.setByIndex(32, 'continue');
                break;
              default:
                break;
            }
          }
        });
      };
    }
    .alignItems(HorizontalAlign.Start);
  }

  selectedOptionFromSettings() {
    const value = this.mySettings.settingsData[32].value as string;
    const seq = ['new tab', 'home', 'continue'];
    return seq.indexOf(value);
  }
}

export { SettingsOnStartUp };
