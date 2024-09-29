import { bunch_of_bookmarks } from '../hosts/bunch_of_bookmarks';

export function get_relations(label_link_array: string[][], key: string, max_result_number?: number) {
  if (key.length == 0) {
    return [];
  }
  if (max_result_number == undefined) {
    // Default fall back
    max_result_number = 5;
  }

  // Get first filtered related items
  let related_items: string[][] = [];
  let relation_levels: number[] = [];
  for (let index = 0; index < label_link_array.length; index++) {
    let this_relation_level = get_relation_level(label_link_array[index], key);
    if (this_relation_level < 0) {
    } else {
      relation_levels.push(this_relation_level);
      related_items.push(label_link_array[index]);
    }
  }

  // Limited quick selection sort
  let search_numbers = Math.min(related_items.length, max_result_number);
  let result: string[][] = [];
  let chosen_links: string[] = [];
  for (let index = 0; index < search_numbers; index++) {
    // Search for search_number results
    let minimum = 0;
    let found = false;
    while (minimum < relation_levels.length - 1 && chosen_links.includes(related_items[minimum][1])) {
      // Go to the first item that has not been chosen
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

function get_relation_level(label_link: string[], key: string) {
  let index_of_label = label_link[0].toUpperCase().indexOf(key.toUpperCase());
  let index_of_link = label_link[1].toUpperCase().indexOf(key.toUpperCase());
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