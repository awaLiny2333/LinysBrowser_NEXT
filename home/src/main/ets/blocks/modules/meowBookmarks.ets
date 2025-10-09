import { bookmark, bunch_of_bookmarks, folder, unified_item } from '../../hosts/bunch_of_bookmarks';
import { bunch_of_tabs } from '../../hosts/bunch_of_tabs';
import { document_pick_to_text, document_save_text, sandbox_save } from '../../utils/storage_tools';
import { animation_default, capsule_bar_height, click_effect_default, fontSize_Large, fontSize_Normal } from '../../hosts/bunch_of_defaults';
import lazy { url_resource_to_meow } from '../../utils/url_tools';
import linysSymbol from '../../components/texts/linysSymbol';
import linysShowButton from '../../components/buttons/linysShowButton';
import linysCapsuleButton from '../../components/buttons/linysCapsuleButton';
import linysPathTree from '../../components/linysPathTree';
import linysTimeoutButton from '../../components/buttons/linysTimeoutButton';
import linysCapsuleButtonWithText from '../../components/buttons/linysCapsuleButtonWithText';
import lazy woofSelectBookmarksPath from '../../dialogs/prompts/woofSelectBookmarksPath';
import { current_tabs_style_is_horizontal, storage_of_id } from '../../utils/ui_tools';
import linysExpandableCardItem from '../../components/layouts/linysExpandableCardItem';

@Component
struct meowBookmarks {
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  storage: LocalStorage = storage_of_id(this.my_window_id);
  // Hosts
  @StorageLink('bunch_of_bookmarks') bunch_of_bookmarks: bunch_of_bookmarks = new bunch_of_bookmarks("Bookmarks~Meow");
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  @State viewing_contents: unified_item[] = this.bunch_of_bookmarks.root.get_content();
  @State @Watch('refresh_content_view') looking_at_path: string = "";
  @State current_folder: folder | undefined = undefined;
  // Environments
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  // UI control actions
  @LocalStorageLink('showing_tabs') showing_tabs: boolean = false;
  @LocalStorageLink('showing_bookmarks') showing_bookmarks: boolean = false;
  @LocalStorageLink('swapping_bookmarks') swapping_bookmarks: boolean = false;
  bookmarks_scroller: Scroller = new Scroller();
  @LocalStorageLink('bookmarks_scroll_by') @Watch('scroll_bookmarks') bookmarks_scroll_by: number = 0;
  @LocalStorageLink('swapping_offset_timeout') swapping_offset_timeout: number = 0;
  @State swapping_offset_upper: number = 0;
  @State swapping_offset_downer: number = 0;
  // Settings / Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  @StorageLink('preferred_hand_reverse_tabs_panel') preferred_hand_reverse_tabs_panel: boolean = false;
  // Input and Interactions
  @LocalStorageLink('bookmark_add_label') add_label: string = "";
  @LocalStorageLink('bookmark_add_link') add_link: string = "";
  @State scroll_area_height: number = 0;
  @State adding_folder: boolean = false;
  @LocalStorageLink('adding_bookmark') adding_bookmark: boolean = false;
  @State showing_navigator: boolean = false;
  @State importing_bookmarks: boolean = false;
  @State exporting_bookmarks: boolean = false;
  // Dialogs
  @LocalStorageLink('universal_fail_prompt_desc_gateway') uni_fail_prompt_gateway: ResourceStr = "";
  /**
   * Colors */
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Pan Gesture
  pan_x: number = 0;

  build() {
    Column() {
      Scroll(this.bookmarks_scroller) {
        Column({ space: 5 }) {
          Column() {
            Column()
              .height(this.swapping_offset_upper)
            if (this.swapping_bookmarks) {
              Column()
                .height(Math.max(0, this.scroll_area_height - 5 - this.viewing_contents.length * (42 + 5)))
            }
          }

          ForEach(this.viewing_contents, (_unified_item: unified_item, key: number) => {
            bookmarkItem({
              // Generals
              my_index: key,
              viewing_contents: this.viewing_contents, // For editing
              looking_at_path: this.looking_at_path, // the path of now showing list (directory) on the panel
              // To ask webViews to show
              height_of_panel: this.scroll_area_height, // for animation params
              parent_path: this.looking_at_path, // for get_my_path()
            });
          },)

          Column()
            .height(this.swapping_offset_downer)
        }
        .width("100%")
      } // List of this directory
      .direction(Direction.Rtl)
      .align(Alignment.Bottom)
      .borderRadius(7)
      .edgeEffect(EdgeEffect.Spring)
      .width("100%")
      .layoutWeight(1)
      .margin({ bottom: 10 })
      .onAreaChange((_o, n) => {
        this.scroll_area_height = n.height as number;
        // Update height of scroll area
        // So that bookmark buttons will know if they are out of visible area
        // and reduce their appearance animation time.
      })
      .nestedScroll({ scrollForward: NestedScrollMode.SELF_ONLY, scrollBackward: NestedScrollMode.SELF_ONLY })

      Row({ space: this.tablet_mode ? 12 : 9 }) {
        linysSymbol({ symbol_glyph_target: 'sys.symbol.arrow_left' })// Go back button
          .onClick(() => {
            this.go_back();
          })
          .visibility(this.looking_at_path == "" || this.swapping_bookmarks ? Visibility.None : this.visible_when_no_operating())
          .animation(animation_default())

        linysShowButton({
          symbol_glyph_target: 'sys.symbol.swap',
          show: this.swapping_bookmarks,
          text: $r('app.string.Bookmarks_move_order')
        })// Swap Button
          .onClick(() => {
            this.importing_bookmarks = false;
            this.exporting_bookmarks = false;
            this.adding_folder = false;
            this.adding_bookmark = false;
            this.swapping_bookmarks = !this.swapping_bookmarks;
          })

        Blank()
          .visibility(this.preferred_hand_left_or_right == 'right' ? Visibility.Visible : Visibility.None)
          .animation(animation_default())

        Column() {
          linysShowButton({
            show: this.importing_bookmarks,
            symbol_glyph_target: 'sys.symbol.arrow_down_and_rectangle_on_rectangle',
            text: $r('app.string.Index_import_bookmarks_title')
          })
            .onClick(() => {
              this.adding_folder = false;
              this.adding_bookmark = false;
              this.exporting_bookmarks = false;
              this.importing_bookmarks = !this.importing_bookmarks;
              // this.import_bookmarks_html();
            })
        } // Import bookmarks button
        .alignItems(HorizontalAlign.End)
        .visibility(this.swapping_bookmarks ? Visibility.None : Visibility.Visible)
        .animation(animation_default())

        linysShowButton({
          show: this.exporting_bookmarks,
          symbol_glyph_target: 'sys.symbol.arrow_right_up_and_square',
          text: $r('app.string.Index_export_bookmarks_title')
        })
          .onClick(() => {
            this.adding_folder = false;
            this.adding_bookmark = false;
            this.importing_bookmarks = false;
            this.exporting_bookmarks = !this.exporting_bookmarks;
            // this.export_bookmarks_html();
          })// Export bookmarks button
          .visibility(this.swapping_bookmarks ? Visibility.None : Visibility.Visible)
          .animation(animation_default())
        linysShowButton({
          show: this.adding_folder,
          symbol_glyph_target: 'sys.symbol.folder_badge_plus',
          text: $r('app.string.Index_add_folder_title')
        })
          .onClick(() => {
            this.adding_bookmark = false;
            this.exporting_bookmarks = false;
            this.importing_bookmarks = false;
            this.add_label = "";
            this.adding_folder = !this.adding_folder;
          })// Add folder button
          .visibility(this.swapping_bookmarks ? Visibility.None : Visibility.Visible)
          .animation(animation_default())
        linysShowButton({
          show: this.adding_bookmark,
          symbol_glyph_target: 'sys.symbol.plus_square',
          text: $r('app.string.Index_add_bookmark_title')
        })
          .onClick(() => {
            this.adding_folder = false;
            this.exporting_bookmarks = false;
            this.importing_bookmarks = false;
            this.add_label = this.bunch_of_tabs.workingMainTab().title;
            this.add_link = url_resource_to_meow(this.bunch_of_tabs.workingMainTab().url);
            this.adding_bookmark = !this.adding_bookmark;
          })// Add bookmark button
          .visibility(this.swapping_bookmarks ? Visibility.None : Visibility.Visible)
          .animation(animation_default())
      } // Operation buttons
      .constraintSize({ minHeight: 36 })
      .width("100%")
      .margin({ bottom: 5 })

      Scroll() {
        Column({ space: 10 }) {
          Row({ space: 10 }) {
            linysSymbol({ symbol_glyph_target: "sys.symbol.rename" })
            TextInput({ text: this.add_label })
              .onChange((value) => {
                this.add_label = value;
              })
              .fontWeight(FontWeight.Regular)
              .fontColor(this.color_current_font)
              .caretColor(this.color_current_font)
              .selectedBackgroundColor(this.color_current_font)
              .height(capsule_bar_height())
              .selectAll(true)
              .layoutWeight(1)
              .onSubmit(() => {
                if (this.adding_folder) {
                  this.new_folder();
                }
              })

          } // Edit Label TextInput
          .visibility(this.adding_folder || this.adding_bookmark ? Visibility.Visible : Visibility.None)
          .animation(animation_default())

          Row({ space: 10 }) {
            linysSymbol({ symbol_glyph_target: "sys.symbol.paperclip" })
            TextInput({ text: this.add_link })
              .onChange((value) => {
                this.add_link = value;
              })
              .fontWeight(FontWeight.Regular)
              .fontColor(this.color_current_font)
              .caretColor(this.color_current_font)
              .selectedBackgroundColor(this.color_current_font)
              .selectAll(true)
              .layoutWeight(1)
              .onSubmit(() => {
                this.new_bookmark();
              })
              .height(capsule_bar_height())

          } // Edit link TextInput
          .visibility(this.adding_bookmark ? Visibility.Visible : Visibility.None)
          .animation(animation_default())

          linysCapsuleButtonWithText({
            desc_text: this.exporting_bookmarks || this.importing_bookmarks ? $r('app.string.Index_select_file') : '',
            button_text: this.adding_folder || this.adding_bookmark ? "  󰀓  " : "  󰃟  ",
            onExecution: () => {
              if (this.adding_folder) {
                this.new_folder()
              }
              if (this.adding_bookmark) {
                this.new_bookmark()
              }
              if (this.importing_bookmarks) {
                this.import_bookmarks_html()
              }
              if (this.exporting_bookmarks) {
                this.export_bookmarks_html()
              }
            }
          })// Submit add button
            .visibility(this.adding_folder || this.adding_bookmark || this.exporting_bookmarks ||
            this.importing_bookmarks ? Visibility.Visible :
              Visibility.None)
            .animation(animation_default())

        }
        .width("100%")
      } // Edit panel
      .height(this.get_edit_area_height())
      .animation(animation_default())
      .scrollBar(BarState.Off)

      Text(this.text_path())// Display of list menu quick jump
        .fontColor(this.color_current_font)
        .fontWeight(FontWeight.Bold)
        .fontSize(fontSize_Normal())
        .textAlign(this.preferred_hand_left_or_right == 'right' ? TextAlign.End : TextAlign.Start)
        .width("100%")
        .margin({ top: 5, bottom: 5 })
        .opacity(0.7)
        .animation(animation_default())
        .clickEffect(click_effect_default())
        .onClick(() => {
          this.showing_navigator = !this.showing_navigator;
        })

      linysPathTree({
        current_viewing_path: this.looking_at_path,
      })// Path indicator
        .height(this.showing_navigator ? undefined : 0)
        .animation(animation_default())

    } // List of directory, Operation buttons and edit TextInputs
    .justifyContent(FlexAlign.End)
    .width("100%")
    .height("100%")
    .onAppear(() => {
      // console.log("[Meow][meowBookmarks] Bookmarks READY")
      this.on_appear();
    })
    .gesture(
      PanGesture({ direction: PanDirection.Left | PanDirection.Right })
        .onActionStart(() => {
          // console.info('Pan start');
          this.pan_x = 0;
        })
        .onActionUpdate((e) => {
          this.pan_x += e.offsetX;
          // console.log(this.pan_x.toString())
        })
        .onActionEnd(() => {
          // this.positionX = this.offsetX;
          // this.positionY = this.offsetY;
          // console.info('Pan end');
          // console.info('Pan end timeStamp is: ' + event.timestamp);
          if (!current_tabs_style_is_horizontal(this.storage)) {
            if (this.pan_x < 0) {
              // ← CLose if Left align
              if (!this.is_right_align()) {
                this.showing_bookmarks = false;
              }
            } else {
              // → Switch to Tabs
              this.showing_bookmarks = false;
              this.showing_tabs = true;
            }
          } else {
            // Directly Close if Horizontal tab
            if (this.pan_x > 0 && this.is_right_align()) {
              // →
              this.showing_bookmarks = false;
            }
            if (this.pan_x < 0 && !this.is_right_align()) {
              // →
              this.showing_bookmarks = false;
            }
          }
        })
    )
  }

  // Event

  async on_appear() {
    this.refresh_content_view();

    setInterval(() => {
      if (this.swapping_offset_timeout == 100) {
        this.getUIContext().animateTo(animation_default(), () => {
          this.swapping_offset_upper = 0;
          this.swapping_offset_downer = 0;
        })
      }
      this.swapping_offset_timeout -= 100;
      if (this.swapping_offset_timeout <= 0) {
        this.swapping_offset_timeout = 0;
      }
    }, 100)
  }

  // Misc

  get_edit_area_height() {
    let area_height = 0;
    area_height += this.adding_bookmark ? 145 : 0;
    area_height += this.adding_folder ? 100 : 0;
    area_height += this.importing_bookmarks || this.exporting_bookmarks ? 54 : 0;
    return area_height;
  }

  refresh_content_view() {
    if (this.looking_at_path == "") {
      // Go to root
      this.viewing_contents = this.bunch_of_bookmarks.root.get_content();
    } else {
      // Go to a directory
      this.current_folder = this.bunch_of_bookmarks.get_folder(this.looking_at_path);
      if (this.current_folder !== undefined) {
        this.viewing_contents = this.current_folder.get_content();
      }
    }
    // this.bookmarks_scroller.scrollTo({ xOffset: 0, yOffset: this.scroll_area_height * 0.75, animation: false });
  }

  visible_when_no_operating() {
    if (this.exporting_bookmarks || this.adding_folder || this.adding_bookmark || this.importing_bookmarks) {
      return Visibility.None;
    } else {
      return Visibility.Visible;
    }
  }

  // Operations

  scroll_bookmarks() {
    if (this.bookmarks_scroll_by == 0) {
      return;
    }
    // this.swapping_offset_timeout = 300;
    if (this.bookmarks_scroll_by > 0) {
      this.swapping_offset_downer += this.bookmarks_scroll_by;
      this.bookmarks_scroller.scrollBy(0, this.bookmarks_scroll_by);
    } else {
      this.swapping_offset_upper -= this.bookmarks_scroll_by;
    }
    this.bookmarks_scroll_by = 0;
  }

  new_folder() {
    if (this.add_label == "") {
      // Cannot add for no label.
      this.uni_fail_prompt_gateway = $r('app.string.Fail_desc_no_name');
      return;
    }
    let result = this.bunch_of_bookmarks.add_folder(new folder(this.add_label), this.looking_at_path);

    if (!result) {
      // If add failed
      // Perhaps due to a name crash
      this.uni_fail_prompt_gateway = $r("app.string.Fail_desc_folder_current_name_crash");
      return;
    }

    this.adding_folder = false;
    this.refresh_content_view();
    this.save_bookmarks();
  }

  new_bookmark() {
    if (this.add_label == "") {
      // Cannot add for no label or no link.
      this.uni_fail_prompt_gateway = $r('app.string.Fail_desc_no_name');
      return;
    }
    if (this.add_link == "") {
      // Cannot add for no label or no link.
      this.uni_fail_prompt_gateway = $r('app.string.Fail_desc_no_link');
      return;
    }

    let rest = this.bunch_of_bookmarks.add_bookmark(new bookmark(this.add_label, this.add_link), this.looking_at_path);

    if (!rest) {
      // If add failed
      // Perhaps due to a name crash
      this.uni_fail_prompt_gateway = $r('app.string.Fail_desc_bookmark_current_name_crash');
      return;
    }

    this.adding_bookmark = false;
    this.refresh_content_view();
    this.save_bookmarks();
  }

  go_back() {
    if (this.looking_at_path.includes("/")) {
      // Pop current folder class
      let upper_path = this.looking_at_path.split("/");
      upper_path.pop()
      // Modify looking_at_path to trigger auto update
      this.looking_at_path = upper_path.join("/")
    } else {
      this.looking_at_path = "";
      // If current folder is sitting in root folder
      // or if current folder is exactly the root folder
    }
    // Since change of this.looking_at_path will automatically pull up refresh_root_content()
    // There is no need to add this.refresh_root_content() here manually
  }

  export_bookmarks_html() {
    this.exporting_bookmarks = false;

    document_save_text("Bookmarks_" + Math.round(new Date().getTime() / 1000),
      this.bunch_of_bookmarks.get_export_html().join("\n"))
  }

  import_bookmarks_html() {
    this.importing_bookmarks = false;
    document_pick_to_text().then(result => {
      if (result == "") {
        // Selected an empty file or cancelled selection
        this.uni_fail_prompt_gateway = $r('app.string.Fail_desc_empty_picked_file');
        return;
      }
      let import_result: number = this.bunch_of_bookmarks.import_html(result);
      this.refresh_content_view();
      console.log("[Meow][LinysBookmarks] Import result: " + import_result.toString())
      this.save_bookmarks();

      if (import_result != 0) {
        // Show Fail Prompt
        this.uni_fail_prompt_gateway = $r('app.string.Fail_desc_import_bookmarks');
      }
    })
  }

  save_bookmarks() {
    console.log("[Meow][LinysBookmarks] Started to save HTML to disk!");
    let html_bookmark: string[] = this.bunch_of_bookmarks.get_export_html();
    // kv_store_put("html_bookmarks", html_bookmark.join("\n"));
    sandbox_save('html_bookmarks.html', html_bookmark.join("\n"));
  }

  // Data

  text_path() {
    if (this.looking_at_path == "") {
      if (this.showing_navigator) {
        return $r('app.string.Bookmarks_root_path_expanded');
      } else {
        return $r('app.string.Bookmarks_root_path');
      }
    } else {
      // Normal display
      return "@ " + this.looking_at_path + "/";
    }
  }

  is_right_align() {
    return (this.preferred_hand_left_or_right == 'right' && !this.preferred_hand_reverse_tabs_panel) ||
      (!(this.preferred_hand_left_or_right == 'right') && this.preferred_hand_reverse_tabs_panel);
  }
}

export default meowBookmarks;

@Component
struct bookmarkItem {
  @Prop my_index: number = 0;
  @StorageLink('bunch_of_bookmarks') bunch_of_bookmarks: bunch_of_bookmarks = new bunch_of_bookmarks("meow");
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  @Link looking_at_path: string;
  @Link viewing_contents: unified_item[];
  @Prop parent_path: string;
  @Prop height_of_panel: number;
  // Me
  @State item: unified_item = this.viewing_contents[this.my_index];
  @State my_type: string = this.item.get_item().get_type();
  @State my_label: string = this.item.get_item().get_label();
  @State my_link: string = this.my_type == "bookmark" ? (this.item.get_item() as bookmark).get_link() : "";
  // Settings / Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // UI
  @LocalStorageLink('swapping_bookmarks') @Watch('on_swapping_bookmarks') swapping_bookmarks: boolean = false;
  @LocalStorageLink('bookmarks_scroll_by') bookmarks_scroll_by: number = 0;
  @State show: Visibility = this.swapping_bookmarks ? Visibility.Visible : Visibility.Hidden;
  @State offset_y: number = this.swapping_bookmarks ? 0 : 50;
  @State is_editing: boolean = false;
  bookmark_height_default: number = 42;
  // Animations statuses
  @State edit_label: string = this.my_label;
  @State edit_link: string = this.my_link;
  @LocalStorageLink('swapping_offset_timeout') swapping_offset_timeout: number = 0;
  // Move params
  @State @Watch('on_select_change') select_path_result: string | undefined = undefined;
  @State moving_type: string = "";
  // Dialogs
  @LocalStorageLink('universal_fail_prompt_desc_gateway') uni_fail_prompt_gateway: ResourceStr = "";
  woofBookmarksPathSelector_control: CustomDialogController = new CustomDialogController({
    builder: woofSelectBookmarksPath({
      prompt_title: $r('app.string.Bookmarks_move_title'),
      select: this.select_path_result,
      looking_at_path: this.looking_at_path
    }),
    alignment: DialogAlignment.Center,
    // showInSubWindow: true,
    cornerRadius: 26,
    width: "90%",
  })
  // Colors
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  @Builder
  contents() {
    Row({ space: 10 }) {
      linysSymbol({ symbol_glyph_target: "sys.symbol.rename" })
      TextInput({ text: this.edit_label })
        .fontWeight(FontWeight.Regular)
        .fontColor(this.color_current_font)
        .caretColor(this.color_current_font)
        .selectedBackgroundColor(this.color_current_font)
        .height(capsule_bar_height())
        .layoutWeight(1)
        .onChange((value) => {
          this.edit_label = value;
        })
        .onSubmit(() => {
          if (this.my_type == "folder") {
            this.save_changes_folder();
          } else {
            this.save_changes_bookmark();
          }
          this.is_editing = false;
        })

    } // Edit label
    .width("100%")

    Row({ space: 10 }) {
      linysSymbol({ symbol_glyph_target: "sys.symbol.paperclip" })
      TextInput({ text: this.edit_link })
        .onChange((value) => {
          this.edit_link = value;
        })
        .fontWeight(FontWeight.Regular)
        .fontColor(this.color_current_font)
        .caretColor(this.color_current_font)
        .selectedBackgroundColor(this.color_current_font)
        .layoutWeight(1)
        .onSubmit(() => {
          this.save_changes_bookmark();
          this.is_editing = false;
        })
        .height(capsule_bar_height())

    } // Edit link
    .width("100%")
    .visibility(this.my_type == "bookmark" ? Visibility.Visible : Visibility.None)
    .animation(animation_default())

    Row({ space: 10 }) {
      linysCapsuleButton({ text: "  󰂺  " })// Move
        .onClick(() => {
          if (this.my_type == "folder") {
            this.move_folder();
          }
          if (this.my_type == "bookmark") {
            this.move_bookmark();
          }
          this.is_editing = false;
        })

      linysTimeoutButton({
        text: "  󰀁  ",
        onExecution: () => {
          this.delete_myself()
        }
      }) // Delete

      linysCapsuleButton({ text: "  󰀻  " })// Save
        .onClick(() => {
          if (this.my_type == "folder") {
            this.save_changes_folder()
          }
          if (this.my_type == "bookmark") {
            this.save_changes_bookmark()
          }
          this.is_editing = false;
        })

    } // Buttons of operations
    .justifyContent(this.preferred_hand_left_or_right == 'right' ? FlexAlign.End : FlexAlign.Start)
    .width("100%")
  }

  @Builder
  extra() {
    Row({ space: 8 }) {
      SymbolGlyph($r('sys.symbol.chevron_up'))
        .fontSize(fontSize_Large())
        .fontColor([this.color_current_font])
        .opacity(this.my_index == 0 ? 0.5 : 1)
        .animation(animation_default())
        .onClick(() => {
          this.swapping_offset_timeout = 600;
          if (this.my_index != 0) {
            this.swap(this.my_index, this.my_index - 1);
            this.bookmarks_scroll_by = -this.bookmark_height_default - 5;
          }
        })
      SymbolGlyph($r('sys.symbol.chevron_down'))
        .fontSize(fontSize_Large())
        .fontColor([this.color_current_font])
        .opacity(this.my_index == this.viewing_contents.length - 1 ? 0.5 : 1)
        .animation(animation_default())
        .onClick(() => {
          this.swapping_offset_timeout = 600;
          if (this.my_index != this.viewing_contents.length - 1) {
            this.swap(this.my_index, this.my_index + 1);
            this.bookmarks_scroll_by = this.bookmark_height_default + 5;
          }
        })
    } // Move up and down
    .width(this.swapping_bookmarks ? undefined : 0)
    .animation(animation_default())
  }

  build() {
    linysExpandableCardItem({
      my_label: this.my_label,
      is_editing: this.is_editing,
      my_icon: this.my_type == 'folder' ? $r('sys.symbol.folder') : undefined,
      my_icon_press_edit: $r('sys.symbol.square_and_pencil'),
      default_background_color: this.color_current_secondary,
      onExecution: () => {
        this.on_item_click();
      },
      title_extras: (): void => {
        this.extra();
      },
      content_edit: (): void => {
        this.contents();
      }
    })
      .onAppear(() => {
        setTimeout(() => {
          this.show = Visibility.Visible;
          this.offset_y = 0;
          // Animation of floating up
        }, this.get_animation_timeout())
      })
      .visibility(this.show)
      .offset({ y: this.offset_y })
      .animation(animation_default())
  }

  on_item_click() {
    if (this.swapping_bookmarks) {
      return;
    }
    if (this.my_type == "folder") {
      // Open folder
      this.looking_at_path = this.get_my_path();
      // Will automatically cause meowBookmarks to update the UI list (@Watch)
    } else {
      // Load web
      this.bunch_of_tabs.stop_onWorkingTab()
      this.bunch_of_tabs.loadUrl_onWorkingTab((this.item.get_item() as bookmark).get_link())
    }
  }

  get_animation_timeout() {
    let unit_interval = 40;
    let load_length = this.viewing_contents.length;
    if (load_length < 5) {
      unit_interval = 60;
    } else if (load_length < 10) {
      unit_interval = 40;
    } else {
      unit_interval = 30;
    }
    return Math.min(this.my_index, this.height_of_panel / this.bookmark_height_default) * unit_interval;
  }

  get_my_path() {
    if (this.parent_path == "") {
      return this.my_label;
    } else {
      return this.parent_path + "/" + this.my_label;
    }
  }

  delete_myself() {
    let my_position = "";
    if (this.parent_path == "") {
      my_position = this.my_label;
    } else {
      my_position = this.parent_path + "/" + this.my_label
    }
    if (this.my_type == "bookmark") {
      this.bunch_of_bookmarks.del_bookmark(my_position)
    } else {
      this.bunch_of_bookmarks.del_folder(my_position)
    }
    // Delete myself from this.viewing_contents

    let temp = this.looking_at_path;
    this.looking_at_path = "/refresh";
    this.looking_at_path = temp;
    // Refresh root content
    // Weird as hell but works, fine.

    this.save_bookmarks();
  }

  save_changes_folder() {
    this.item.get_item().set_label(this.edit_label);
    this.my_label = this.edit_label;
    this.bunch_of_bookmarks.reconstruct_cached_plain_bookmarks();
    this.save_bookmarks();
  }

  save_changes_bookmark() {
    this.item.get_item().set_label(this.edit_label);
    (this.item.get_item() as bookmark).set_link(this.edit_link);
    this.my_label = this.edit_label;
    this.my_link = this.edit_link;
    this.bunch_of_bookmarks.reconstruct_cached_plain_bookmarks();
    this.save_bookmarks();
  }

  // Operations

  move_folder() {
    this.moving_type = "folder";
    this.woofBookmarksPathSelector_control.open();
  }

  move_bookmark() {
    this.moving_type = "bookmark";
    this.woofBookmarksPathSelector_control.open();
  }

  save_bookmarks() {
    console.log("[Meow][LinysBookmarks] Started to save HTML to disk!")
    let html_bookmark: string[] = this.bunch_of_bookmarks.get_export_html();
    // kv_store_put("html_bookmarks", html_bookmark.join("\n"));
    sandbox_save('html_bookmarks.html', html_bookmark.join("\n"));
  }

  on_select_change() {
    // Move folder or bookmark

    if (this.select_path_result === undefined) {
      return;
    }

    let operation_result = 0;
    if (this.moving_type == "folder") {
      operation_result = this.bunch_of_bookmarks.move_folder(this.get_my_path(), this.select_path_result);
    } else {
      // if (this.moving_type == "bookmark")
      operation_result = this.bunch_of_bookmarks.move_bookmark(this.get_my_path(), this.select_path_result);
    }

    if (operation_result != 0) {
      // Show Fail Prompt
      if (this.moving_type == "folder") {
        if (operation_result == 2) {
          this.uni_fail_prompt_gateway = $r("app.string.Fail_desc_folder_destination_name_crash"); // name crash
        }
        if (operation_result == 3) {
          this.uni_fail_prompt_gateway =
            $r('app.string.Fail_desc_move_bookmarks_folders'); // sub folder in myself
        }
      } else { // if is a bookmark
        if (operation_result == 2) {
          this.uni_fail_prompt_gateway = $r("app.string.Fail_desc_bookmark_destination_name_crash"); // name crash
        }
      }
    }

    let temp = this.looking_at_path;
    this.looking_at_path = "/refresh";
    this.looking_at_path = temp;

    // Refresh root content
    // Weird as hell but works, fine.

    this.save_bookmarks();
    this.select_path_result = undefined;
  }

  swap(idx_a: number, idx_b: number) {
    this.bunch_of_bookmarks.last_accessed = Date.now();
    let c = this.viewing_contents[idx_a];
    this.viewing_contents[idx_a] = this.viewing_contents[idx_b];
    this.viewing_contents[idx_b] = c;
    this.save_bookmarks();
  }

  on_swapping_bookmarks() {
    if (this.swapping_bookmarks) {
      this.is_editing = false;
    }
  }
}
