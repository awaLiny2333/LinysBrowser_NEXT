import { copy } from '../../utils/clipboard_tools';
import { share_link, share_text } from '../../utils/link_tools';
import { is_legal_ipv4, is_legal_url } from '../../utils/url_tools';
import linysSymbol from '../texts/linysSymbol';

@Component
struct linysPreviewTextActions {
  // Params
  storage: LocalStorage = new LocalStorage();
  @State content: string = '';
  @State visitable: boolean = is_legal_url(this.content, true) || is_legal_ipv4(this.content);
  // Public
  @LocalStorageLink('web_context_menu_show') web_context_menu_show: boolean = false;
  @LocalStorageLink('search_extracted_field_available') search_extracted_field_available: boolean = false;

  build() {
    Scroll() {
      Row() {
        linysSymbol({ symbol_glyph_target: 'sys.symbol.text_clipboard', can_hover: true }) // Copy
          .onClick(() => {
            copy(this.content);
            this.web_context_menu_show = false;
          })
        linysSymbol({ symbol_glyph_target: 'sys.symbol.arrow_right', can_hover: true }) // Visit
          .onClick(() => {
            this.storage.set('universal_new_tab_gateway', [this.content, false]);
            this.web_context_menu_show = false;
          })
          .opacity(is_legal_url(this.content, true) || is_legal_ipv4(this.content) ? 1 : 0.5)
          .enabled(is_legal_url(this.content, true) || is_legal_ipv4(this.content))
        linysSymbol({ symbol_glyph_target: 'sys.symbol.magnifyingglass_house', can_hover: true }) // Search Here
          .onClick(() => {
            let se = this.storage.get('search_extracted_engine') as string;
            let target = se.replaceAll('%s', encodeURIComponent(this.content));
            this.storage.set('universal_new_tab_gateway', [target, false]);
            this.web_context_menu_show = false;
          })
          .opacity(this.search_extracted_field_available ? 1 : 0.5)
          .enabled(this.search_extracted_field_available)
        linysSymbol({ symbol_glyph_target: 'sys.symbol.magnifyingglass', can_hover: true }) // Search Default
          .onClick(() => {
            let se = AppStorage.get('search_engine') as string;
            let target = se.replaceAll('%s', encodeURIComponent(this.content));
            this.storage.set('universal_new_tab_gateway', [target, false]);
            this.web_context_menu_show = false;
          })
        linysSymbol({ symbol_glyph_target: 'sys.symbol.share', can_hover: true }) // Share
          .onClick(() => {
            if (this.getUIContext().getHostContext()) {
              if (is_legal_url(this.content, true) || is_legal_ipv4(this.content)) {
                share_link(this.content, this.content, this.getUIContext().getHostContext()!);
              } else {
                share_text(this.content, this.getUIContext().getHostContext()!);
              }
              this.web_context_menu_show = false;
            }
          })
      } // Buttons
    }
    .scrollBar(BarState.Off)
    .scrollable(ScrollDirection.Horizontal)
    .edgeEffect(EdgeEffect.Spring)
  }
}

export default linysPreviewTextActions;