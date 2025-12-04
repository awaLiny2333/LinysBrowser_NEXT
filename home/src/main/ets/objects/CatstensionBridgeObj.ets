import { bunch_of_extensions, extension } from '../hosts/bunch_of_extensions';
import { get_message_from_messages } from '../processes/extension_actions';

export class CatsBridge {
  id: string;
  ext: extension;

  constructor(ext: extension) {
    this.id = ext.id;
    this.ext = ext;
    // this.ext = (AppStorage.get('bunch_of_extensions') as bunch_of_extensions).get_extension(this.id)!;
    console.warn(this.log_head('Constructed!'));
  }

  log_head(text: string) {
    const head = `[Extension][${this.ext.name}][${this.ext.id}][CatsBridge]`;
    if (text.substring(0, 1) == '[') {
      return head + text;
    } else {
      return `${head} ` + text;
    }
  }

  chrome_action_setTitle(title: string) {
    this.ext.action_default_title = title;
    (AppStorage.get('bunch_of_extensions') as bunch_of_extensions).update_timestamp();
  }

  chrome_action_getTitle() {
    return this.ext.action_default_title;
  }

  chrome_action_getPopup() {
    return this.ext.action_default_popup;
  }

  chrome_action_setPopup(popup: string, tabId?: number) {
    if (popup == '') {
      this.ext.action_default_popup = undefined;
      try {
        this.ext.controller.loadUrl(this.ext.path_full + '/' + this.ext.action_default_popup);
      } catch (e) {
        console.error(this.log_head('[chrome_action_setPopup] loadUrl Failed: ' + e));
      }
    } else {
      this.ext.action_default_popup = popup;
    }
  }

  chrome_i18n_getAcceptLanguages() {
    return ['en', 'zh_CN'];
  }

  chrome_i18n_getUILanguage() {
    return 'en';
  }

  chrome_i18n_getMessage(messageName: string): string | undefined {
    if (this.ext.messages) {
      return get_message_from_messages(this.ext.messages, messageName);
    } else {
      return undefined;
    }
  }

  /**
   * Test method.
   * @param data Anything to be logged.
   * */
  liny_test(data: string) {
    console.log(`[Extension][CatsBridge][arkTs] Test! data=[${data}]!`);
  }
}

export function CatsBridgeMethods() {
  return ['constructor', 'chrome_action_setTitle', 'chrome_action_getTitle', 'chrome_action_getPopup', 'chrome_action_setPopup', 'chrome_i18n_getAcceptLanguages',
    'chrome_i18n_getUILanguage', 'chrome_i18n_getMessage',
    'liny_test'];
}