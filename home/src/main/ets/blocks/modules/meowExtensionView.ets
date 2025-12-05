import { animation_default } from '../../hosts/bunch_of_defaults';
import { bunch_of_extensions } from '../../hosts/bunch_of_extensions';
import { createEWeb, ExtNodeController } from '../../objects/ExtWebNode';
import { detach_show_extension } from '../../processes/web_actions';

@Component
struct meowExtensionView {
  @StorageLink('bunch_of_extensions') bunch_of_extensions: bunch_of_extensions = new bunch_of_extensions();
  // UI
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @LocalStorageLink('compact_mode') compact_mode: boolean = false; // Like PuraX
  @StorageLink('effects') effects: boolean = false;
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  // Ext
  @LocalStorageLink('showing_ext_id') showing_ext_id: string = '';
  @LocalStorageLink('showing_ext_node_controller') showing_ext_node_controller: ExtNodeController | undefined = undefined;

  aboutToAppear(): void {
    // Init web to create the ExtWeb Nodes for extensions loaded from disk.
    if (this.bunch_of_extensions.NodeControllers.length == 0) {
      for (let index = 0; index < this.bunch_of_extensions.extensions.length; index++) {
        this.bunch_of_extensions.NodeControllers.push(new ExtNodeController(createEWeb(this.getUIContext(), this.bunch_of_extensions.extensions[index])));
      }
      console.log(`[meowExtensionView] bunch_of_extensions.extensions.lengtgh = ${this.bunch_of_extensions.extensions.length}. Created NodeControllers!`);
    } else {
      console.log(`[meowExtensionView] I'm a sub window. I found there are already created NodeControllers. I have nothing to do. Oh sad sad...`);
    }
  }

  build() {
    Stack() {
      Row()
        .width('100%')
        .height('100%')
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          let ext = this.bunch_of_extensions.get_extension(this.showing_ext_id);
          // if (ext) {
          //   ext.is_being_viewed = false;
          // }
          // this.showing_ext_id = '';
          if (ext) {
            detach_show_extension(ext);
          } else {
            this.showing_ext_node_controller = undefined;
            this.showing_ext_id = '';
          }
        })

      if (this.showing_ext_node_controller != undefined) {
        NodeContainer(this.showing_ext_node_controller)
          .width(this.tablet_mode ? '60%' : undefined)
          .height('70%')
          .animation(animation_default())
          .margin(12)
          .clip(true)
          .borderRadius(this.effects ? 5 : 0)
          .onAppear(() => {
            console.log(`[meowExtensionView][${this.my_window_id}] Hello NodeContainer.`);
          })
      } else {
        Row().onAppear(() => {
          console.log(`[meowExtensionView][${this.my_window_id}] Goodbye NodeContainer.`);
        })
      }

    }
    .alignContent(Alignment.TopEnd)
    .visibility((this.showing_ext_id != '') ? Visibility.Visible : Visibility.Hidden)
    .animation(animation_default())
    .width('100%')
    .height('100%')
    .hitTestBehavior((this.showing_ext_id != '') ? HitTestMode.Default : HitTestMode.Transparent)
  }
}

export default meowExtensionView;