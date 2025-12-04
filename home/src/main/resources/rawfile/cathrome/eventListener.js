// Helper to manage event listeners (similar to chrome.events.Event)
class cathrome_eventListener {
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