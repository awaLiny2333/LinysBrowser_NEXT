import { hapTasks } from '@ohos/hvigor-ohos-plugin';

export default {
  system: hapTasks, /* Built-in plugin of Hvigor. It cannot be modified. */
  plugins: [], /* Custom plugin to extend the functionality of Hvigor. */
  config: {
    ohos: {
      overrides: {
        buildOption: {
          arkOptions: {
            buildProfileFields: {
              linysBuildTime: (new Date().toUTCString()),
            }
          }
        }
      }
    }
  }
}
