import { BusinessError } from '@kit.BasicServicesKit';
import { filePreview } from '@kit.PreviewKit';
import { common } from '@kit.AbilityKit';
import { meowContext } from './environment_tools';

const image_suffixes = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'];
const image_mimes = ['jpeg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg+xml'];

export function preview_image(uri: string, storage: LocalStorage) {
  // Determine file name
  const split_name_result = uri.split('/');
  const file_name = split_name_result[split_name_result.length-1];
  // Determine file suffix
  const file_suffix_result = file_name.split('.');
  const file_suffix = file_suffix_result[file_suffix_result.length-1];
  // Determine mime
  let mime: string = 'image/' + image_mimes[image_suffixes.indexOf(file_suffix.toLowerCase())];
  // Show
  let displayInfo: filePreview.DisplayInfo = {
    x: 100,
    y: 100,
    width: 800,
    height: 800
  };
  let fileInfo: filePreview.PreviewInfo = {
    title: '（ฅ＾・ﻌ・＾）ฅ - ' + file_name,
    uri: uri,
    mimeType: mime
  };

  let context = storage.get('context') as Context;
  filePreview.openPreview(context, fileInfo, displayInfo).then(() => {
    console.info('[preview_image] Succeeded in opening preview');
  }).catch((err: BusinessError) => {
    console.error(`[preview_image] Failed to open preview, err.code = ${err.code}, err.message = ${err.message}`);
  });
}

