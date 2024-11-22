export class history_record {
  accessed_time: number = Date.now();
  label: string;
  link: string;

  /**
   * history_record item, consists of a label, a link and an accessed timestamp.
   * @param label A string, the name of this bookmark.
   * @param link A string, the link of this bookmark.
   * @param accessed_time A number, the access time of this history (timestamp in milliseconds)
   * */
  constructor(label: string, link: string, accessed_time?: number) {
    if (accessed_time !== undefined) {
      this.accessed_time = accessed_time;
    }
    this.label = label;
    this.link = link;
  }
}

export class bunch_of_history {
  history_list: history_record[] = [];
  private cached_plain_history: string[][] | undefined = undefined;
  private plain_history_default_max_length: number = 500;

  /**
   * A class holding a history_record[] array, in which there stores history_record objects.
   * @param plain_history_max_length The default max length of plain history reconstruction.
   */
  constructor(plain_history_max_length?: number) {
    if (plain_history_max_length) {
      this.plain_history_default_max_length = plain_history_max_length;
    }
  }

  // Settings

  /**
   * Set the max length of cached_plain_history reconstruction products.
   * @param max_length The default max length of plain history reconstruction.
   * */
  set_plain_max_length(max_length: number) {
    this.plain_history_default_max_length = max_length;
    this.reconstruct_plain_history();
  }

  // Use

  /**
   * Adds a history, automatically puts it in the order of time.
   * @param history A history_record object.
   * @param no_reconstruct_plain_history A boolean, will not reconstruct plain history cache if set true.
   * */
  add_history(history: history_record, no_reconstruct_plain_history?: boolean) {
    let insert_position = this.index_of_record_after_time(history.accessed_time);
    if (insert_position < 0) {
      insert_position = this.history_list.length;
    }
    this.history_list.splice(insert_position, 0, history);

    if (no_reconstruct_plain_history) {
      return;
    }
    // reconstruct plain from only part of the records
    this.reconstruct_plain_history();
  }

  /**
   * Removes the history record at the index given.
   *
   * Not recommended when deleting a lot of history records.
   * @param index A number, the index of the target item in the grand history_list.
   * @param no_reconstruct_plain_history A boolean, will not reconstruct plain history cache if set true.
   * */
  remove_history(index: number, no_reconstruct_plain_history?: boolean) {
    this.history_list.splice(index, 1);

    if (no_reconstruct_plain_history) {
      return;
    }
    // reconstruct plain from only part of the records
    this.reconstruct_plain_history();
  }

  /**
   * Removes some selected histories, according to a given array of indices.
   *
   * Should be preferred when deleting a lot of history records.
   * @param selections A number[] array, indicating the indices of the items to be deleted.
   * @param no_reconstruct_plain_history A boolean, will not reconstruct plain history cache if set true.
   * */
  remove_selected_history(selections: number[], no_reconstruct_plain_history?: boolean) {

    selections.sort((a, b) => {
      return a - b;
    });

    let selected = new Array<boolean>(this.history_list.length);

    let result_history: history_record[] = [];

    for (let i = 0; i < selections.length; i++) {
      selected[selections[i]] = true;
    }

    for (let i = 0; i < this.history_list.length; i++) {
      if (selected[i] == true) {
        // Marked to be deleted
      } else {
        result_history.push(this.history_list[i]);
      }
    }

    this.history_list = result_history;

    if (no_reconstruct_plain_history) {
      return;
    }
    // reconstruct plain from only part of the records
    this.reconstruct_plain_history();
  }

  /**
   * Get the index of the first history item whose access_time is not smaller than Target.
   * @param timestamp The limit of earliest timestamp.
   * @returns A positive number, the index.
   * @returns -1 if list is empty.
   * @returns -2 if Target is bigger than all histories.
   * */
  index_of_record_after_time(timestamp: number) {
    if (this.history_list.length == 0) {
      return -1;
    }
    if (timestamp > this.history_list[this.history_list.length - 1].accessed_time) {
      return -2;
    }
    if (timestamp <= this.history_list[0].accessed_time) {
      return 0;
    }

    let start = 0;
    let end = this.history_list.length - 1;
    let mid = Math.floor((start + end) / 2);
    while (start <= end) {
      mid = Math.floor((start + end) / 2);
      let mid_time = this.history_list[mid].accessed_time;
      if (mid_time > timestamp) {
        end = mid - 1;
      }
      if (mid_time < timestamp) {
        start = mid + 1;
      }
      if (mid_time == timestamp) {
        while (mid > 0 && this.history_list[mid].accessed_time == timestamp) {
          // in case of same access_time
          // choose the front-most
          mid -= 1;
        }
        break;
      }
    }
    if (mid + 1 < this.history_list.length && this.history_list[mid].accessed_time < timestamp) {
      // Make sure the history at mid has an access_time equal to or larger than Target timestamp
      mid = mid + 1;
    }
    return mid;
  }

  /**
   * Get the latest slice of history[] array,
   * of a certain length set equal to plain_history_default_max_length,
   * a member variable of bunch_of_history class.
   * @returns The list of history[] being less or equal than plain_history_default_max_length in length.
   * */
  get_latest_slice() {
    let max_length = this.plain_history_default_max_length;
    let slice: history_record[];

    if (this.history_list.length > max_length) {
      slice = this.history_list.slice(this.history_list.length - max_length);
    } else {
      slice = this.history_list;
    }
    return slice;
  }

  /**
   * Get the slice of history[] array in a required time period.
   * @param from_time The earliest timestamp. Default 0.
   * @param to_time The most recent timestamp. Default the last (most recent) timestamp in history_list.
   * @returns The list of history[] in this period.
   * */
  get_part_slice(from_time?: number, to_time?: number) {
    if (this.history_list.length == 0) {
      return [];
    }
    if (from_time == undefined) {
      from_time = 0;
    }
    if (to_time == undefined) {
      to_time = this.history_list[this.history_list.length-1].accessed_time + 1;
    }
    if (from_time > to_time) {
      return [];
    }
    let from_index = this.index_of_record_after_time(from_time);
    let to_index = this.index_of_record_after_time(to_time);
    // Slice
    if (from_index < 0) {
      return [];
    }
    if (to_index < 0) {
      return this.history_list.slice(from_index);
    }
    return this.history_list.slice(from_index, to_index);
  }

  /**
   * Reconstruct the plain history list.
   * @example [['bing', 'www.bing.com'], ['loading', 'www.google.com']]
   * @param from_history_list The source of history records. Would reconstruct the whole bunch_of_history if not given.
   * */
  reconstruct_plain_history(from_history_list?: history_record[]) {
    // Default fallback
    if (from_history_list === undefined) {
      from_history_list = this.get_latest_slice();
    }

    this.cached_plain_history = [];
    for (let index = 0; index < from_history_list.length; index++) {
      let history_item = from_history_list[index];
      this.cached_plain_history.push([history_item.label, history_item.link]);
    }
    console.log("[bunch_of_history][plain_history] Reconstructed plain history! length: " +
    this.cached_plain_history.length.toString());
  }

  /**
   * Get the plain label link array from the cached array.
   * @returns A string[][] array, cached_plain_history, which consists of plain label and link pairs.
   * @example [['bing', 'www.bing.com'], ['loading', 'www.google.com']]
   * */
  get_plain_history(): string[][] {
    if (!this.cached_plain_history) {
      this.reconstruct_plain_history();
    }
    return this.cached_plain_history as string[][];
  }

  // External interaction

  /**
   * Export history records in a specific plain text format.
   * @returns "\n" connected string of history records in the format of:
   * @example 'bing\nbing.com\n127771721'
   * */
  export_string() {
    let export_list: string[] = []
    for (let index = 0; index < this.history_list.length; index++) {
      let history_item: history_record = this.history_list[index];
      export_list.push(history_item.label);
      export_list.push(history_item.link);
      export_list.push(history_item.accessed_time.toString());
    }
    return export_list.join("\n");
  }

  /**
   * Import history records in a specific plain text format.
   *
   * In default overwrites whatever was in this history_list.
   * @param imp The string in the correct format:
   * @example 'bing\nbing.com\n127771721'
   * */
  import_string(imp: string) {

    if (imp.split("\n").length % 3 > 0) {
      // Incorrect format, log an error.
      // Though this is not very likely to happen so often
      // since all the txt files are generated by a fixed algorithm.
      console.error("[ERROR][Meow][bunch_of_history] Import Error: not 3*n length: " + imp)
      return;
    }

    this.history_list = [];
    // Clear
    let import_list: string[] = imp.split("\n");
    for (let index = 0; index < import_list.length; index += 3) {
      if (import_list[index] != "") {
        let new_history_record =
          new history_record(import_list[index], import_list[index+1], Number.parseInt(import_list[index+2]));
        this.add_history(new_history_record, true);
      }
    }
    console.log("[Meow][bunch_of_history] Import history success, length: " + this.history_list.length.toString())
  }
}
