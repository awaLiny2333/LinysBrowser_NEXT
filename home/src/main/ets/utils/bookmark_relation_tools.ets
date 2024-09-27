import { bunch_of_bookmarks } from '../hosts/bunch_of_bookmarks';

export function get_relations(bunch_of_bookmarks: bunch_of_bookmarks, key: string, items?: number) {
  if (key.length == 0) {
    return [];
  }

  let result: string[][] = [];
  let related_items: string[][] = [];
  let relation_levels: number[] = [];
  let raw_database = bunch_of_bookmarks.get_all_plain_bookmarks();

  for (let index = 0; index < raw_database.length; index++) {
    let this_relation_level = get_relation_level(raw_database[index], key);
    if (this_relation_level < 0) {
    } else {
      relation_levels.push(this_relation_level);
      related_items.push(raw_database[index]);
    }
  }

  // console.log("related items " + related_items.toString())

  if (items == undefined) {
    // Default fall back
    items = 5;
  }
  // Limited quick selection sort
  let search_numbers = Math.min(related_items.length, items);

  let chosen_links: string[] = [];

  for (let index = 0; index < search_numbers; index++) {
    // Search for search_number results
    let minimum = 0;
    let found = false;
    // console.log(result.toString())
    while (minimum < relation_levels.length - 1 && chosen_links.includes(related_items[minimum][1])) {
      minimum += 1;
    }

    for (let inner_index = 0; inner_index < relation_levels.length; inner_index++) {
      if (relation_levels[inner_index] <= relation_levels[minimum]) {
        if (!chosen_links.includes(related_items[inner_index][1])) {
          found = true;
          minimum = inner_index;
        }
      }
    }
    if (found) {
      chosen_links.push(related_items[minimum][1]);
      result.push(related_items[minimum]);
      related_items.splice(minimum, 1);
      relation_levels.splice(minimum, 1);
    }
  }

  return result;
}

function get_relation_level(bookmark: string[], key: string) {
  let index_of_label = bookmark[0].toUpperCase().indexOf(key.toUpperCase());
  let index_of_link = bookmark[1].toUpperCase().indexOf(key.toUpperCase());
  if (index_of_label == -1 && index_of_link == -1) {
    return -1;
  }
  if (index_of_label == -1) {
    return index_of_link;
  }
  if (index_of_link == -1) {
    return index_of_label;
  }
  return Math.min(index_of_label, index_of_link);
}