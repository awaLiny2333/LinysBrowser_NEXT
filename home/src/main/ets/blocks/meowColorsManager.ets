import linysText from '../components/linysText'
import woofColorSelect from '../dialogs/woofColorSelect'
import { animation_default, capsule_bar_height, click_effect_default, fontSize_Large } from '../hosts/bunch_of_defaults'
import { bunch_of_settings } from '../hosts/bunch_of_settings'

@Component
struct meowColorsManager{
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings();
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor =
    $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor =
    $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor =
    $r('app.color.font_color_title');
  @StorageLink('color_light_primary') color_light_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_light_secondary') color_light_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_light_font') color_light_font: ResourceColor = $r('app.color.font_color_title');
  @StorageLink('color_dark_primary') color_dark_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_dark_secondary') color_dark_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_dark_font') color_dark_font: ResourceColor = $r('app.color.font_color_title');
  // Color editing
  @State delete_confirm: number = 0;

  build() {
    Column({ space: 10 }) {
      linysText({ text: $r('app.string.Appearance_color_scheme_Light') })// Light
        .width("100%")
      Row({ space: 5 }) {
        colorBlock({
          color: this.color_light_primary,
          color_theme_id: 'color_light_primary',
          my_color_mode: 1,
        })
        colorBlock({
          color: this.color_light_secondary,
          color_theme_id: 'color_light_secondary',
          my_color_mode: 1,
        })
        colorBlock({
          color: this.color_light_font,
          color_theme_id: 'color_light_font',
          my_color_mode: 1,
        })
      }
      .padding(6)
      .borderRadius(13.5)
      .backgroundColor($r('sys.color.comp_background_secondary'))
      .width("100%")
      .animation(animation_default())

      linysText({ text: $r('app.string.Appearance_color_scheme_Dark') })// Dark
        .width("100%")
      Row({ space: 5 }) {
        colorBlock({
          color: this.color_dark_primary,
          color_theme_id: 'color_dark_primary',
          my_color_mode: 0,
        })
        colorBlock({
          color: this.color_dark_secondary,
          color_theme_id: 'color_dark_secondary',
          my_color_mode: 0,
        })
        colorBlock({
          color: this.color_dark_font,
          color_theme_id: 'color_dark_font',
          my_color_mode: 0,
        })
      }
      .padding(6)
      .borderRadius(13.5)
      .backgroundColor($r('sys.color.comp_background_secondary'))
      .width("100%")
      .animation(animation_default())

      Row() {
        linysText({
          text: $r("app.string.Color_reset")
        })
        Blank()
        Button('  󰃈  ')// Delete
          .type(ButtonType.Capsule)
          .backgroundColor(this.delete_confirm > 0 ? this.color_current_primary :
          this.color_current_font)
          .fontColor(this.delete_confirm > 0 ? this.color_current_font :
          this.color_current_primary)
          .border({
            width: 2,
            color: this.delete_confirm > 0 ? this.color_current_font : "transparent"
          })
          .fontSize(fontSize_Large())
          .fontWeight(FontWeight.Medium)
          .height(capsule_bar_height())
          .onClick(async () => {
            this.delete_confirm += 300;
            if (this.delete_confirm >= 301) {
              // Reset
              this.bunch_of_settings.reset('color_light_font');
              this.bunch_of_settings.reset('color_light_primary');
              this.bunch_of_settings.reset('color_light_secondary');
              this.bunch_of_settings.reset('color_dark_font');
              this.bunch_of_settings.reset('color_dark_primary');
              this.bunch_of_settings.reset('color_dark_secondary');

              // Figure out what color should i use
              this.color_light_primary = await this.bunch_of_settings.get('color_light_primary') as string;
              this.color_light_secondary =
                await this.bunch_of_settings.get('color_light_secondary') as string;
              this.color_light_font = await this.bunch_of_settings.get('color_light_font') as string;
              this.color_dark_primary = await this.bunch_of_settings.get('color_dark_primary') as string;
              this.color_dark_secondary = await this.bunch_of_settings.get('color_dark_secondary') as string;
              this.color_dark_font = await this.bunch_of_settings.get('color_dark_font') as string;
              this.delete_confirm = 0;
            }
          })
          .clickEffect(click_effect_default())
          .animation(animation_default())
          .onAppear(() => {
            setInterval(() => {
              if (this.delete_confirm > 0) {
                this.delete_confirm -= 1;
              }
              // Reset delete confirm
            }, 10)
          })
      }
      .width("100%")
    } // Colors

  }
}

export default meowColorsManager;

@Component
struct colorBlock {
  @Link @Watch('on_color_set') color: ResourceColor;
  @State color_theme_id: string = 'color_light_font';
  @State my_color_mode: number = 0;
  @StorageProp('currentColorMode') current_color_mode: number = 0;
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings();
  woofColorSelect_control: CustomDialogController = new CustomDialogController({
    builder: woofColorSelect({ color: this.color, dark_mode_color: false, color_theme_id: this.color_theme_id }),
    alignment: DialogAlignment.Center,
    cornerRadius: 16,
    showInSubWindow: true,
    width: "90%",
  });

  build() {
    Column()
      .layoutWeight(1)
      .backgroundColor(this.color)
      .height(80)
      .border(this.current_color_mode == this.my_color_mode ? { width: 2, color: this.color_current_font } :
        { width: 0 })
      .borderRadius(10)
      .clickEffect(click_effect_default())
      .onClick(() => {
        this.woofColorSelect_control = new CustomDialogController({
          builder: woofColorSelect({
            color: this.color,
            dark_mode_color: this.color_theme_id.includes('dark'),
            color_theme_id: this.color_theme_id
          }),
          alignment: DialogAlignment.Center,
          cornerRadius: 16,
          showInSubWindow: true,
          width: "90%",
        });
        this.woofColorSelect_control.open();
      })
  }

  on_color_set() {
    this.bunch_of_settings.set(this.color_theme_id, this.color as string);
  }
}
