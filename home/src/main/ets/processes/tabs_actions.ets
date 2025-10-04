import { bunch_of_tabs } from '../hosts/bunch_of_tabs';
import { url_resource_to_meow } from '../utils/url_tools';

// Data and Statuses



// UI

/**
 * Sets the key 'search_input' in AppStorage with text if is not typing in search box.
 * @param text The new content.
 * */
export function set_search_box_text(text: string) {
  let is_search_input_typing = AppStorage.get('is_search_input_typing') as boolean;
  if (!is_search_input_typing && text) {
    AppStorage.set('search_input', url_resource_to_meow(text))
    // Update Input Search Box
  }
}

/**
 * Determines if extra background is needed, and saves this to key 'extra_background' in AppStorage.
 *
 * An extra background is for those websites who do not have background colors, so that they would be more readable.
 * */
export function determine_extra_background() {
  let need_extra_background = true;
  // Determine background
  if (!AppStorage.get('meowWebView_init_OK') as boolean) {
    need_extra_background = false;
  }

  let tab_urls = AppStorage.get('tab_urls') as string[];
  let tabs = AppStorage.get('bunch_of_tabs') as bunch_of_tabs;

  let main_tab_url = tab_urls[tabs.main_tab_idx];
  main_tab_url = url_resource_to_meow(main_tab_url);
  let sub_tab_url = tab_urls[tabs.sub_tab_idx];
  sub_tab_url = url_resource_to_meow(sub_tab_url);

  if (tabs.sub_tab_idx > -1) {
    // Paralleowing
    if (main_tab_url == 'meow://home' && sub_tab_url == 'meow://home') {
      console.log('[Meow] Extra background false due to paralleow home!')
      need_extra_background = false;
    }
  } else {
    // Not Paralleowing
    if (main_tab_url == 'meow://home') {
      need_extra_background = false;
    }
  }
  AppStorage.set('extra_background', need_extra_background);
}

