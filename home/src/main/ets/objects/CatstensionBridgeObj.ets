import { bunch_of_extensions, extension } from '../hosts/bunch_of_extensions';

export class CatsBridge {
  id: string;
  ext: extension;

  constructor(id: string) {
    this.id = id;
    this.ext = (AppStorage.get('bunch_of_extensions') as bunch_of_extensions).get_extension(this.id)!;
    console.log(`[Extension][CatsBridge] Constructed! id=${id}`);
  }

  chrome_action_setTitle(title: string) {
    this.ext.action_default_title = title;
    (AppStorage.get('bunch_of_extensions') as bunch_of_extensions).update_timestamp();
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
  return ['constructor', 'chrome_action_setTitle', 'liny_test'];
}