import { TextModifier } from '@kit.ArkUI';
import { getColor } from '../settings';
import { meowThemeColorType, mooTextType, fontSizeSmall, fontSizeMedium } from '../constants';

export class MooTextModifier implements AttributeModifier<TextModifier> {

  colorType: meowThemeColorType = meowThemeColorType.FONT;
  textType: mooTextType = mooTextType.NORMAL;

  constructor(textType: mooTextType = mooTextType.NORMAL, colorType: meowThemeColorType = meowThemeColorType.FONT) {
    this.colorType = colorType;
    this.textType = textType;
  }

  applyNormalAttribute(instance: TextModifier): void {
    instance
      .fontColor(getColor(this.colorType))
      .fontSize(this.textType == mooTextType.NORMAL ? fontSizeSmall : fontSizeMedium)
      .fontWeight(this.textType == mooTextType.NORMAL ? FontWeight.Normal : FontWeight.Medium)
      // .wordBreak(WordBreak.BREAK_ALL)
      .textOverflow({ overflow: TextOverflow.Ellipsis });
  }
}
