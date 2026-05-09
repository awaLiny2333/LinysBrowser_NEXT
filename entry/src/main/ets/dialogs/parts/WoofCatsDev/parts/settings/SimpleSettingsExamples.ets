import { defaultInnerRadius } from '../../../../../catstypicalframework/utils/ui';
import { AppStorageV2 } from '@kit.ArkUI';
import { meowManagedSettings } from '../../../../../hosts/userdata/settings/classes/meowManagedSettings';
import { UniContentCard } from '../../../../../components/common/UniContentCard';
import { titleBarPositionBottom } from '../../../../../components/settings';
import { SymbolButton } from '../common/SymbolButton';
import { meowFlexOptions } from '../../../../../components/constants';

/**
 * Example on how to use the meowSettings system.
 */
@ComponentV2
struct SimpleSettingsExamples {
  @Local mySettings: meowManagedSettings = AppStorageV2.connect<meowManagedSettings>(meowManagedSettings)!; // Should be initialized by flows.
  @Local settingsAdblockExceptions: string[] = this.mySettings.settingsData[53].value as string[]; // adblock_exceptions

  build() {
    UniContentCard({ roundedRadius: defaultInnerRadius }) {
      Flex(meowFlexOptions) {
        // DEV_MODE as an example of meowSettingsEntryType.BOOLEAN
        Row({ space: 8 }) {
          Text('DEV_MODE');
          Toggle({ isOn: this.mySettings.settingsData[74].value as boolean, type: ToggleType.Switch })
            .onChange((c) => {
              this.mySettings.setByIndex(74, c);
            });
        };       
        
        Row({ space: 8 }) {
          Text('use_effects');
          Toggle({ isOn: this.mySettings.settingsData[7].value as boolean, type: ToggleType.Switch })
            .onChange((c) => {
              this.mySettings.setByIndex(7, c);
            });
        };

        // my_window_alias_last as an example of meowSettingsEntryType.STRING
        Flex(meowFlexOptions) {
          Text('my_window_alias_last');
          TextInput({ text: this.mySettings.settingsData[26].value as string })
            .width(200)
            .onChange((c) => {
              this.mySettings.setByIndex(26, c);
            });
        };
        Flex(meowFlexOptions) {
          Text('title_bar_position = "bottom"');
          Toggle({ isOn: titleBarPositionBottom(), type: ToggleType.Switch })
            .onChange((c) => {
              if (c) {
                this.mySettings.setByIndex(1, 'bottom');
              } else {
                this.mySettings.setByIndex(1, 'top');
              }
            });
        };

        // animation_response as an example of meowSettingsEntryType.number
        Flex(meowFlexOptions) {
          Text('animation_response');
          TextInput({ text: this.mySettings.settingsData[39].value?.toString() })
            .width(200)
            .onChange((c) => {
              this.mySettings.setByIndex(39, Number(c));
            });
        };
      }; // Settings in flex to save layout space

      // adblock_exceptions sites as an example of meowSettingsEntryType.STRING_ARRAY
      Flex(meowFlexOptions) {
        Button('Add Site  󰅖')
          .onClick(() => {
            this.settingsAdblockExceptions.push('new.site');
            this.mySettings.requestSaveToDisk();
          });
        Text('adblock_exceptions');
      };
      List({ space: 5 }) {
        Repeat(this.settingsAdblockExceptions)
          .each((item) => {
            ListItem() {
              Row({ space: 8 }) {
                TextInput({ text: item.item })
                  .layoutWeight(1)
                  .onChange((c) => {
                    if (this.settingsAdblockExceptions[item.index] == c) {
                      return;
                    }
                    this.settingsAdblockExceptions[item.index] = c;
                    this.mySettings.requestSaveToDisk();
                  });

                SymbolButton({
                  icon: $r('sys.symbol.trash'),
                  clickAction: () => {
                    this.settingsAdblockExceptions.splice(item.index, 1);
                    this.mySettings.requestSaveToDisk();
                  }
                });
              };
            };
          })
          .key((item) => JSON.stringify(item))
          .virtualScroll();
      }
      .height(200)
      .width('auto');
    };
  }
}

export { SimpleSettingsExamples };