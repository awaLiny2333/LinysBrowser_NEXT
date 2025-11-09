import linysCapsuleButton from '../../components/buttons/linysCapsuleButton';
import woofHomepageManager from '../../dialogs/managers/woofHomepageManager';
import { bookmark, bunch_of_bookmarks } from '../../hosts/bunch_of_bookmarks';
import { animation_default, capsule_bar_height } from '../../hosts/bunch_of_defaults';
import { bunch_of_settings } from '../../hosts/bunch_of_settings';
import { bunch_of_tabs } from '../../hosts/bunch_of_tabs';
import { run_time, storage_of_id } from '../../utils/ui_tools';

@Component
struct meowShortcuts {
  shortcut_scroller: Scroller = new Scroller();
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  storage: LocalStorage = storage_of_id(this.my_window_id);
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  @StorageLink('bunch_of_bookmarks') @Watch('refresh_homepage_shortcuts') bunch_of_bookmarks: bunch_of_bookmarks = new bunch_of_bookmarks('Bookmarks~Meow');
  @StorageLink('homepage_shortcuts_bookmarks_dir') @Watch('refresh_homepage_shortcuts') homepage_shortcuts_dir: string = '/';
  @StorageLink('homepage_shortcuts') homepage_shortcuts: bookmark[] = []; // Ideally this is loaded after init_process.
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
      this.storage.setOrCreate('homepage_shortcuts_no_start_animation', true);
    }
  }

  build() {
    Scroll(this.shortcut_scroller) {
      Column({ space: 10 }) {
        ForEach(this.homepage_shortcuts, (shortcut: bookmark, key: number) => {
          shortcutButton({
            bookmark: shortcut,
            my_index: key,
          })
        })
      }
      .alignItems(this.shortcut_alignItems())
      .padding({ top: Math.max(18, this.screen_height * (1 - this.homepage_shortcuts_init_height * 0.01)) })
      // .animation(animation_default())
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
  @LocalStorageLink('homepage_shortcuts_no_start_animation') homepage_shortcuts_no_start_animation: boolean = false;
  // Settings - Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  @StorageLink('preferred_hand_reverse_homepage_shortcuts') preferred_hand_reverse_homepage_shortcuts: boolean = false;
  @StorageLink('homepage_shortcuts_init_height') homepage_shortcuts_init_height: number = 50;
  // Gateways
  @LocalStorageLink('universal_new_tab_gateway') new_tab_gateway: (string | boolean)[] = ['', false];
  // Colors
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // SHow
  @State vis_contents: Visibility = Visibility.None;
  @State render_contents: boolean = false;
  render_contents_timeout_id: number | undefined = undefined;
  @State show: Visibility = this.homepage_shortcuts_no_start_animation ? Visibility.Visible : Visibility.None;
  @State offset_y: number = this.homepage_shortcuts_no_start_animation ? 0 : 50;

  build() {
    Column({ space: this.render_contents ? 10 : 0 }) {
      linysCapsuleButton({
        text: this.get_label_name(),
        color_button: this.color_current_secondary,
        color_text: this.color_current_font,
        opa: 1
      })
        .visibility(this.show)
        .animation(animation_default())
        .offset({ y: this.offset_y })
        .onAppear(() => {
          if (!this.homepage_shortcuts_no_start_animation) {
            setTimeout(() => {
              this.show = Visibility.Visible;
              this.offset_y = 0;
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
            }, 100)
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
}

export default meowShortcuts;