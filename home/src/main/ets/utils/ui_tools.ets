/**
 * Gets current tabs style is whether horizontal or not.
 * @returns a boolean. True for is horizontal.
 * */
export function current_tabs_style_is_horizontal() {
  let tablet_mode = AppStorage.get('tablet_mode') as boolean;
  let tabs_style = AppStorage.get('tabs_style') as string;
  let tabs_style_non_tablet_mode = AppStorage.get('tabs_style_non_tablet_mode') as string;
  if (tablet_mode) {
    return tabs_style == 'horizontal';
  } else {
    return tabs_style_non_tablet_mode == 'horizontal';
  }
}