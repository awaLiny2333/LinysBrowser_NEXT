import { animation_default, click_effect_default } from '../hosts/bunch_of_defaults';
import linysText from './texts/linysText';

@Component
struct linysPathTree {
  @Link @Watch('on_current_viewing_path_change') current_viewing_path: string;
  @LocalStorageProp('screen_height') screen_height: number = 100;
  @Prop max_height_screen_percentage: number = 0.4;
  @State path_stack: string[] = [];
  @State label_stack: string[] = [];
  scroller: Scroller = new Scroller();
  // Settings / Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // Colors
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');

  build() {
    Scroll(this.scroller) {
      Column({ space: 5 }) {
        Row() {
          linysText({ text: " 󰀧 ", font_weight: FontWeight.Bold });
        }
        .borderRadius(10)
        .padding(10)
        .backgroundColor(this.color_current_secondary)
        .animation(animation_default())
        .clickEffect(click_effect_default())
        .onClick(() => {
          this.current_viewing_path = "";
        })

        ForEach(this.label_stack, (item: string, index: number) => {
          linysPathButton({
            current_viewing_path: this.current_viewing_path,
            label: item,
            my_directory: this.path_stack[index],
          })
        })
      }
      .alignItems(this.preferred_hand_left_or_right == 'right' ? HorizontalAlign.End : HorizontalAlign.Start)
      .width("100%")
      .animation(animation_default())
    }
    .scrollBar(BarState.Off)
    .height(42 + Math.min(this.screen_height * this.max_height_screen_percentage, 45 * this.label_stack.length))
    .animation(animation_default())
    .edgeEffect(EdgeEffect.Spring)
  }

  on_current_viewing_path_change() {
    this.decompose_path(this.current_viewing_path);
  }

  decompose_path(path: string) {
    let split_labels = path.split("/");
    let result: string[] = [];
    let meow_path = "";
    for (let index = 0; index < split_labels.length; index++) {
      let label = split_labels[index];
      if (meow_path == '') {
        meow_path = label;
        result.push(label);
      } else {
        meow_path = meow_path + "/" + label;
        result.push(meow_path);
      }
    }
    this.path_stack = result;
    this.label_stack = split_labels;
    if (this.label_stack.join() == "") {
      this.label_stack = [];
    }
  }
}

export default linysPathTree;

@Component
struct linysPathButton {
  @Prop label: string = "label";
  @Prop my_directory: string = "label";
  @Link current_viewing_path: string;
  // Colors
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');

  build() {
    Row() {
      linysText({ text: this.label });
    }
    .borderRadius(10)
    .padding(10)
    .backgroundColor(this.color_current_secondary)
    .animation(animation_default())
    .clickEffect(click_effect_default())
    .onClick(() => {
      this.current_viewing_path = this.my_directory;
    })
  }
}