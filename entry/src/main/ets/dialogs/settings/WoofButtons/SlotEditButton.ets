import { AppStorageV2 } from '@kit.ArkUI';
import { meowUiHost } from '../../../hosts/system/windows/classes/meowUiHost';
import { meowManagedSettings } from '../../../hosts/userdata/settings/classes/meowManagedSettings';
import mooMenuButton from '../../../components/common/MooMenuButton';
import { MooSymbolButton } from '../../../components/common/MooSymbolButton';
import { getColor, meowThemeColorType, useEffects } from '../../../components/settings';
import { getButtonIcon } from '../../../components/parts/MeowButtons/constants';

/**
 * An edit button that has two modes (isEditing?)
 * 
 * When isEditing is off, it's a normal button.
 * When isEditing is on, clicks on it would call a menu to delete it.
 *
 * This is also used in sidebar editing.
 * @see entry/src/main/ets/components/parts/Sidebar/MeowSidebar.ets
 */
@ComponentV2
struct SlotEditButton {
  // Params
  @Param @Require isEditing: boolean = false;
  @Param @Require type: string;
  // Hosts
  @Param myUi: meowUiHost | undefined = undefined;
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
  // Local
  @Local isMenu: boolean = false;
  // Events
  @Event myOnHold: () => boolean = () => {
    return false;
  };
  /**
   * Triggered if not editing!
   */
  @Event clickAction: () => void;
  @Event requestDelete: () => void;

  build() {
    MooSymbolButton({
      icon: this.myIcon,
      onHold: this.myOnHold(),
      clickAction: () => {
        if (this.isEditing) {
          this.isMenu = !this.isMenu;
        } else {
          this.clickAction();
        }
      }
    })
      .bindContextMenu(this.isMenu && this.isEditing, this.contextMenuBuilder(), {
        aboutToDisappear: () => {
          this.isMenu = false;
        },
        backgroundColor: useEffects() ? undefined : getColor(meowThemeColorType.PRIMARY)
      });
  }

  @Builder
  contextMenuBuilder() {
    mooMenuButton({
      text: $r('app.string.General_delete'),
      clickAction: () => {
        this.requestDelete();
      }
    });
  }

  get myIcon() {
    return getButtonIcon(this.type);
  }
}

export { SlotEditButton };
