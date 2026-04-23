import { defaultInnerRadius } from "../../../../catstypicalframework/utils/ui";
import { MooTextModifier } from "../../../../components/common/MooTextModifier";
import { defaultAnimation, getColor, meowThemeColorType, standardSpacing, useEffects } from "../../../../components/settings";
import { isFn, isModifier, keyDisplay } from "../../../../hosts/userdata/keyshortcuts/scripts/helpers";

// Don't want to export this,
// Because doing so would cause these puppies to be seen everywhere in this project.
// But they have random names "row[x]"
// So we'd better constraint them here and no to pollute the other codes. :P
const row1 = ['ESC', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12'];
const row2 = ['TAB', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'];
const row3 = ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'];
const row4 = ['SHIFT', 'Z', 'X', 'C', 'V', 'B', 'N', 'M'];
const row5 = ['CTRL', 'ALT', 'DPAD_LEFT', 'DPAD_UP', 'DPAD_DOWN', 'DPAD_RIGHT'];

/**
 * The keyboard panel component, allowing selecting a legal keyboard shortcut.
 */
@ComponentV2
struct Keyboard {
  @Param @Require @Once initialSelected: string[];
  // Event
  /**
   * Called when the selected keys change.
   */
  @Event onKeyChange: (keys: string[]) => void;

  build() {
    // Rows of keyboards
    Scroll() {
      Column({ space: standardSpacing * 0.75 }) {
        Row({ space: standardSpacing * 0.75 }) {
          Repeat(row1)
            .each((item) => {
              this.Key(item.item);
            });
        };
        Row({ space: standardSpacing * 0.75 }) {
          Repeat(row2)
            .each((item) => {
              this.Key(item.item);
            });
        };
        Row({ space: standardSpacing * 0.75 }) {
          Repeat(row3)
            .each((item) => {
              this.Key(item.item);
            });
        };
        Row({ space: standardSpacing * 0.75 }) {
          Repeat(row4)
            .each((item) => {
              this.Key(item.item);
            });
        };
        Row({ space: standardSpacing * 0.75 }) {
          Repeat(row5)
            .each((item) => {
              this.Key(item.item);
            });
        };
      };
    }
    .borderRadius(defaultInnerRadius)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .scrollable(ScrollDirection.Horizontal);
  }

  @Builder
  Key(key: string) {
    // Builder of a single key
    Text(keyDisplay(key))
      .textAlign(TextAlign.Center)
      .constraintSize({ minWidth: 36 })
      .attributeModifier(new MooTextModifier())
      .padding(standardSpacing)
      .hoverEffect(HoverEffect.Highlight)
      .backgroundColor(useEffects() ? getColor(meowThemeColorType.PRIMARY) : getColor(meowThemeColorType.SECONDARY))
      .border(this.initialSelected.includes(key)
        ? { width: 2, color: getColor(meowThemeColorType.FONT), radius: defaultInnerRadius }
        : { width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth'), radius: defaultInnerRadius })
      .onClick(() => {
        // meow(`Clicked on ${key}, this is ${isModifier(key) ? '' : 'not '}a modifier key.`, 'KeyBoard', meowLevel.WARN);
        animateToImmediately(defaultAnimation(), () => {
          this.clickAction(key);
        });
      });
  }

  /**
   * Called when a key is clicked.
   * @param key The key clicked.
   */
  clickAction(key: string) {
    if (isModifier(key)) {
      // If selected, then deselect, vice versa
      if (this.initialSelected.includes(key)) {
        // Remove key from selected
        if (this.initialSelected.length == 2) {
          // Unless the value key is a function key, or we don't allow removing all modifiers
          // We need to start to care about this if there are only 2 keys remaining.
          if (!isFn(this.initialSelected[0]) && !isFn(this.initialSelected[1])) {
            return;
          }
        }
        this.initialSelected = this.initialSelected.filter(item => item !== key);
        this.onKeyChange(this.initialSelected);
      } else {
        // Add key to selected
        this.initialSelected = [...this.initialSelected, key];
        this.onKeyChange(this.initialSelected);
      }
    } else {
      // Is value.
      if (this.initialSelected.includes(key)) {
        // Do nothing on clicking myself.
        return;
      }
      // Change value to this
      // Remove the original value key from selected, and push this new key into the list

      for (let i = 0; i < this.initialSelected.length; i++) {
        if (!isModifier(this.initialSelected[i])) {
          this.initialSelected.splice(i, 1);
          break;
        }
      }

      this.initialSelected.push(key);
      if (!isFn(key) && this.initialSelected.length == 1) {
        // Grab a modifier key for this.
        this.initialSelected = [...this.initialSelected, 'CTRL'];
      }
      this.onKeyChange(this.initialSelected);
    }
  }
}

export { Keyboard };
