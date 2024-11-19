import linysCapsuleButton from '../components/linysCapsuleButton';
import linysPathDisplay from '../components/linysPathDisplay';
import linysSymbol from '../components/linysSymbol';
import linysTitleText from '../components/linysTitleText';
import { bookmark, bunch_of_bookmarks, folder, unified_item } from '../hosts/bunch_of_bookmarks';
import { animation_default, fontSize_Large, fontSize_Normal } from '../hosts/bunch_of_defaults';

@CustomDialog
struct woofBookmarksPathSelector {
  controller: CustomDialogController;
  @Link select: string;
  @State scroll_area_height: number = 0;
  @StorageLink('bunch_of_bookmarks') bunch_of_bookmarks: bunch_of_bookmarks = new bunch_of_bookmarks("meow");
  @State viewing_contents: unified_item[] = this.filter_only_folders(this.bunch_of_bookmarks.root.get_content());
  @State @Watch('refresh_dir_content') looking_at_path: string = "";
  @State showing_navigator: boolean = false;

  build() {
    Column({ space: 5 }) {
      linysTitleText({ text: $r('app.string.Bookmarks_move_title') })
        .width("100%")

      Scroll() {
        Column({ space: 5 }) {
          ForEach(
            this.viewing_contents,
            (_unified_item: unified_item, key: number) => {
              bookmarkItem({
                my_index: key,
                viewing_contents: this.viewing_contents, // For editing
                looking_at_path: this.looking_at_path, // the path of now showing list (directory) on the panel
                height_of_panel: this.scroll_area_height, // for animation params
                parent_path: this.looking_at_path, // for get_my_path()
              });
            },
          )

          linysTitleText({ text: "¯\\_(ツ)_/¯" })
            .visibility(this.viewing_contents.length == 0 ? Visibility.Visible : Visibility.None)
            .opacity(0.7)
            .animation(animation_default())

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

      Row({ space: 10 }) {
        linysSymbol({ symbol_glyph_target: 'sys.symbol.arrow_left' })
          .onClick(() => {
            this.go_back();
          })
          .visibility(this.looking_at_path == "" ? Visibility.None : Visibility.Visible)
          .animation(animation_default())

        Blank()

        linysCapsuleButton({ text: "  󰀓  " })
          .onClick(() => {
            if (this.controller) {
              this.select = this.looking_at_path;
              this.controller.close();
            }
          }) // Submit

        linysCapsuleButton({ text: "  󰁖  " })
          .onClick(() => {
            if (this.controller) {
              this.controller.close();
            }
          }) // Cancel
      } // Buttons of submit and cancel
      .width("100%")

      Text(this.looking_at_path == "" ?
        this.showing_navigator ? $r('app.string.Bookmarks_root_path_expanded') : $r('app.string.Bookmarks_root_path')
        : "@ " + this.looking_at_path + "/")
        .fontColor($r('app.color.font_color_title'))
        .fontWeight(FontWeight.Medium)
        .fontSize(fontSize_Normal())
        .textAlign(TextAlign.End)
        .width("100%")
        .margin({ top: 5 })
        .opacity(0.7)
        .animation(animation_default())
        .onClick(() => {
          this.showing_navigator = !this.showing_navigator;
        })

      linysPathDisplay({
        current_viewing_path: this.looking_at_path,
        max_height_screen_percentage: 0.2,
      })
        .height(this.showing_navigator ? undefined : 0)
        .animation(animation_default())
    }
    .backgroundColor($r('app.color.start_window_background'))
    .padding(15)
    .height("80%")
  }

  refresh_dir_content() {
    let got_folder: folder | undefined;
    if (this.looking_at_path == "") {
      got_folder = this.bunch_of_bookmarks.root;
    } else {
      got_folder = this.bunch_of_bookmarks.get_folder(this.looking_at_path);
    }
    if (got_folder !== undefined) {
      this.viewing_contents = this.filter_only_folders(got_folder.get_content());
    }
  }

  filter_only_folders(raw: unified_item[]) {
    let raw_content = raw;
    let folder_only_content: unified_item[] = [];
    for (let index = 0; index < raw_content.length; index++) {
      if (raw_content[index].get_item().get_type() == "folder") {
        folder_only_content.push(raw_content[index]);
      }
    }
    return folder_only_content;
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
}

export default woofBookmarksPathSelector;

@Component
struct bookmarkItem {
  @Prop my_index: number = 0;
  @StorageLink('bunch_of_bookmarks') bunch_of_bookmarks: bunch_of_bookmarks = new bunch_of_bookmarks("meow");
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
          SymbolGlyph($r('sys.symbol.folder'))
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
        if (this.type == "folder") {
          this.looking_at_path = this.get_my_path();
          // Will automatically cause LinysBookmarks to update the UI list (@Watch)
        }
      })
      .height(this.bookmark_height_default)
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
    })
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
      return this.label;
    } else {
      return this.parent_path + "/" + this.label;
    }
  }
}