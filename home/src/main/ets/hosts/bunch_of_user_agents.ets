export class bunch_of_user_agents {
  list_of_user_agents: user_agent[] = [];
  last_accessed: number = 0;

  /**
   * A class holding a user_agent[] array, in which there stores user_agent objects.
   */
  constructor() {
    // console.log('[Meow][bunch_of_user_agents] Init success!')
  }

  /**
   * Add a new user agent to the current user agent list.
   * @param se A user_agent object, the user agent to be added.
   * */
  add_user_agent(ua: user_agent) {
    this.list_of_user_agents.push(ua);
    this.last_accessed = Date.now();
  }

  /**
   * Remove a user agent from the current user agent list.
   * @param index A number, the index of the user agent to be removed in the list.
   * */
  del_user_agent(index: number) {
    this.list_of_user_agents.splice(index, 1);
    this.last_accessed = Date.now();
  }

  /**
   * Export user agents in a specific plain text format.
   * @returns '\n' connected string of user agents in the format of:
   * @example 'Firefox Windows 132\nMozilla/5.0 (Windows NT 10.0; Win64; x64; rv:132.0) Gecko/20100101 Firefox/132.0'
   * */
  export_string() {
    let export_list: string[] = []
    for (let index = 0; index < this.list_of_user_agents.length; index++) {
      let ua: user_agent = this.list_of_user_agents[index];
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
  import_string(imp: string) {
    // Clear
    this.list_of_user_agents = [];
    if (imp == "") {
      return;
    }
    // Import
    let import_list: string[] = imp.split("\n");
    for (let index = 0; index < import_list.length; index += 2) {
      if (import_list[index] != "") {
        this.add_user_agent(new user_agent(import_list[index], import_list[index+1]));
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
