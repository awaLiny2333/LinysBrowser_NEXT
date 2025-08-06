import { print } from '@kit.BasicServicesKit';
import { meowContext } from './environment_tools';

/**
 * Print web!
 * @param controller The webview controller.
 * */
export function print_web(controller: WebviewController) {
  let print_adapter: print.PrintDocumentAdapter | undefined = AppStorage.get('print_adapter') as print.PrintDocumentAdapter | undefined;
  if (print_adapter == undefined) {
    let jobName = 'webPrint' + Date.now().toString();
    print_adapter = controller.createWebPrintDocumentAdapter(jobName);
    print.print(jobName, print_adapter, null, meowContext()).then(() => {
      print_adapter = undefined;
      AppStorage.set('print_adapter', undefined);
    });
  } else {
    console.log('[Meow][meowWebView] Cannot print! Another print job going on?');
  }
}