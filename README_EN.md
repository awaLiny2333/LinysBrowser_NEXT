# Liny’s Browser!

[中文](README.md) | [English](README_EN.md)

## Something to Meow Before

The original purpose of this project is to make a decent browser for Liny catself to drive daily
after upgrading to HarmonyOS NEXT. 
But later after realizing that a lot of people out there may also need such an app,
this project is completely made opensource for every body to use.

However, due to the time and stuff arrangement problems by Liny catself, 
issues may not be checked and updates may not be pushed so in time.
In most cases plenty is lagging behind so thank you for your kind understanding.

If you see that the last commit was made some weeks, or over a month ago,
please don't consider this project dead so easily, since
Liny may be so _lucky_ to be busy writing essays that 
stuffs this side would not be cared for for a period of time.

Therefore, the best solution to this problem is to **open an issue** so that 
Liny would feel so anxious that the update of this project would be determined to be prioritized.

Let's say: _Thank you, issues!_

:3

## Guides

In [build_auto](build_auto) directory there are the latest build products for testing,
which may contain some unknown issues, and are not suggested for long term use.
However, if you have installed one of those, remember to check for updates here frequently!

Type in urls or keywords in the search box at the bottom of the app,
then return or click the little magnifying glass to submit.

Click the icon with four (2x2) little dots to show page information and more functions,
click again to collapse the panel.

## Ideas

Liny's Browser is a basic browser built for HarmonyOS NEXT,
aiming in providing a light-weight solution for users
with devices at any performance level.

This project is inspired by
tuyafeng's marvelous work [Via](https://viayoo.com/),
the cutest cyber fox [Firefox](https://firefox.com/) from Mozilla,
and helped by source codes from OpenHarmony's
[Browser Demo](https://gitee.com/openharmony/applications_app_samples/tree/master/code/BasicFeature/Web/Browser)
& Westinyang's fork [Browser CE](https://gitee.com/westinyang/browser-ce).
Thank you all with your works!! (*￣3￣)╭

## Previews

On Large screens (Light Mode):

![Tablet_light](Examples/gallery_4.png)

On Foldables (Dark Mode):

![Foldable_Dark](Examples/gallery_1.png)

On Phones (Light Mode):

|               Browsing Page                |                  TabsView                   |
|:------------------------------------------:|:-------------------------------------------:|
| ![Phone_light_web](Examples/gallery_2.png) | ![Phone_light_tabs](Examples/gallery_3.png) |

## Related Permissions

[ohos.permission.INTERNET](https://gitee.com/openharmony/docs/blob/master/zh-cn/application-dev/security/permission-list.md#ohospermissioninternet)

## Plans & Developments

May cost unimaginably long time to bring all these into the reality,
or some of them will even lie on the table for ever... (ง •_•)ง

### Features

- [x] Cookies management (and clearing)
- [x] Cache management and clear
- [x] Ads blocking
- [ ] Private mode
- [ ] Customizable download options: ask each time & directly download to system download directory
- [x] In-page text search
- [x] Disable JavaScript
- [ ] Right click or long press menu on web links. (For preview and operations)
- [x] No picture mode
- [ ] Reading mode
- [ ] Search suggestion
- [ ] Plugins / custom scripts
- [ ] DRM Content support
- [x] Respond to webpages' request of opening in new tab.
- [x] Downloads from web.
- [x] UA switching and customizations. (UA related settings)
- [x] Reopen tabs when launching.
- [x] Multi-view parallel browsing.

### Experience

- [x] Customizable themes. (Colors)
- [x] Customizable position for title bar. (Top or Bottom)
- [x] Customizable position for Tabs bar. (Side or Top)
- [x] Adapt to system Back operations.
- [x] Customizable global animation curve.

## Constraints and limits

Long way ahead.

1. As a result of Liny's unsystematic programming thoughts and rubbish codes,
   this application may contain performance problems.
   Liny would appreciate that so much if you wish to report a problem, big or small!
2. Some mysterious problems causing the selected options not displayed in the first opening
   of the Settings Panel after app launch.
3. Due to a mysterious problem and a temporary but necessary compromise,
   sometimes the AD blocking whitelist may not take effect in time after launching,
   resulting in ads on the web page being blocked.
   (Trying to solve)
4. Due to a mysterious problem and a temporary but necessary compromise,
   sometimes the AD blocking function itself may not take effect in time after launching,
   resulting in ads on the web page not being blocked.
   (Trying to solve)
5. In some cases reopening tabs function won't work, and no new tabs are shown.
   (Still under investigation)
6. Perhaps due to performance issues on Windows x86-64 Emulators,
   quickly opening plenty of new tabs may cause crashes due to error
   17100001 (Init error. The WebviewController must be associated with a Web component).
   (Seems to be solved, still under observation)
7. Quickly closing plenty of tabs may cause tabs to disappear.
   This is because in some extreme occasions,
   the tab button is trying to close the last+1 index of the tab list.
   An if statement has been added before the operation
   in order to make sure the index is in the legal range.
   (Seems to be solved, still under observation)
8. HarmonyOS UA is not understood by plenty of websites (But UA is customizable now).
9. The vertical tabs panel animations may seem weird when the scroll is longer than the screen.
10. This project requires HarmonyOS NEXT API12 to run.

## What are the commit labels for?

All the commit information so far since the birth of this project have been so chaotic
that Liny decides to have some self-constraints...

1. fix: Fix updates, used to mark a bug fix;
2. feat: Feature updates, usually used to mark a new feature introduced in this commit；
3. improve: Improvement updates, usually used to mark changes on existing stuffs,
   like changes on logics, interfaces or wordings;
4. code: Code updates, used to mark code optimizations, like code clean ups and logic clean ups;
5. version: Version code changes, used to mark changes in version codes;
6. api: API level changes, used to mark changes in required API level;
7. other: Other uncategorized commits.