/**
 * @file Standalone Chrome Action Mock
 * @description A standalone JavaScript implementation mimicking the core features of the
 * chrome.action API using standard JavaScript objects for state management.
 *
 * NOTE: This mock implements methods for managing the action's visual properties and state,
 * but it cannot render or interact with a real browser toolbar.
 */

// Helper to manage event listeners (similar to chrome.events.Event)
class EventListener {
    constructor() {
        /** @private */
        this.listeners = [];
    }

    /** @param {function} callback */
    addListener(callback) {
        this.listeners.push(callback);
    }

    /** @param {function} callback */
    removeListener(callback) {
        this.listeners = this.listeners.filter(l => l !== callback);
    }

    /** @param {...any} args */
    fire(...args) {
        this.listeners.forEach(listener => listener(...args));
    }
}

class action {
    constructor() {
        // Initialize events
        /** @public */
        this.onClicked = new EventListener();
        /** @public */
        this.onUserSettingsChanged = new EventListener();
    }

    // --- chrome.action Methods ---

    /**
     * Sets the title (tooltip) for the action. Near-identical to chrome.action.setTitle.
     * @param {{title: string, tabId?: number}} details - The title and optional tab ID.
     * @returns {Promise<void>}
     */
    async setTitle(details) {
        let title = details.title;
        // TODO: In a real extension, the browser UI would update the tooltip here.
        CatsBridge.chrome_action_setTitle(title);
    }

    /**
     * Gets the title of the action. Near-identical to chrome.action.getTitle.
     * @param {{tabId?: number}} [details={}] - Optional tab ID.
     * @returns {Promise<string>}
     */
    async getTitle(details = {}) {
        let id = details.tabId;
        // TODO: Get title.
        return;
    }

    /**
     * Sets the badge text for the action. Near-identical to chrome.action.setBadgeText.
     * @param {{text: string, tabId?: number}} details - The text (max ~4 chars) and optional tab ID.
     * @returns {Promise<void>}
     */
    async setBadgeText(details) {
        let id = details.tabId;
        let text = details.text;
        // TODO: In a real extension, the browser UI would update the badge text here.
    }

    /**
     * Gets the badge text of the action. Near-identical to chrome.action.getBadgeText.
     * @param {{tabId?: number}} [details={}] - Optional tab ID.
     * @returns {Promise<string>}
     */
    async getBadgeText(details = {}) {
        let id = details.tabId;
        // TODO: Get badge text.
        return;
    }

    /**
     * Sets the background color for the badge. Near-identical to chrome.action.setBadgeBackgroundColor.
     * @param {{color: string | Array<number>, tabId?: number}} details - The color (CSS string or RGBA array) and optional tab ID.
     * @returns {Promise<void>}
     */
    async setBadgeBackgroundColor(details) {
        let id = details.tabId;
        let color = details.color;
        // TODO: In a real extension, the browser UI would update the badge color here.
    }

    /**
     * Gets the background color of the action. Near-identical to chrome.action.getBadgeBackgroundColor.
     * @param {{tabId?: number}} [details={}] - Optional tab ID.
     * @returns {Promise<string | Array<number>>}
     */
    async getBadgeBackgroundColor(details = {}) {
        let id = details.tabId;
        return;
    }

    /**
     * Sets the text color for the badge (Chrome 110+). Near-identical to chrome.action.setBadgeTextColor.
     * @param {{color: string | Array<number>, tabId?: number}} details - The color (CSS string or RGBA array) and optional tab ID.
     * @returns {Promise<void>}
     */
    async setBadgeTextColor(details) {
        let id = details.tabId;
        let color = details.color;
        // TODO: In a real extension, the browser UI would update the badge text color here.
    }

    /**
     * Gets the text color of the action (Chrome 110+). Near-identical to chrome.action.getBadgeTextColor.
     * @param {{tabId?: number}} [details={}] - Optional tab ID.
     * @returns {Promise<string | Array<number>>}
     */
    async getBadgeTextColor(details = {}) {
        let id = details.tabId;
        return;
    }

    /**
     * Sets the HTML document to be opened as a popup. Near-identical to chrome.action.setPopup.
     * @param {{popup: string, tabId?: number}} details - The relative path (or empty string for no popup) and optional tab ID.
     * @returns {Promise<void>}
     */
    async setPopup(details) {
        let id = details.tabId;
        let popup = details.popup;
        // TODO: In a real extension, this would associate the popup file with the action button.
    }

    /**
     * Gets the html document set as the popup for this action. Near-identical to chrome.action.getPopup.
     * @param {{tabId?: number}} [details={}] - Optional tab ID.
     * @returns {Promise<string>}
     */
    async getPopup(details = {}) {
        let id = details.tabId;
        return;
    }

    /**
     * Sets the icon for the action. Near-identical to chrome.action.setIcon.
     * @param {{path?: string | object, imageData?: ImageData | object, tabId?: number}} details - Icon details and optional tab ID.
     * @returns {Promise<void>}
     */
    async setIcon(details) {
        let id = details.tabId;
        let path = details.path;
        let imageData = details.imageData;
        // TODO: In a real extension, the browser UI would update the icon here.
    }

    /**
     * Enables the action for a tab (or globally). Near-identical to chrome.action.enable.
     * @param {number} [tabId] - Optional tab ID.
     * @returns {Promise<void>}
     */
    async enable(tabId) {
        // TODO: In a real extension, this makes the button clickable/sends onClicked events.
    }

    /**
     * Disables the action for a tab (or globally). Near-identical to chrome.action.disable.
     * @param {number} [tabId] - Optional tab ID.
     * @returns {Promise<void>}
     */
    async disable(tabId) {
        // TODO: In a real extension, this prevents the button from being clickable/sending onClicked events.
    }

    /**
     * Indicates whether the extension action is enabled for a tab (or globally). Near-identical to chrome.action.isEnabled.
     * @param {number} [tabId] - Optional tab ID.
     * @returns {Promise<boolean>}
     */
    async isEnabled(tabId) {
        return true;
    }

    /**
     * Returns the user-specified settings relating to an extension's action. Near-identical to chrome.action.getUserSettings.
     * @returns {Promise<{isOnToolbar: boolean}>}
     */
    async getUserSettings() {
        return { isOnToolbar: true };
    }

    /**
     * Opens the extension's popup. Near-identical to chrome.action.openPopup.
     * @param {{windowId?: number}} [options={}] - Options for opening the popup.
     * @returns {Promise<void>}
     */
    async openPopup(options = {}) {
        let id = options.windowId || 'current';
        // This is purely a mock operation as it requires browser UI interaction.
        console.log(`[action.openPopup] Attempting to open popup in window ${id}.`);
        // TODO: This method would trigger the display of the currently set popup URL.
        return;
    }
}