import { locale_messages_of_extension, manifest_of_extension, message_of_manifest_key } from '../processes/extension_actions';

export class bunch_of_extensions {
  extensions: extension[] = [];
}

export class extension {
  id: string;
  path: string;
  path_full: string;
  // Properties
  name: string;
  manifest_version: number;
  version: string;
  description: string | undefined;
  default_locale: string | undefined;
  // icon
  icon_path: string | undefined;
  // action
  action_default_icon_path: string | undefined;
  action_default_title: string | undefined;
  action_default_popup: string | undefined;
  // Objects
  manifest: object | undefined;
  messages: object | undefined;

  constructor(id: string, path: string, path_full: string) {
    this.id = id;
    this.path = path;
    this.path_full = path_full;
    this.manifest = manifest_of_extension(path);
    this.manifest_version = this.manifest?.['manifest_version'];
    this.name = this.manifest?.['name'];
    this.version = this.manifest?.['version'];
    this.description = this.manifest?.['description'];

    // icon
    let icons: object | undefined = this.manifest?.['icons'];
    this.icon_path = getMaxKeyPath(icons);

    // action
    let action_json_obj: object | undefined = this.manifest?.['action'];
    if (action_json_obj) {
      // icon
      let default_icon: object | undefined = action_json_obj?.['default_icon'];
      if (default_icon) {
        let best_path = getMaxKeyPath(default_icon);
        this.action_default_icon_path = best_path;
      }
      // default_title
      this.action_default_title = action_json_obj?.['default_title'];
      this.action_default_popup = action_json_obj?.['default_popup'];
    }

    // i18n
    this.default_locale = this.manifest?.['default_locale'];
    if (this.default_locale) {
      // Do i18n
      this.messages = locale_messages_of_extension(path, this.default_locale);
      if (this.messages) {
        // Update manifest information
        this.name = message_of_manifest_key(this.messages, this.name);
        if (this.description) {
          this.description = message_of_manifest_key(this.messages, this.description);
        }
        if (this.action_default_title) {
          this.action_default_title = message_of_manifest_key(this.messages, this.action_default_title);
        }
      }
    }

    console.log(`[extension] Created! path=${path}, path_full=${path_full}`);
  }
}

/**
 * Finds the icon with largest size.
 * @param obj The default_icon object.
 * @returns A string, path of that icon.
 * */
function getMaxKeyPath(obj: object | undefined): string | undefined {
  if (!obj) {
    return;
  }

  if (typeof obj === 'string') {
    return obj as string;
  }

  const keys = Object.keys(obj);
  if (keys.length === 0) {
    return undefined;
  }
  console.log(`[getMaxKeyPath] keys=${keys},`)

  let maxKey = -Infinity;
  for (let i = 0; i < keys.length; i++) {
    const keyNum = parseInt(keys[i], 10);
    if (keyNum > maxKey) {
      maxKey = keyNum;
    }
  }

  return obj?.[maxKey.toString()];
}