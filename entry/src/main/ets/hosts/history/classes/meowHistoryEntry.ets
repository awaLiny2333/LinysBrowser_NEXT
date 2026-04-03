/**
 * The basic unit of history entries.
 * Contains title, url and time.
 *
 * Provides tokenizeSelf() function to tokenize the entry's title and url together into a collections.Set<string> of tokens for later use.
 * For instance, after pushing a new entry into the chunk, the meowHistorian would request an index rebuild.
 * During the rebuild, old entries won't need to be tokenized again in the rebuild process if they have already been done so.
 * This saves a lot of time as tokenize() is theoratically time consuming.
 *
 * Theoraticlly clearing this.tokens (resetting it to undefined) does no physical harm to the system.
 * Because during index building, this.tokens is always checked before use.
 * If the meowHistorian found this.tokens to be undefined, it would call tokenizeSelf() to generate the tokens.
 * It just gets things slower.
 *
 * But this is meaning less because contents in an entry won't bechanged throughout the life.
 * There is no point in clearing this.tokens.
 */

import { collections } from "@kit.ArkTS";
import { meow, meowLevel } from "../../../catstypicalframework/utils/catsLogger";
import { tokenize } from "../scripts/helpers";

@Sendable
export class meowHistoryEntry {
  title: string;
  url: string;
  time: number;
  // Generated ↓
  tokens: collections.Set<string> | undefined;

  constructor(title: string, url: string, time: number) {
    this.title = title;
    this.url = url;
    this.time = time;
  }

  /**
   * Converts this meowHistory entry to a string representation.
   * @returns The string representation of the meowHistory entry.
   */
  toString(): string {
    // trim if too long
    if (this.url.length > 32) this.url = this.url.substring(0, 32) + ' ...';
    if (this.title.length > 32) this.title = this.title.substring(0, 32) + ' ...';
    return `[${this.url}] ${this.title} @ ${this.time} (${new Date(this.time).toLocaleString()})`;
  }

  /**
   * Ensures that this meowHistory entry is tokenized. Process entry to tokens if it doesn't have tokens built yet.
   */
  tokenizeSelf() {
    if (this.tokens) {
      return; // Do nothing
    }

    // Decode Url
    let decodedUrl: string;
    try {
      decodedUrl = decodeURI(this.url);
    } catch (e) {
      try {
        decodedUrl = decodeURI(this.url.replaceAll('%S', ''));
        meow(`Troubles in decoding URL: ${this.url}, error: ${e}, but it worked after trying to replace %S with ''!`, 'meowHistoryEntry][tokenizeSelf', meowLevel.WARN);
        decodedUrl = this.url;
      } catch (e) {
        meow(`Failed to decode URL: ${this.url}, error: ${e}, replacing %S didn't save it so we are going to use the original (encoded) url directly.`, 'meowHistoryEntry][tokenizeSelf', meowLevel.WARN);
        decodedUrl = this.url;
      }
    }

    // Generate tokens
    this.tokens = tokenize(decodedUrl + ' ' + this.title);
  }
}
