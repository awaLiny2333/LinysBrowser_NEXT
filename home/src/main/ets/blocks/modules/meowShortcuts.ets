import lazy woofHomepageManager from '../../dialogs/managers/woofHomepageManager';
import { bookmark, bunch_of_bookmarks } from '../../hosts/bunch_of_bookmarks';
import { animation_default, capsule_bar_height, click_effect_default, fontSize_Large } from '../../hosts/bunch_of_defaults';
import { bunch_of_settings } from '../../hosts/bunch_of_settings';
import { bunch_of_tabs } from '../../hosts/bunch_of_tabs';
import { new_window, run_time, storage_of_id } from '../../utils/ui_tools';
import lazy { common } from '@kit.AbilityKit';
import lazy { zone_opened } from '../../processes/zone_actions';

@Component
struct meowShortcuts {
  shortcut_scroller: Scroller = new Scroller();
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  storage: LocalStorage = storage_of_id(this.my_window_id);
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  @StorageLink('bunch_of_bookmarks') @Watch('refresh_homepage_shortcuts') bunch_of_bookmarks: bunch_of_bookmarks = new bunch_of_bookmarks('Bookmarks~Meow');
  @StorageLink('homepage_shortcuts_bookmarks_dir') @Watch('refresh_homepage_shortcuts') homepage_shortcuts_dir: string = '/';
  @StorageLink('homepage_shortcuts') homepage_shortcuts: bookmark[] = []; // Ideally this is loaded after init_process.
  @StorageLink('zones') zones: string[] = [];
  // Environment
  @LocalStorageProp('screen_height') screen_height: number = 100;
  // Statuses
  @LocalStorageLink('current_url') current_url: string = "=￣ω￣=";
  @LocalStorageLink('shortcut_scroll_offset') shortcut_scroll_offset: number = 0;
  // Settings
  @StorageLink('homepage_shortcuts_init_height') homepage_shortcuts_init_height: number = 50;
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  @StorageLink('preferred_hand_reverse_homepage_shortcuts') preferred_hand_reverse_homepage_shortcuts: boolean = false;
  // Popups
  woofHomepageManager_control: CustomDialogController = new CustomDialogController({
    builder: woofHomepageManager(),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
  });

  aboutToAppear(): void {
    if (this.homepage_shortcuts.length > 0) {
      this.storage.setOrCreate('homepage_shortcuts_no_animation', true);
    }
  }

  build() {
    Scroll(this.shortcut_scroller) {
      Column({ space: 10 }) {
        ForEach(this.zones, (alias: string, key: number) => {
          zoneButton({
            zone_alias: alias,
            my_index: key,
          })
        })

        ForEach(this.homepage_shortcuts, (shortcut: bookmark, key: number) => {
          shortcutButton({
            bookmark: shortcut,
            my_index: key,
          })
        })
      }
      .alignItems(this.shortcut_alignItems())
      .padding({ top: Math.max(18, this.screen_height * (1 - this.homepage_shortcuts_init_height * 0.01)) })
      .width('100%')
    } // Shortcuts
    .padding({ right: 14, left: 14, bottom: 18 })
    .width('100%')
    .height('100%')
    .scrollable(ScrollDirection.Vertical)
    .align(Alignment.Bottom)
    .edgeEffect(EdgeEffect.Spring)
    .animation(animation_default())
    .scrollBar(BarState.Off)
    .visibility(this.visibility_of_shortcuts())
    .onDidScroll(() => {
      this.shortcut_scroll_offset = this.shortcut_scroller.currentOffset().yOffset;
    })
    .onClick(() => {
      this.woofHomepageManager_control.open();
    })
    .onAppear(() => {
      setTimeout(() => {
        this.storage.setOrCreate('homepage_shortcuts_no_animation', false);
      }, 1)
      console.log(`[meowShortcuts] Bookmarks Shortcuts OK! (${run_time(this.storage)} ms)`)
    })
  }

  // Values

  shortcut_alignItems() {
    let status = this.preferred_hand_left_or_right == 'right';
    if (this.preferred_hand_reverse_homepage_shortcuts) {
      status = !status;
    }
    return status ? HorizontalAlign.End : HorizontalAlign.Start;
  }

  visibility_of_shortcuts() {
    let vis = true;
    const pre_init = this.current_url == '=￣ω￣=' || this.current_url == undefined;
    const on_home = this.current_url == 'meow://home' && this.bunch_of_tabs.sub_tab_idx == -1;
    if (!(pre_init || on_home)) {
      vis = false;
    }
    return vis ? Visibility.Visible : Visibility.Hidden;
  }

  // Actions

  /**
   * Tries to retrieve homepage shortcuts from bunch_of_bookmarks.
   * */
  refresh_homepage_shortcuts() {
    let result = this.bunch_of_bookmarks.get_folder(this.homepage_shortcuts_dir)?.get_content();
    if (result) {
      this.homepage_shortcuts = Array.from(result);
      console.log(`[Meow][meowWebView] Directory selected / refreshed for shortcuts: [${this.homepage_shortcuts_dir}] (${run_time(this.storage)} ms)`);
      bunch_of_settings.set('homepage_shortcuts_bookmarks_dir', this.homepage_shortcuts_dir);
    } else {
      // directory doesn't exist
      this.homepage_shortcuts = [];

      if (this.homepage_shortcuts_dir == '/') {
        // Save empty selection
        bunch_of_settings.set('homepage_shortcuts_bookmarks_dir', this.homepage_shortcuts_dir);
        console.log('[Meow][meowWebView] Directory selection cleared! [' + this.homepage_shortcuts_dir + ']');
      } else {
        console.log('[Meow][meowWebView] Directory selected for shortcuts doesn\'t exist! [' + this.homepage_shortcuts_dir + ']');
      }
    }
  }
}

// @Reusable // Lost of animation
@Component
struct shortcutButton {
  @Prop my_index: number;
  @Prop bookmark: bookmark;
  // Environment
  @LocalStorageLink('current_url') current_url: string = "=￣ω￣=";
  @LocalStorageLink('screen_height') screen_height: number = 100;
  @LocalStorageLink('homepage_shortcuts_no_animation') homepage_shortcuts_no_animation: boolean = false;
  // Settings - Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  @StorageLink('preferred_hand_reverse_homepage_shortcuts') preferred_hand_reverse_homepage_shortcuts: boolean = false;
  @StorageLink('homepage_shortcuts_init_height') homepage_shortcuts_init_height: number = 50;
  // Gateways
  @LocalStorageLink('universal_new_tab_gateway') new_tab_gateway: (string | boolean)[] = ['', false];
  // Colors
  @StorageLink('effects') effects: boolean = false;
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // SHow
  @State vis_contents: Visibility = Visibility.None;
  @State render_contents: boolean = false;
  render_contents_timeout_id: number | undefined = undefined;
  @State show: Visibility = this.homepage_shortcuts_no_animation ? Visibility.Visible : Visibility.None;
  @State isHov: boolean = false;

  build() {
    Column({ space: this.render_contents ? 10 : 0 }) {
      Text(this.get_label_name())
        .brightness(this.isHov ? 1.1 : 1)
        .backgroundColor(this.background_color())
        .useEffect(this.effects, EffectType.WINDOW_EFFECT)
        .fontColor(this.color_current_font)
        .visibility(this.show)
        .animation(animation_default())
        .padding({
          left: 0.5 * capsule_bar_height(),
          right: 0.5 * capsule_bar_height(),
          top: 5,
          bottom: 5
        })
        .borderRadius(0.5 * capsule_bar_height())
        .fontSize(fontSize_Large())
        .fontWeight(FontWeight.Medium)
        .height(capsule_bar_height())
        .border({
          width: 2,
          color: "transparent"
        })
        .clickEffect(click_effect_default())
        .onAppear(() => {
          if (!this.homepage_shortcuts_no_animation) {
            setTimeout(() => {
              this.show = Visibility.Visible;
              // Animation of floating up
            }, this.get_animation_timeout())
          }
        })
        .onClick(() => {
          let item = this.bookmark;
          if (item.get_type() == 'bookmark') {
            // Is bookmark, access website
            setTimeout(() => {
              this.new_tab_gateway = [(item as bookmark).get_link(), false];
              this.current_url = (item as bookmark).get_link();
            }, 5);
          } else {
            // Is folder, expand contents
            clearTimeout(this.render_contents_timeout_id);
            if (this.vis_contents == Visibility.None) {
              this.vis_contents = Visibility.Visible;
              this.render_contents = true;
            } else {
              this.vis_contents = Visibility.None;
              this.render_contents_timeout_id = setTimeout(() => {
                this.render_contents = false;
              }, 300)
            }
          }
        })
        .onHover((isHv) => {
          this.isHov = isHv;
        })

      if (this.bookmark.get_type() == 'folder') {
        Column({ space: this.render_contents ? 10 : 0 }) {
          if (this.render_contents) {
            ForEach(Array.from(this.bookmark.get_content()), (shortcut: bookmark, key: number) => {
              shortcutButton({
                bookmark: shortcut,
                my_index: key,
              })
            })
          }
        }
        .alignItems(this.get_alignItems())
        .visibility(this.vis_contents)
        .animation(animation_default())
      }
    }
    .alignItems(this.get_alignItems())
    .padding(this.vis_contents == Visibility.Visible ? (this.is_right_align() ? { right: 30 } : { left: 30 }) : {})
    .animation(animation_default())
  }

  get_label_name() {
    let name = '';
    if (this.bookmark.get_type() == 'folder') {
      name = (this.vis_contents == Visibility.Visible ? '󰃆  ' : '󰃅  ');
    }
    let label = this.bookmark.get_label();
    name += label;
    return name;
  }

  is_right_align() {
    return (this.preferred_hand_left_or_right == 'right' && !this.preferred_hand_reverse_homepage_shortcuts) ||
      (!(this.preferred_hand_left_or_right == 'right') && this.preferred_hand_reverse_homepage_shortcuts);
  }

  get_alignItems() {
    if (this.is_right_align()) {
      return HorizontalAlign.End;
    } else {
      return HorizontalAlign.Start
    }
  }

  get_animation_timeout() {
    let interval = 800 / (this.screen_height / (capsule_bar_height() + 10));
    return (this.my_index + 0) * interval;
  }

  background_color(): ResourceColor {
    if (this.effects) {
      return $r('sys.color.background_tertiary');
    }
    return this.color_current_secondary;
  }
}

// @Reusable // Lost of animation
@Component
struct zoneButton {
  @Prop zone_alias: string;
  @Prop my_index: number;
  // Environment
  @LocalStorageLink('current_url') current_url: string = "=￣ω￣=";
  @LocalStorageLink('screen_height') screen_height: number = 100;
  @LocalStorageLink('homepage_shortcuts_no_animation') homepage_shortcuts_no_animation: boolean = false;
  @StorageLink('zones_opened') zones_opened: boolean[] = [];
  // Settings - Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  @StorageLink('preferred_hand_reverse_homepage_shortcuts') preferred_hand_reverse_homepage_shortcuts: boolean = false;
  // Colors
  @StorageLink('effects') effects: boolean = false;
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // SHow
  @State show: Visibility = this.homepage_shortcuts_no_animation ? Visibility.Visible : Visibility.None;
  @State isHov: boolean = false;

  build() {
    Text('󰙟 ' + this.zone_alias)
      .brightness(this.isHov ? 1.1 : 1)
      .opacity(this.zones_opened[this.my_index] ? 0.5 : 1)
      .backgroundColor(this.background_color())
      .useEffect(this.effects, EffectType.WINDOW_EFFECT)
      .fontColor(this.color_current_font)
      .visibility(this.show)
      .animation(animation_default())
      .padding({
        left: 0.5 * capsule_bar_height(),
        right: 0.5 * capsule_bar_height(),
        top: 5,
        bottom: 5
      })
      .borderRadius(0.5 * capsule_bar_height())
      .fontSize(fontSize_Large())
      .fontWeight(FontWeight.Medium)
      .height(capsule_bar_height())
      .border({
        width: 2,
        color: "transparent"
      })
      .clickEffect(click_effect_default())
      .onAppear(() => {
        if (!this.homepage_shortcuts_no_animation) {
          setTimeout(() => {
            this.show = Visibility.Visible;
            // Animation of floating up
          }, this.get_animation_timeout())
        }
      })
      .onClick(() => {
        // Prevent opening 2 same zones.
        let is_opened = zone_opened(this.zone_alias);
        // Open zone
        if (is_opened) {
          console.warn(`[zoneButton] INTERCEPTED Load zone! Zone already opened. ${this.zone_alias}`);
          return;
        }
        this.zones_opened[this.my_index] = true; // TODO: investigate appearance flash bug
        console.log(`[zoneButton] Load zone! ${this.zone_alias}`);
        new_window(this.getUIContext().getHostContext() as common.UIAbilityContext, Date.now().toString(), this.zone_alias, true);
      })
      .onHover((isHv) => {
        this.isHov = isHv;
      })
  }

  is_right_align() {
    return (this.preferred_hand_left_or_right == 'right' && !this.preferred_hand_reverse_homepage_shortcuts) ||
      (!(this.preferred_hand_left_or_right == 'right') && this.preferred_hand_reverse_homepage_shortcuts);
  }

  get_alignItems() {
    if (this.is_right_align()) {
      return HorizontalAlign.End;
    } else {
      return HorizontalAlign.Start
    }
  }

  get_animation_timeout() {
    let interval = 800 / (this.screen_height / (capsule_bar_height() + 10));
    return (this.my_index + 0) * interval;
  }

  background_color() {
    if (this.effects) {
      return $r('sys.color.background_tertiary');
    }
    return this.color_current_secondary;
  }
}

export default meowShortcuts;