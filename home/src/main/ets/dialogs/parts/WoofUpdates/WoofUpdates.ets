import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { MooTextModifier } from "../../../components/common/MooTextModifier";
import { UniContentCard } from "../../../components/common/UniContentCard";
import { meowFlexOptions, mooTextType, standardSpacing } from "../../../components/constants";
import { meowDialogManager } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { WoofUniFrame } from "../../WoofUniFrame";
import { updateHistories } from "./updateHistories";

@ComponentV2
struct UpdateRecords {
  build() {
    List({ space: standardSpacing }) {
      ListItem(); // To push the space.

      // The list
      Repeat(updateHistories)
        .each((item) => {
          ListItem() {
            UniContentCard({ space: standardSpacing * 1.618 }) {
              // Title & Tags
              Flex(meowFlexOptions) {
                Column() {
                  Text(item.item.version).attributeModifier(new MooTextModifier(mooTextType.TITLE));
                  Text(item.item.date).attributeModifier(new MooTextModifier()).opacity(0.5);
                }.alignItems(HorizontalAlign.Start); // Title
                Blank(); // Spacing
                Repeat(item.item.tag).each((tag) => {
                  Text(tag.item).attributeModifier(new MooTextModifier(mooTextType.TITLE)).padding(standardSpacing * 0.5).opacity(0.5);
                }); // Tags
              };
              // Desc
              Text(item.item.description_zh).attributeModifier(new MooTextModifier()).width('100%');
              Text(item.item.description_en).attributeModifier(new MooTextModifier()).opacity(0.7).width('100%');
            };
          }
          .padding({ left: standardSpacing, right: standardSpacing });
        })
        .virtualScroll();

      ListItem(); // To push the space.
    }
    // .padding({ top: standardSpacing })
    .width('100%')
    .height('auto');
  }
}

@CustomDialog
struct WoofUpdatesDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;

  build() {
    WoofUniFrame({
      controller: this.controller, myDialog: this.myDialog, myLayout: this.myLayout,
      title: $r('app.string.Updates'),
    }) {
      UpdateRecords();
    };
  }
}

export { WoofUpdatesDialog };
