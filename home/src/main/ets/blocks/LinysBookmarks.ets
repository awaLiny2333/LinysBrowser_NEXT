import { bookmark, BunchOfBookmarks, folder, unified_item } from '../hosts/BunchOfBookmarks';
import { BunchOfTabs } from '../hosts/BunchOfTabs';
import { url_resource_to_meow } from '../utils/url_tools';
import LinysSymbol from './LinysSymbol';
import { document_open, document_save } from '../utils/storage_tools';

@Component
struct LinysBookmarks {
  @Link bunch_of_bookmarks: BunchOfBookmarks;
  @Link bunch_of_tabs: BunchOfTabs;
  @Link webViews_ready: boolean;
  @State viewing_contents: unified_item[] = this.bunch_of_bookmarks.root.get_content();
  @State @Watch('refresh_root_content') looking_at_path: string = "";
  // Environments
  @State adding_folder: boolean = false;
  @State adding_bookmark: boolean = false;
  @State add_label: string = "";
  @State add_link: string = "";
  // Input interactions
  scroll_controller: Scroller = new Scroller();
  @Prop animation_default: AnimateParam;
  @State scroll_area_height: number = 0;

  // Visual effects related

  build() {
    Column() {
      Scroll(this.scroll_controller) {
        Column({ space: 5 }) {
          ForEach(
            this.viewing_contents,
            (item: unified_item, key: number) => {
              BookmarkItem({
                my_index: key,
                bunch_of_tabs: this.bunch_of_tabs, // For loadUrl
                viewing_contents: this.viewing_contents, // For editing
                looking_at_path: this.looking_at_path, // the path of now showing list (directory) on the panel
                webViews_ready: this.webViews_ready, // To ask webViews to show
                height_of_panel: this.scroll_area_height, // for animation params
                parent_path: this.looking_at_path, // for get_my_path()
                animation_default: this.animation_default, // default stuffs
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
        LinysSymbol({ symbol_glyph_target: 'sys.symbol.arrow_left' })
          .visibility(this.looking_at_path == "" ? Visibility.None : Visibility.Visible)
          .animation(this.animation_default)
          .onClick(() => {
            this.go_back();
          }) // Go back button
        Blank()
        LinysSymbol({ symbol_glyph_target: 'sys.symbol.arrow_down_and_rectangle_on_rectangle' })
          .onClick(() => {
            this.import_bookmarks_html();
          }) // Import bookmarks button
        LinysSymbol({ symbol_glyph_target: 'sys.symbol.arrow_right_up_and_square' })
          .onClick(() => {
            this.export_bookmarks_html();
          }) // Export bookmarks button
        LinysSymbol({ symbol_glyph_target: 'sys.symbol.folder_badge_plus' })
          .onClick(() => {
            this.add_label = "";
            this.adding_bookmark = false;
            this.adding_folder = !this.adding_folder;
          }) // Add folder button
        LinysSymbol({ symbol_glyph_target: 'sys.symbol.plus_square' })
          .onClick(() => {
            this.add_label = this.bunch_of_tabs.workingTab().title;
            this.add_link = url_resource_to_meow(this.bunch_of_tabs.workingTab().url);
            this.adding_folder = false;
            this.adding_bookmark = !this.adding_bookmark;
          }) // Add bookmark button
      } // Operation buttons
      .width("100%")
      .margin({ bottom: 5 })

      Scroll() {
        Column({ space: 10 }) {
          Row({ space: 10 }) {
            LinysSymbol({ symbol_glyph_target: "sys.symbol.rename" })
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
          } // Edit Label TextInput
          .width("100%")

          Row({ space: 10 }) {
            LinysSymbol({ symbol_glyph_target: "sys.symbol.paperclip" })
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
          } // Edit link TextInput
          .width("100%")
          .visibility(this.adding_bookmark ? Visibility.Visible : Visibility.None)
          .animation(this.animation_default)

          Row() {
            Blank()
            Button("  󰀓  ")
              .type(ButtonType.Capsule)
              .backgroundColor($r("app.color.font_color_title"))
              .fontColor($r('app.color.start_window_background'))
              .fontSize(22)
              .onClick(() => {
                if (this.adding_folder) {
                  this.new_folder()
                }
                if (this.adding_bookmark) {
                  this.new_bookmark()
                }
              })
          } // Submit add button
          .width("100%")
        }
        .width("100%")
      } // Edit panel
      .height((this.adding_bookmark ? 150 : 0) + (this.adding_folder ? 100 : 0))
      .animation(this.animation_default)
      .scrollBar(BarState.Off)

      Text("@ " + (this.looking_at_path == "" ? "(～o￣3￣)～" : this.looking_at_path + "/"))
        .fontColor($r('app.color.font_color_title'))
        .fontWeight(FontWeight.Medium)
        .fontSize(18)
        .textAlign(TextAlign.End)
        .width("100%")
        .margin({ top: 5 })
        .opacity(0.7)
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
    this.refresh_root_content();
  }

  new_bookmark() {
    if (this.add_label == "" || this.add_link == "") {
      // Cannot add for no label or no link.
      return;
    }
    this.bunch_of_bookmarks.add_bookmark(
      new bookmark(this.add_label, this.add_link), this.looking_at_path);
    this.refresh_root_content();
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

  export_bookmarks_html() {
    document_save("Bookmarks_" + Math.round(new Date().getTime() / 1000) + ".html",
      this.bunch_of_bookmarks.export_html().join("\n"))
  }

  import_bookmarks_html() {
    document_open().then(result => {
      let import_result: number = this.bunch_of_bookmarks.import_html(result);
      this.refresh_root_content();
      console.log("[Meow][LinysBookmarks] Import result: " + import_result.toString())
    })
  }
}

export default LinysBookmarks;

@Component
struct BookmarkItem {
  @Prop my_index: number = 0;
  @Link bunch_of_tabs: BunchOfTabs;
  @Link webViews_ready: boolean;
  @Link looking_at_path: string;
  @Link viewing_contents: unified_item[];
  @Prop parent_path: string;
  @Prop height_of_panel: number;
  @Prop animation_default: AnimateParam;
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

  // Edit inputs

  build() {
    Column() {
      Row() {
        Text(this.label)// Title
          .fontColor(!this.pressing ? $r('app.color.font_color_title') : $r('app.color.block_color'))
          .fontWeight(!this.pressing ? FontWeight.Normal : FontWeight.Medium)
          .animation(this.animation_default)
          .padding({ left: 2 })
          .fontSize(18)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
        if (this.type == "folder") {
          SymbolGlyph($r(!this.pressing ? 'sys.symbol.folder' : 'sys.symbol.chevron_right'))
            .fontSize(20)
            .fontWeight(!this.pressing ? FontWeight.Normal : FontWeight.Medium)
            .fontColor([!this.pressing ? $r('app.color.font_color_title') : $r('app.color.block_color')])
            .animation(this.animation_default)
        } // Folder Icon
        Scroll() {
          SymbolGlyph($r('sys.symbol.square_and_pencil'))
            .fontSize(20)
            .fontColor([$r('app.color.block_color')])
        } // Edit Icon
        .scrollable(ScrollDirection.Horizontal)
        .width(this.press_timing_ok ? 22 : 0)
        .margin({ left: this.press_timing_ok ? 10 : 0 })
        .animation(this.animation_default)

      } // Bookmark button
      .border({
        radius: this.editing ? { topLeft: 10, topRight: 10 } : 10,
        width: 2,
        color: "transparent"
      })
      .backgroundColor(this.pressing ? $r('app.color.font_color_title') : $r('app.color.block_color'))
      .animation(this.animation_default)
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
            LinysSymbol({ symbol_glyph_target: "sys.symbol.rename" })
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
          } // Edit label
          .width("100%")

          Row({ space: 10 }) {
            LinysSymbol({ symbol_glyph_target: "sys.symbol.paperclip" })
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
          } // Edit link
          .width("100%")
          .visibility(this.type == "bookmark" ? Visibility.Visible : Visibility.None)
          .animation(this.animation_default)

          Row({ space: 10 }) {
            Blank()
            Button("  󰀁  ")// Delete
              .type(ButtonType.Capsule)
              .backgroundColor($r("app.color.font_color_title"))
              .fontColor($r('app.color.start_window_background'))
              .fontSize(22)
              .onClick(() => {
                this.delete_myself()
              })
            Button("  󰀻  ")// Save
              .type(ButtonType.Capsule)
              .backgroundColor($r("app.color.font_color_title"))
              .fontColor($r('app.color.start_window_background'))
              .fontSize(22)
              .onClick(() => {
                if (this.type == "folder") {
                  this.save_changes_folder()
                }
                if (this.type == "bookmark") {
                  this.save_changes_bookmark()
                }
                this.editing = false;
              })
          } // Buttons of operations
          .width("100%")
        }
        // .margin({ top: this.editing ? 1 : 0 })
        .padding({
          top: 4,
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
          (this.type == "bookmark" ? 157 : 0) + (this.type == "folder" ? 107 : 0)
      )
      .animation(this.animation_default)
      .scrollBar(BarState.Off)
    }
    .width("100%")
    .visibility(this.show)
    .offset({ y: this.offset_y })
    .animation(this.animation_default)
    .onAppear(() => {
      setTimeout(() => {
        this.show = Visibility.Visible;
        this.offset_y = 0;
        // Animation of floating up
      }, Math.min(this.my_index, this.height_of_panel / this.bookmark_height_default) * 60)
      setInterval(() => {
        if (this.pressing) {
          this.press_timing += 1;
        } else {
          this.press_timing = 0;
        }
        this.press_timing_ok = this.press_timing > 16;
        // Count press time
      }, 10)
    })
  }

  get_my_path() {
    if (this.parent_path == "") {
      return this.label;
    } else {
      return this.parent_path + "/" + this.label;
    }
  }

  delete_myself() {
    this.viewing_contents.splice(this.my_index, 1)
    // Delete myself from this.viewing_contents

    let temp = this.looking_at_path;
    this.looking_at_path = "/refresh";
    this.looking_at_path = temp;
    // Refresh root content
    // Weird as hell but works, fine.
  }

  save_changes_folder() {
    this.item.get_item().set_label(this.edit_label);
    this.label = this.edit_label;
  }

  save_changes_bookmark() {
    this.item.get_item().set_label(this.edit_label);
    (this.item.get_item() as bookmark).set_link(this.edit_link);
    this.label = this.edit_label;
    this.link = this.edit_link;
  }
}