import { bunch_of_settings } from "./bunch_of_settings";

export class bunch_of_user_agents {
  static list_of_user_agents: user_agent[] = [];

  /**
   * Update last accessed time. This would trigger some refresh on UI layer.
   * */
  static update_last_accessed() {
    AppStorage.setOrCreate('bunch_of_user_agents_update', Date.now());
  }

  /**
   * Sets the global UA.
   * @param idx The index of UA.
   * */
  static set_global_UA(idx: number) {
    if (idx == -99) {
      // Setting index to -99 then the real value
      // Can force refresh @Watch
      // And the index -99 has no meaning
      return;
    }
    AppStorage.setOrCreate('user_agent_selected', idx);
    if (idx <= -1) {
      // If set back to default
      AppStorage.setOrCreate('universal_global_custom_ua_gateway', '');
    } else {
      AppStorage.setOrCreate('universal_global_custom_ua_gateway', bunch_of_user_agents.list_of_user_agents[idx].user_agent_content);
    }
    bunch_of_settings.set('custom_user_agents_selected_index', idx);
  }

  /**
   * Add a new user agent to the current user agent list.
   * @param se A user_agent object, the user agent to be added.
   * */
  static add_user_agent(ua: user_agent) {
    bunch_of_user_agents.list_of_user_agents.push(ua);
    bunch_of_user_agents.update_last_accessed();
  }

  /**
   * Remove a user agent from the current user agent list.
   * @param index A number, the index of the user agent to be removed in the list.
   * */
  static del_user_agent(index: number) {
    bunch_of_user_agents.list_of_user_agents.splice(index, 1);
    bunch_of_user_agents.update_last_accessed();
  }

  /**
   * Export user agents in a specific plain text format.
   * @returns '\n' connected string of user agents in the format of:
   * @example 'Firefox Windows 132\nMozilla/5.0 (Windows NT 10.0; Win64; x64; rv:132.0) Gecko/20100101 Firefox/132.0'
   * */
  static export_string() {
    let export_list: string[] = []
    for (let index = 0; index < bunch_of_user_agents.list_of_user_agents.length; index++) {
      let ua: user_agent = bunch_of_user_agents.list_of_user_agents[index];
      export_list.push(ua.label);
      export_list.push(ua.user_agent_content);
    }
    return export_list.join("\n");
  }

  /**
   * Import user agents in a specific plain text format.
   *
   * In default overwrites whatever was in this list_of_user_agents.
   * @param imp The string in the correct format:
   * @example 'Firefox Windows 132\nMozilla/5.0 (Windows NT 10.0; Win64; x64; rv:132.0) Gecko/20100101 Firefox/132.0'
   * */
  static import_string(imp: string) {
    // Clear
    bunch_of_user_agents.list_of_user_agents = [];
    if (imp == "") {
      return;
    }
    // Import
    let import_list: string[] = imp.split("\n");
    for (let index = 0; index < import_list.length; index += 2) {
      if (import_list[index] != "") {
        bunch_of_user_agents.add_user_agent(new user_agent(import_list[index], import_list[index+1]));
      }
    }
  }
}

export class user_agent {
  label: string;
  user_agent_content: string;

  /**
   * A user_agent object, which consists of a label and the user agent text content.
   * @param label The name of the user agent.
   * @param user_agent_content The content of the user agent.
   */
  constructor(label: string, content: string) {
    this.label = label;
    this.user_agent_content = content;
  }
}
