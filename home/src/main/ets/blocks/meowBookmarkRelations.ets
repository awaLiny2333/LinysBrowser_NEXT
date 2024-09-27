import { animation_default } from '../hosts/bunch_of_settings';
import linysText from '../components/linysText';
import linysTitleText from '../components/linysTitleText';

@Component
struct meowBookmarkRelations {
  @Prop relations: string[][];

  build() {
    Column({ space: 8 }) {
      ForEach(this.relations, (item: string[], index: number) => {
        meowRelation({
          relation: item,
          index: index
        })
      })
    }
    .height(this.relations.length * 50 + 20)
    .alignItems(HorizontalAlign.Start)
    .margin({ left: 15, right: 15 })
    .padding(15)
    // .layoutWeight(1)
    .borderRadius(10)
    .backgroundColor($r('app.color.start_window_background'))
    .animation(animation_default())

  }
}

export default meowBookmarkRelations;

@Component
struct meowRelation {
  @Prop relation: string[] = [];
  @Prop index: number;
  @State offset_y: number = 50;
  @State this_visibility: Visibility = Visibility.Hidden;
  @StorageLink('universal_new_tab_gateway') universal_new_tab_gateway: string = "";

  build() {
    Column({ space: 2 }) {
      linysText({
        text: this.relation[0].length == 0 ? "　" : this.relation[0]
      })
      linysText({
        text: this.relation[1]
      })
        .opacity(0.7)
    }
    .alignItems(HorizontalAlign.Start)
    .width("100%")
    .visibility(this.this_visibility)
    .offset({ y: this.offset_y })
    .animation(animation_default())
    .onClick(() => {
      this.universal_new_tab_gateway = this.relation[1];
    })
    .onAppear(() => {
      setTimeout(() => {
        this.offset_y = 0;
        this.this_visibility = Visibility.Visible;
      }, (this.index) * 60)
    })
  }
}