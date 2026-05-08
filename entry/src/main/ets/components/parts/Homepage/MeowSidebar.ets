import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { SymbolButton } from "../../../dialogs/parts/WoofCatsDev/parts/common/SymbolButton";
import { WoofHistoryPanel } from "../../../dialogs/parts/WoofHistory/parts/Panel";
import { meowUiHost, SidebarContentsStatus } from "../../../hosts/system/windows/classes/meowUiHost";
import { sidebarShouldBeOnTheRight, standardSpacing } from "../../settings";
import { sidebarWidth } from "../../statuses";
import { MeowBookmarksPanel } from "../Bookmarks/MeowBookmarksPanel";

@ComponentV2
struct MeowSidebar {
  @Param @Require myLayout: meowLayout;
  @Param @Require myUi: meowUiHost;

  build() {
    Column({ space: standardSpacing * 0.75 }) {
      Column() {
        if (this.myUi.sidebarStatus == SidebarContentsStatus.SCRATCHING_BOARD) {
          // TODO: scratching board UI.
        } else if (this.myUi.sidebarStatus == SidebarContentsStatus.BOOKMARKS) {
          MeowBookmarksPanel({ myUi: this.myUi, needPadding: false });
        } else if (this.myUi.sidebarStatus == SidebarContentsStatus.HISTORY) {
          WoofHistoryPanel({ myLayout: this.myLayout, allowEdit: false, needPadding: false });
        }
      }
      .layoutWeight(1)
      .width('100%');

      Scroll() {
        Row() {
          SymbolButton({
            icon: $r('sys.symbol.doc_rectify'),
            clickAction: () => {
              this.myUi.sidebarStatus = SidebarContentsStatus.SCRATCHING_BOARD;
            }
          });
          SymbolButton({
            icon: $r('sys.symbol.bookmark'),
            clickAction: () => {
              this.myUi.sidebarStatus = SidebarContentsStatus.BOOKMARKS;
            }
          });
          SymbolButton({
            icon: $r('sys.symbol.arrow_counterclockwise_clock'),
            clickAction: () => {
              this.myUi.sidebarStatus = SidebarContentsStatus.HISTORY;
            }
          });
        };
      }
      .scrollable(ScrollDirection.Horizontal)
      .edgeEffect(EdgeEffect.Spring);
    }
    .alignItems(sidebarShouldBeOnTheRight() ? HorizontalAlign.End : HorizontalAlign.Start)
    .width(sidebarWidth(this.myLayout))
    .height('100%');
  }
}

export { MeowSidebar };
