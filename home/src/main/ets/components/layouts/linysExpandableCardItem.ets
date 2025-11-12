import { animation_default, fontSize_Large, fontSize_Normal } from '../../hosts/bunch_of_defaults';

@Component
struct linysExpandableCardItem {
  // Data
  @Prop my_label: ResourceStr = 'Label';
  @Prop my_icon: Resource | undefined = undefined; // $r('sys.symbol.cat_fill')
  @Prop my_icon_press_edit: Resource | undefined = $r('sys.symbol.square_and_pencil'); // $r('sys.symbol.square_and_pencil')
  @Link is_editing: boolean;
  // UI effects
  @Prop default_background_color: ResourceColor | undefined = undefined;
  @Prop show_border: boolean | undefined = undefined;
  @State is_pressing: boolean = false;
  @State is_dragging: boolean = false;
  @State is_press_timing_ok: boolean = false;
  press_start_time: number | undefined = undefined;
  button_height_default: number = 42;
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // execution
  onExecution?: () => void;
  onDrag?: (event: DragEvent) => void;
  // Pass in content components
  @BuilderParam content_edit: () => void;
  @BuilderParam title_extras: () => void;
  // Actions
  @Prop can_drag: boolean = false;
  up_timeout_id: number | undefined = undefined;

  build() {
    Column() {
      Row() {
        Text(this.my_label)// Title
          .fontColor(!this.is_pressing ? this.color_current_font : this.color_current_secondary)
          .fontWeight(!this.is_pressing ? FontWeight.Regular : FontWeight.Bold)
          .animation(animation_default())
          .padding({ left: 2 })
          .fontSize(fontSize_Normal())
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)

        if (this.title_extras) {
          this.title_extras();
        }

        if (this.my_icon) {
          SymbolGlyph(this.my_icon)
            .fontSize(fontSize_Large())
            .fontWeight(!this.is_pressing ? FontWeight.Regular : FontWeight.Medium)
            .fontColor([!this.is_pressing ? this.color_current_font : this.color_current_secondary])
            .animation(animation_default())
            .margin({ left: 10 })
        } // Folder Icon

        if (this.my_icon_press_edit) {
          SymbolGlyph(this.my_icon_press_edit)
            .fontSize(fontSize_Large())
            .fontWeight(!this.is_pressing ? FontWeight.Regular : FontWeight.Medium)
            .fontColor([!this.is_pressing ? this.color_current_font : this.color_current_secondary])
            .width(this.is_press_timing_ok ? 22 : 0)
            .margin({ left: this.is_press_timing_ok ? 10 : 0 })
            .animation(animation_default())
        }
      } // Item Button with Title
      .borderRadius(this.is_editing ? { topLeft: 7, topRight: 7 } : 7)
      .backgroundColor(this.is_pressing ? this.color_current_font : (this.default_background_color || this.color_current_primary))
      .animation(animation_default())
      .clip(true)
      .padding({ left: 10, right: 10 })
      .alignItems(VerticalAlign.Center)
      .alignRules({
        middle: { anchor: "__container__", align: HorizontalAlign.Center },
        top: { anchor: "__container__", align: VerticalAlign.Top }
      })
      .onTouch((event) => {
        // console.log(`[linysExpandableCardItem][uwu] ${event.type}, is_dragging=${this.is_dragging}`)
        if (this.is_dragging) {
          return;
        }
        // Up
        if (event.type == TouchType.Up || event.type == TouchType.Cancel) {
          clearTimeout(this.up_timeout_id);
          this.up_timeout_id = setTimeout(() => {
            console.log('[linysExpandableCardItem] onTouch UP or CANCEL!')
            this.is_pressing = false;
            this.press_start_time = undefined;
            this.is_press_timing_ok = false;
          }, 10)
          return;
        }
        // If is touching
        this.is_pressing = true;
        if (this.press_start_time) {
          // See if time is enough to trigger long press action
          let press_time = Date.now() - this.press_start_time;
          if (press_time > 160) {
            this.is_press_timing_ok = true;
          }
        } else {
          // Set press start time
          console.log('[linysExpandableCardItem] onTouch DOWN!')
          this.press_start_time = Date.now();
        }
      })
      .onClick(() => {
        // If touch ends, determine if is click or long press
        if (this.is_press_timing_ok) {
          // Toggle Edit Panel
          this.is_editing = !this.is_editing;
          this.is_press_timing_ok = false;
        } else {
          // Click Execution
          if (this.onExecution) {
            this.onExecution();
          }
        }
      })
      .height(this.button_height_default)
      .onMouse((e) => {
        if (e.button == MouseButton.Right && e.action == MouseAction.Press) {
          // Right click
          this.is_editing = !this.is_editing;
        }
      })

      Column({ space: 10 }) {
        if (this.content_edit) {
          this.content_edit();
        }
      } // Contents
      .padding({
        top: 6,
        left: 14,
        right: 14,
        bottom: 14
      })
      .backgroundColor((this.default_background_color || this.color_current_primary))
      .border({
        radius: { bottomLeft: 7, bottomRight: 7 }
      })
      .visibility(this.is_editing ? Visibility.Visible : Visibility.None)
      .animation(animation_default())
    }
    .border(this.show_border === undefined ? undefined : {
      radius: 10,
      width: 2,
      color: this.show_border ? this.color_current_font : "transparent"
    })
    .width("100%")
    .animation(animation_default())
    .draggable(this.can_drag)
    .onDragStart((event) => {
      this.is_dragging = true;
      console.log('[linysExpandableCardItem] onDragStart!');
      this.press_start_time = undefined;
      this.is_pressing = false;
      this.is_press_timing_ok = false;
      this.is_editing = false;
      if (this.onDrag) {
        this.onDrag(event);
      }
    })
    .onDragEnd(() => {
      this.is_dragging = false;
      console.log('[linysExpandableCardItem] onDragEnd!');
    })
  }
}

export default linysExpandableCardItem;