import { bookmark, bunch_of_bookmarks, folder, unified_item } from '../hosts/bunch_of_bookmarks';
import { bunch_of_tabs } from '../hosts/bunch_of_tabs';
import { url_resource_to_meow } from '../utils/url_tools';
import linysSymbol from '../components/linysSymbol';
import { document_open, document_save } from '../utils/storage_tools';
import {
  animation_default,
  capsule_bar_height,
  click_effect_default,
  fontSize_Large,
  fontSize_Normal
} from '../hosts/bunch_of_settings';
import { kv_store_get, kv_store_put } from '../utils/kv_store_tools';
import linysShowButton from '../components/linysShowButton';

@Component
struct meowBookmarks {
  @Link bunch_of_bookmarks: bunch_of_bookmarks;
  @Link bunch_of_tabs: bunch_of_tabs;
  @Link webViews_ready: boolean;
  @State viewing_contents: unified_item[] = this.bunch_of_bookmarks.root.get_content();
  @State @Watch('refresh_root_content') looking_at_path: string = "";
  // Environments
  @State add_label: string = "";
  @State add_link: string = "";
  @State adding_folder: boolean = false;
  @State adding_bookmark: boolean = false;
  @State importing_bookmarks: boolean = false;
  @State exporting_bookmarks: boolean = false;
  // Input interactions
  scroll_controller: Scroller = new Scroller();
  @State scroll_area_height: number = 0;
  @State bookmark_load_from_disk_ok: boolean = false;

  // Visual effects related

  aboutToAppear(): void {
    kv_store_get("html_bookmarks").then(result => {
      if (result as string == "undefined") {
        // First use bookmarks
      } else {
        let html_bookmarks = result as string;
        this.bunch_of_bookmarks.import_html(html_bookmarks, true);
        this.refresh_root_content();
        this.bookmark_load_from_disk_ok = true;
      }
    })
  }

  build() {
    Column() {
      Scroll(this.scroll_controller) {
        Column({ space: 5 }) {
          ForEach(
            this.viewing_contents,
            (item: unified_item, key: number) => {
              bookmarkItem({
                my_index: key,
                bunch_of_bookmarks: this.bunch_of_bookmarks,
                bunch_of_tabs: this.bunch_of_tabs, // For loadUrl
                viewing_contents: this.viewing_contents, // For editing
                looking_at_path: this.looking_at_path, // the path of now showing list (directory) on the panel
                webViews_ready: this.webViews_ready, // To ask webViews to show
                height_of_panel: this.scroll_area_height, // for animation params
                parent_path: this.looking_at_path, // for get_my_path()
              });
            },
          )
        }
        .width("100%")
      } // List of this directory
      .direction(Direction.Rtl)
      .align(Alignment.Bottom)
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

      Row({ space: 12.5 }) {
        linysSymbol({ symbol_glyph_target: 'sys.symbol.arrow_left' })
          .visibility(this.looking_at_path == "" ? Visibility.None : Visibility.Visible)
          .animation(animation_default())
          .onClick(() => {
            this.go_back();
          }) // Go back button
        Blank()
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
          }) // Import bookmarks button
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
          }) // Export bookmarks button

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
          }) // Add folder button

        linysShowButton({
          show: this.adding_bookmark,
          symbol_glyph_target: 'sys.symbol.plus_square',
          text: $r('app.string.Index_add_bookmark_title')
        })
          .onClick(() => {
            this.adding_folder = false;
            this.exporting_bookmarks = false;
            this.importing_bookmarks = false;
            this.add_label = this.bunch_of_tabs.workingTab().title;
            this.add_link = url_resource_to_meow(this.bunch_of_tabs.workingTab().url);
            this.adding_bookmark = !this.adding_bookmark;
          }) // Add bookmark button

      } // Operation buttons
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
              .fontColor($r('app.color.font_color_title'))
              .caretColor($r('app.color.font_color_title'))
              .selectedBackgroundColor($r('app.color.font_color_title'))
              .selectAll(true)
              .layoutWeight(1)
              .onSubmit(() => {
                if (this.adding_folder) {
                  this.new_folder();
                }
              })
              .height(capsule_bar_height())

          } // Edit Label TextInput
          .width("100%")
          .visibility(this.adding_folder || this.adding_bookmark ? Visibility.Visible : Visibility.None)
          .animation(animation_default())

          Row({ space: 10 }) {
            linysSymbol({ symbol_glyph_target: "sys.symbol.paperclip" })
            TextInput({ text: this.add_link })
              .onChange((value) => {
                this.add_link = value;
              })
              .fontWeight(FontWeight.Regular)
              .fontColor($r('app.color.font_color_title'))
              .caretColor($r('app.color.font_color_title'))
              .selectedBackgroundColor($r('app.color.font_color_title'))
              .selectAll(true)
              .layoutWeight(1)
              .onSubmit(() => {
                this.new_bookmark();
              })
              .height(capsule_bar_height())

          } // Edit link TextInput
          .width("100%")
          .visibility(this.adding_bookmark ? Visibility.Visible : Visibility.None)
          .animation(animation_default())

          Row() {
            Blank()
            Text($r('app.string.Index_select_file'))
              .fontSize(fontSize_Large() - 2)
              .fontColor($r('app.color.font_color_title'))
              .visibility(this.exporting_bookmarks || this.importing_bookmarks ? Visibility.Visible : Visibility.None)
              .margin({ right: 10 })
            Button(this.adding_folder || this.adding_bookmark ? "  󰀓  " : "  󰃟  ")
              .type(ButtonType.Capsule)
              .backgroundColor($r("app.color.font_color_title"))
              .fontColor($r('app.color.start_window_background'))
              .fontSize(fontSize_Large())
              .fontWeight(FontWeight.Medium)
              .height(capsule_bar_height())
              .onClick(() => {
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
              })
              .clickEffect(click_effect_default())

          } // Submit add button
          .width("100%")
          .visibility(this.adding_folder || this.adding_bookmark || this.exporting_bookmarks || this.importing_bookmarks
            ? Visibility.Visible : Visibility.None)
          .animation(animation_default())

        }
        .width("100%")
      } // Edit panel
      .height(this.get_edit_area_height())
      .animation(animation_default())
      .scrollBar(BarState.Off)

      Text("@ " + (this.looking_at_path == "" ? "(～o￣3￣)～" : this.looking_at_path + "/"))
        .fontColor($r('app.color.font_color_title'))
        .fontWeight(FontWeight.Medium)
        .fontSize(fontSize_Normal())
        .textAlign(TextAlign.End)
        .width("100%")
        .margin({ top: 5 })
        .opacity(0.7)
        .animation(animation_default())

      // Path indicator
    } // List of directory, Operation buttons and edit TextInputs
    .justifyContent(FlexAlign.End)
    .padding(10)
    .width("100%")
    .height("100%")
  }

  new_folder() {
    if (this.add_label == "") {
      // Cannot add for no label.
      return;
    }
    this.bunch_of_bookmarks.add_folder(new folder(this.add_label), this.looking_at_path);
    this.adding_folder = false;
    this.refresh_root_content();
    this.save_html_to_kv_store();
  }

  new_bookmark() {
    if (this.add_label == "" || this.add_link == "") {
      // Cannot add for no label or no link.
      return;
    }
    this.bunch_of_bookmarks.add_bookmark(
      new bookmark(this.add_label, this.add_link), this.looking_at_path);
    this.adding_bookmark = false;
    this.refresh_root_content();
    this.save_html_to_kv_store();
  }

  go_back() {
    if (this.looking_at_path.includes("/")) {
      let upper_path = this.looking_at_path.split("/");
      upper_path.pop()
      // Pop current folder class
      this.looking_at_path = upper_path.join("/")
    } else {
      this.looking_at_path = "";
      // If current folder is sitting in root folder
      // or if current folder is exactly the root folder
    }
    // Since change of this.looking_at_path will automatically pull up refresh_root_content()
    // There is no need to add this.refresh_root_content() here manually
  }

  refresh_root_content() {
    if (this.looking_at_path == "") {
      this.viewing_contents = this.bunch_of_bookmarks.root.get_content();
      return;
    } else {
      let got_folder = this.bunch_of_bookmarks.get_folder(this.looking_at_path);
      if (got_folder !== undefined) {
        this.viewing_contents = got_folder.get_content();
        return;
      }
    }
  }

  get_edit_area_height() {
    let area_height = 0;
    area_height += this.adding_bookmark ? 145 : 0;
    area_height += this.adding_folder ? 100 : 0;
    area_height += this.importing_bookmarks || this.exporting_bookmarks ? 54 : 0;
    return area_height;
  }

  export_bookmarks_html() {
    this.exporting_bookmarks = false;

    document_save("Bookmarks_" + Math.round(new Date().getTime() / 1000) + ".html",
      this.bunch_of_bookmarks.export_html().join("\n"))
  }

  import_bookmarks_html() {
    this.importing_bookmarks = false;
    document_open().then(result => {
      let import_result: number = this.bunch_of_bookmarks.import_html(result);
      this.refresh_root_content();
      console.log("[Meow][LinysBookmarks] Import result: " + import_result.toString())
      this.save_html_to_kv_store();
    })
  }

  save_html_to_kv_store() {
    console.log("[Meow][LinysBookmarks] Started to save HTML to KVStore!")
    let html_bookmark: string[] = this.bunch_of_bookmarks.export_html();
    kv_store_put("html_bookmarks", html_bookmark.join("\n"));
  }
}

export default meowBookmarks;

@Component
struct bookmarkItem {
  @Prop my_index: number = 0;
  @Link bunch_of_bookmarks: bunch_of_bookmarks;
  @Link bunch_of_tabs: bunch_of_tabs;
  @Link webViews_ready: boolean;
  @Link looking_at_path: string;
  @Link viewing_contents: unified_item[];
  @Prop parent_path: string;
  @Prop height_of_panel: number;
  // Public stuffs
  @State item: unified_item = this.viewing_contents[this.my_index];
  @State type: string = this.item.get_item().get_type();
  @State label: string = this.item.get_item().get_label();
  @State link: string = this.type == "bookmark" ? (this.item.get_item() as bookmark).get_link() : "";
  // Basic this properties
  @State pressing: boolean = false;
  @State show: Visibility = Visibility.Hidden;
  @State offset_y: number = 50;
  @State editing: boolean = false;
  @State press_timing_ok: boolean = false;
  press_timing: number = 0;
  bookmark_height_default: number = 42;
  // Animations statuses
  @State edit_label: string = this.label;
  @State edit_link: string = this.link;
  @State delete_confirm: number = 0;

  // Edit inputs

  build() {
    Column() {
      Row() {
        Text(this.label)// Title
          .fontColor(!this.pressing ? $r('app.color.font_color_title') : $r('app.color.block_color'))
          .fontWeight(!this.pressing ? FontWeight.Normal : FontWeight.Medium)
          .animation(animation_default())
          .padding({ left: 2 })
          .fontSize(fontSize_Normal())
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
        if (this.type == "folder") {
          SymbolGlyph($r(!this.pressing ? 'sys.symbol.folder' : 'sys.symbol.chevron_right'))
            .fontSize(fontSize_Large())
            .fontWeight(!this.pressing ? FontWeight.Normal : FontWeight.Medium)
            .fontColor([!this.pressing ? $r('app.color.font_color_title') : $r('app.color.block_color')])
            .animation(animation_default())
        } // Folder Icon
        Scroll() {
          SymbolGlyph($r('sys.symbol.square_and_pencil'))
            .fontSize(fontSize_Large())
            .fontColor([$r('app.color.block_color')])
        } // Edit Icon
        .scrollable(ScrollDirection.Horizontal)
        .width(this.press_timing_ok ? 22 : 0)
        .margin({ left: this.press_timing_ok ? 10 : 0 })
        .animation(animation_default())

      } // Bookmark button
      .border({
        radius: this.editing ? { topLeft: 10, topRight: 10 } : 10,
        width: 2,
        color: "transparent"
      })
      .backgroundColor(this.pressing ? $r('app.color.font_color_title') : $r('app.color.block_color'))
      .animation(animation_default())
      .padding(10)
      .alignRules({
        middle: { anchor: "__container__", align: HorizontalAlign.Center },
        top: { anchor: "__container__", align: VerticalAlign.Top }
      })
      .onTouch((event) => {
        if (event.type == TouchType.Up) {
          this.pressing = false;
          // If touch ends
        } else {
          this.pressing = true;
          // If touching
        }
      })
      .onClick(() => {
        if (this.press_timing_ok) {
          this.delete_confirm = 0;
          this.editing = !this.editing;
          return;
        } // Toggle Edit Panel
        if (this.type == "folder") {
          this.looking_at_path = this.get_my_path();
          // Will automatically cause LinysBookmarks to update the UI list (@Watch)
        } else {
          this.webViews_ready = true;
          this.bunch_of_tabs.stop_onWorkingTab()
          this.bunch_of_tabs.loadUrl_onWorkingTab((this.item.get_item() as bookmark).get_link())
        } // Open folder or load web
      })
      .height(this.bookmark_height_default)

      Scroll() {
        Column({ space: 10 }) {
          Row({ space: 10 }) {
            linysSymbol({ symbol_glyph_target: "sys.symbol.rename" })
            TextInput({ text: this.edit_label })
              .onChange((value) => {
                this.edit_label = value;
              })
              .fontWeight(FontWeight.Regular)
              .fontColor($r('app.color.font_color_title'))
              .caretColor($r('app.color.font_color_title'))
              .selectedBackgroundColor($r('app.color.font_color_title'))
              .layoutWeight(1)
              .onSubmit(() => {
                if (this.type == "folder") {
                  this.save_changes_folder();
                } else {
                  this.save_changes_bookmark();
                }
                this.editing = false;
              })
              .height(capsule_bar_height())

          } // Edit label
          .width("100%")

          Row({ space: 10 }) {
            linysSymbol({ symbol_glyph_target: "sys.symbol.paperclip" })
            TextInput({ text: this.edit_link })
              .onChange((value) => {
                this.edit_link = value;
              })
              .fontWeight(FontWeight.Regular)
              .fontColor($r('app.color.font_color_title'))
              .caretColor($r('app.color.font_color_title'))
              .selectedBackgroundColor($r('app.color.font_color_title'))
              .layoutWeight(1)
              .onSubmit(() => {
                this.save_changes_bookmark();
                this.editing = false;
              })
              .height(capsule_bar_height())

          } // Edit link
          .width("100%")
          .visibility(this.type == "bookmark" ? Visibility.Visible : Visibility.None)
          .animation(animation_default())

          Row({ space: 10 }) {
            Blank()
            Button("  󰀁  ")// Delete
              .type(ButtonType.Capsule)
              .backgroundColor(this.delete_confirm > 0 ? $r('app.color.start_window_background') :
              $r("app.color.font_color_title"))
              .fontColor(this.delete_confirm > 0 ? $r('app.color.font_color_title') :
              $r('app.color.start_window_background'))
              .border({
                width: 2,
                color: this.delete_confirm > 0 ? $r('app.color.font_color_title') : "transparent"
              })
              .fontSize(fontSize_Large())
              .fontWeight(FontWeight.Medium)
              .height(capsule_bar_height())
              .onClick(() => {
                this.delete_myself()
              })
              .clickEffect(click_effect_default())
              .animation(animation_default())

            Button("  󰀻  ")// Save
              .type(ButtonType.Capsule)
              .backgroundColor($r("app.color.font_color_title"))
              .fontColor($r('app.color.start_window_background'))
              .fontSize(fontSize_Large())
              .fontWeight(FontWeight.Medium)
              .height(capsule_bar_height())
              .onClick(() => {
                if (this.type == "folder") {
                  this.save_changes_folder()
                }
                if (this.type == "bookmark") {
                  this.save_changes_bookmark()
                }
                this.editing = false;
              })
              .clickEffect(click_effect_default())

          } // Buttons of operations
          .width("100%")
        }
        .padding({
          top: 6,
          left: 14,
          right: 14,
          bottom: 14
        })
        .backgroundColor($r('app.color.block_color'))
        .border({
          radius: { bottomLeft: 10, bottomRight: 10 }
        })

      } // Edit panel
      .height(
        !this.editing ? 0 :
          (this.type == "bookmark" ? 145 : 0) + (this.type == "folder" ? 100 : 0)
      )
      .visibility(this.editing ? Visibility.Visible : Visibility.None)
      .animation(animation_default())
      .scrollBar(BarState.Off)
      .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.PARENT_FIRST })

    }
    .width("100%")
    .visibility(this.show)
    .offset({ y: this.offset_y })
    .animation(animation_default())
    .onAppear(() => {
      setTimeout(() => {
        this.show = Visibility.Visible;
        this.offset_y = 0;
        // Animation of floating up
      }, this.get_animation_timeout())
      setInterval(() => {
        if (this.pressing) {
          this.press_timing += 1;
        } else {
          this.press_timing = 0;
        }
        this.press_timing_ok = this.press_timing > 16;
        // Count press time
        if (this.delete_confirm > 0) {
          this.delete_confirm -= 1;
        }
        // Reset delete confirm
      }, 10)
    })
  }

  get_animation_timeout() {
    let unit_interval = 60;
    let load_length = this.viewing_contents.length;
    if (load_length < 5) {
      unit_interval = 100;
    } else if (load_length < 10) {
      unit_interval = 60;
    } else {
      unit_interval = 40;
    }
    return Math.min(this.my_index, this.height_of_panel / this.bookmark_height_default) * unit_interval;
  }

  get_my_path() {
    if (this.parent_path == "") {
      return this.label;
    } else {
      return this.parent_path + "/" + this.label;
    }
  }

  delete_myself() {
    this.delete_confirm += 300;
    if (this.delete_confirm >= 301) {
      let my_position = "";
      if (this.parent_path == "") {
        my_position = this.label;
      } else {
        my_position = this.parent_path + "/" + this.label
      }
      if (this.type == "bookmark") {
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

      this.save_html_to_kv_store();
    }
  }

  save_changes_folder() {
    this.item.get_item().set_label(this.edit_label);
    this.label = this.edit_label;
    this.save_html_to_kv_store();
  }

  save_changes_bookmark() {
    this.item.get_item().set_label(this.edit_label);
    (this.item.get_item() as bookmark).set_link(this.edit_link);
    this.label = this.edit_label;
    this.link = this.edit_link;
    this.save_html_to_kv_store();
  }

  save_html_to_kv_store() {
    console.log("[Meow][LinysBookmarks] Started to save HTML to KVStore!")
    let html_bookmark: string[] = this.bunch_of_bookmarks.export_html();
    kv_store_put("html_bookmarks", html_bookmark.join("\n"));
  }
}