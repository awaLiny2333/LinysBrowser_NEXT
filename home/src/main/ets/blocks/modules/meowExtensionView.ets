import { animation_default } from '../../hosts/bunch_of_defaults';
import { bunch_of_extensions, extension } from '../../hosts/bunch_of_extensions';
import { CatsBridgeMethods } from '../../objects/CatstensionBridgeObj';
import { text_from_rawfile } from '../../utils/storage_tools';

@Component
struct meowExtensionView {
  @StorageLink('bunch_of_extensions') bunch_of_extensions: bunch_of_extensions = new bunch_of_extensions();
  // UI
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @LocalStorageLink('compact_mode') compact_mode: boolean = false; // Like PuraX
  @StorageLink('effects') effects: boolean = false;
  @LocalStorageLink('showing_ext_id') showing_ext_id: string = '';

  aboutToAppear(): void {
    console.log(`[meowExtensionView] bunch_of_extensions.extensions: ${this.bunch_of_extensions.extensions.length}`)
  }

  build() {
    Stack() {
      Row()
        .width('100%')
        .height('100%')
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.showing_ext_id = '';
        })

      Stack() {
        ForEach(this.bunch_of_extensions.extensions, (ext: extension, idx: number) => {
          Web({ controller: ext.controller, src: ext.path_full + '/' + ext.action_default_popup || $rawfile('home.html') })
            .mediaPlayGestureAccess(false)
            .databaseAccess(true)
            .fileAccess(true)
            .domStorageAccess(true)
            .multiWindowAccess(true)
            .mixedMode(MixedMode.All)
            .allowWindowOpenMethod(true)
            .mediaOptions({ audioExclusive: false })
            .darkMode(WebDarkMode.Auto) // Dark mode!
            .javaScriptAccess(true)
            .imageAccess(true)
            .onlineImageAccess(true)
            .onPageEnd((e) => {
              console.log(`[Extension] Web Loaded! url=${e.url}`);
            })
            .javaScriptProxy({
              object: ext.bridge,
              name: 'CatsBridge',
              methodList: CatsBridgeMethods(),
              controller: ext.controller
            })
            .runJavaScriptOnDocumentStart([
              { script: text_from_rawfile('cathrome/eventListener.js'), scriptRules: ["*"] },
              { script: text_from_rawfile('cathrome/liny.js'), scriptRules: ["*"] },
              { script: text_from_rawfile('cathrome/alarms.js'), scriptRules: ["*"] },
              { script: text_from_rawfile('cathrome/action.js'), scriptRules: ["*"] },
              { script: text_from_rawfile('cathrome/i18n.js'), scriptRules: ["*"] },
              { script: text_from_rawfile('cathrome/cathrome.js'), scriptRules: ["*"] },
            ])
            .onConsole((e) => {
              console.log('[Extension][onConsole] ' + e.message.getMessage());
              return true;
            })
            .visibility(this.showing_ext_id == ext.id ? Visibility.Visible : Visibility.Hidden)
            .hitTestBehavior(this.showing_ext_id == ext.id ? HitTestMode.Default : HitTestMode.Transparent)
        }, (ext: extension) => {
          return ext.id;
        })
      }
      .width(this.tablet_mode ? '60%' : undefined)
      .height('70%')
      .animation(animation_default())
      .margin(12)
      .clip(true)
      .borderRadius(this.effects ? 5 : 0)

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