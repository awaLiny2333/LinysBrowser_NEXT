class cathrome {
    constructor() {
        // Chrome apis
        this.alarms = new cathrome_alarms();
        this.action = new cathrome_action();
        this.bookmarks = new cathrome_bookmarks();
        this.browsingData = new cathrome_browsingData();
        this.commands = new cathrome_commands();
        this.contentSettings = new cathrome_contentSettings();
        this.contextMenus = new cathrome_contextMenus();
        this.declarativeNetRequest = new cathrome_declarativeNetRequest();
        this.i18n = new cathrome_i18n();

        // BrowserCat stuffs
        this.liny = new cathrome_liny();
        this.liny.test('New cathrome constructed! uwu_!!!');
    }
}

chrome = new cathrome();