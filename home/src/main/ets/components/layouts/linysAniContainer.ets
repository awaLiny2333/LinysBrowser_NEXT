import { animation_default } from "../../hosts/bunch_of_defaults";

// @Reusable // Is this ok? Nope, animation would be lost
@Component
struct linysAniContainer {
  // Contents
  @BuilderParam contents: () => void;
  // UI
  @State vis: Visibility = Visibility.None;

  build() {
    Column({ space: 12 }) {
      this.contents();
    }
    .visibility(this.vis)
    .animation(animation_default())
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .onAppear(() => {
      this.vis = Visibility.Visible;
    })
  }
}

export default linysAniContainer;