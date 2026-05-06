export enum SearchBarStatuses {
  NO_SHIFT, // For non-searches
  CAN_SHIFT, // For valid searches, but the user didn't switch to the "KEYWORDS" view.
  SHIFTED // For valid searches, the user is in the "KEYWORDS" view.
}
