export class bunch_of_user_agents {
  list_of_user_agents: user_agent[] = [];

  constructor() {
  }

  add_user_agent(ua: user_agent) {
    this.list_of_user_agents.push(ua);
  }

  del_user_agent(index: number) {
    this.list_of_user_agents.splice(index, 1);
  }

  export_string() {
    let export_list: string[] = []
    for (let index = 0; index < this.list_of_user_agents.length; index++) {
      let ua: user_agent = this.list_of_user_agents[index];
      export_list.push(ua.label);
      export_list.push(ua.content);
    }
    return export_list.join("\n");
  }

  /**
   * @param imp store string
   * @abstract In default overwrites whatever was in this bunch_of_user_agents
   * */
  import_string(imp: string) {
    this.list_of_user_agents = [];
    // Clear
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
  content: string;

  constructor(label: string, content: string) {
    this.label = label;
    this.content = content;
  }
}