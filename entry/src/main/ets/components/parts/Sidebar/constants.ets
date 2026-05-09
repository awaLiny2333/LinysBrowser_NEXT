/**
 * Uses the same system of representation as meowButtonsType.
 * Because we may want to store this info / order permanently into the settings as well,
 * like all the customizable buttons.
 */
export enum SidebarPageType {
  BOOKMARKS = 'BKM',
  HISTORIES = 'HIS',
  SCRATCHING_BOARD = 'SCB',
  DOWNLOADS = 'DNL'
}

export const sidebarContentIconArray: string[] = [
  SidebarPageType.BOOKMARKS,
  SidebarPageType.HISTORIES,
  SidebarPageType.SCRATCHING_BOARD,
  SidebarPageType.DOWNLOADS
];

export const defaultSidebarWidth = 360;
