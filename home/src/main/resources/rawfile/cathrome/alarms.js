/**
 * @fileoverview A standalone JavaScript class that mimics the functionality
 * of the Chrome Alarms API (chrome.alarms). This class is named 'alarm'
 * for easier integration/mocking, as requested.
 *
 * This implementation uses standard JavaScript setInterval/setTimeout for
 * scheduling and a custom event emitter for the onAlarm event.
 *
 * NOTE: The original chrome.alarms API enforces a 30-second minimum interval.
 * This standalone version enforces a 30-second minimum for API fidelity but
 * the actual JavaScript timers are limited only by the environment.
 */

// --- Type Definitions (For clarity, mirroring Chrome's structure) ---

/**
 * @typedef {Object} Alarm
 * @property {string} name - The name of this alarm.
 * @property {number} scheduledTime - Time at which this alarm was scheduled to fire, in milliseconds past the epoch (Date.now() + n).
 * @property {number | null} [periodInMinutes] - If not null, the alarm is repeating and will fire again in this many minutes.
 * @property {number} _timerId - The internal ID of the JavaScript timer (setTimeout or setInterval).
 */

/**
 * @typedef {Object} AlarmCreateInfo
 * @property {number | undefined} [when] - Time at which the alarm should fire, in milliseconds past the epoch.
 * @property {number | undefined} [delayInMinutes] - Length of time in minutes after which the onAlarm event should fire (mutually exclusive with 'when').
 * @property {number | undefined} [periodInMinutes] - If set, the onAlarm event should fire every periodInMinutes minutes after the initial event.
 */


class alarms { // Class renamed to 'alarm'
    /**
     * @constructor
     */
    constructor() {
        /**
         * Storage for all active alarms, indexed by name.
         * @private
         * @type {Map<string, Alarm>}
         */
        this._alarms = new Map();

        /**
         * Array to hold listener functions for the onAlarm event.
         * @private
         * @type {Array<function(Alarm): void>}
         */
        this._onAlarmListeners = [];

        // Expose the event listener management similar to the Chrome API
        this.onAlarm = {
            /**
             * Adds a listener to be called when an alarm fires.
             * @param {function(Alarm): void} callback The listener function.
             */
            addListener: (callback) => {
                if (typeof callback === 'function' && !this._onAlarmListeners.includes(callback)) {
                    this._onAlarmListeners.push(callback);
                }
            },
            /**
             * Removes a listener.
             * @param {function(Alarm): void} callback The listener function to remove.
             */
            removeListener: (callback) => {
                this._onAlarmListeners = this._onAlarmListeners.filter(listener => listener !== callback);
            },
            /**
             * Checks if a listener is already registered.
             * @param {function(Alarm): void} callback The listener function.
             * @returns {boolean}
             */
            hasListener: (callback) => {
                return this._onAlarmListeners.includes(callback);
            }
        };

        // Define the minimum period in milliseconds (30 seconds)
        this.MIN_PERIOD_MS = 0.5 * 60 * 1000;
    }

    // --- Public Methods Mirroring chrome.alarms ---

    /**
     * Creates an alarm. If an alarm with the same name exists, it is cancelled
     * and replaced by this new one.
     * @param {string} [name=''] Optional name to identify this alarm.
     * @param {AlarmCreateInfo} alarmInfo Describes when the alarm should fire.
     * @returns {void}
     */
    create(name = '', alarmInfo) {
        // 1. Clear any existing alarm with the same name
        if (this._alarms.has(name)) {
            this.clear(name);
        }

        const now = Date.now();
        let scheduledTime;
        let periodInMinutes = alarmInfo.periodInMinutes;

        // Determine the initial fire time (must use one of three methods)
        if (alarmInfo.when !== undefined) {
            scheduledTime = alarmInfo.when;
        } else if (alarmInfo.delayInMinutes !== undefined) {
            scheduledTime = now + (alarmInfo.delayInMinutes * 60 * 1000);
        } else if (periodInMinutes !== undefined) {
            // If periodInMinutes is set but no initial time, delayInMinutes defaults to periodInMinutes
            scheduledTime = now + (periodInMinutes * 60 * 1000);
        } else {
            console.error('Alarms.create failed: Must specify "when", "delayInMinutes", or "periodInMinutes".');
            return;
        }

        const initialDelayMs = Math.max(0, scheduledTime - now);
        let periodMs = periodInMinutes !== undefined ? periodInMinutes * 60 * 1000 : null;
        const isRepeating = periodMs !== null;

        // 2. Enforce minimum period for Chrome API fidelity
        if (isRepeating && periodMs < this.MIN_PERIOD_MS) {
            console.warn(`Alarms.create: periodInMinutes (${periodInMinutes}) is less than the 30-second minimum enforced by Chrome (0.5 minutes). Using 0.5 minutes instead.`);
            periodInMinutes = 0.5;
            periodMs = this.MIN_PERIOD_MS;
        }

        let timerId;
        const fireCallback = () => this._fireAlarm(name, isRepeating);

        if (isRepeating) {
            // Setup for repeating alarms: Use a setTimeout for the first fire (initialDelayMs), then switch to setInterval.
            // This ensures the initial fire time is exact, independent of the periodic interval.
            timerId = setTimeout(() => {
                fireCallback(); // Fire for the first time

                // Switch to setInterval for all subsequent, recurring fires
                const intervalId = setInterval(fireCallback, periodMs);

                // CRITICAL: Update the stored alarm's ID from the initial setTimeout ID to the new setInterval ID.
                const updatedAlarm = this._alarms.get(name);
                if (updatedAlarm) {
                    updatedAlarm._timerId = intervalId;
                }
            }, initialDelayMs);

        } else {
            // For one-shot alarms, use a single setTimeout.
            timerId = setTimeout(fireCallback, initialDelayMs);
        }

        // 3. Store the new Alarm object
        /** @type {Alarm} */
        const newAlarm = {
            name,
            scheduledTime: scheduledTime,
            periodInMinutes: periodInMinutes || null,
            _timerId: timerId // This holds the initial setTimeout ID
        };

        this._alarms.set(name, newAlarm);
        console.log(`Alarm '${name}' created. Initial fire in: ${initialDelayMs / 1000} seconds.`);
    }

    /**
     * Clears the alarm with the given name.
     * @param {string} name The name of the alarm to clear.
     * @returns {Promise<boolean>} Resolves with true if an alarm was cleared, false otherwise.
     */
    async clear(name) {
        const alarm = this._alarms.get(name);

        if (alarm) {
            this._clearTimer(alarm);
            this._alarms.delete(name);
            console.log(`Alarm '${name}' cleared.`);
            return true;
        }

        return false;
    }

    /**
     * Clears all alarms.
     * @returns {Promise<boolean>} Resolves with true if any alarms were cleared, false otherwise.
     */
    async clearAll() {
        if (this._alarms.size === 0) {
            return false;
        }

        this._alarms.forEach(alarm => this._clearTimer(alarm));
        this._alarms.clear();
        console.log('All alarms cleared.');
        return true;
    }

    /**
     * Retrieves details about the specified alarm.
     * @param {string} name The name of the alarm to get.
     * @returns {Promise<Alarm | undefined>}
     */
    async get(name) {
        // Return a copy without the internal _timerId, mirroring the public Chrome API object.
        const alarm = this._alarms.get(name);
        if (alarm) {
            const { _timerId, ...publicAlarm } = alarm;
            return publicAlarm;
        }
        return undefined;
    }

    /**
     * Gets an array of all the alarms.
     * @returns {Promise<Alarm[]>} An array of all current alarms.
     */
    async getAll() {
        // Return a clean array without the internal _timerId
        return Array.from(this._alarms.values()).map(alarm => {
            const { _timerId, ...publicAlarm } = alarm;
            return publicAlarm;
        });
    }

    // --- Private ---

    /**
     * Helper to clear any existing alarm timer (setTimeout/setInterval).
     * @private
     * @param {Alarm} alarm The alarm object to clear.
     */
    _clearTimer(alarm) {
        if (alarm._timerId) {
            // Check periodInMinutes to determine if it's a recurring alarm (setInterval) or one-shot (setTimeout)
            if (alarm.periodInMinutes) {
                clearInterval(alarm._timerId);
            } else {
                clearTimeout(alarm._timerId);
            }
        }
    }

    /**
     * Executes the alarm listeners and handles cleanup for non-repeating alarms.
     * @private
     * @param {string} name The name of the alarm that fired.
     * @param {boolean} isRepeating True if this alarm is recurring (uses setInterval).
     */
    _fireAlarm(name, isRepeating) {
        const alarm = this._alarms.get(name);

        if (!alarm) {
            console.error(`Alarm fired but not found in registry: ${name}`);
            return;
        }

        // 1. Notify all registered listeners
        const alarmDataForListeners = {
            name: alarm.name,
            scheduledTime: alarm.scheduledTime,
            periodInMinutes: alarm.periodInMinutes
        };
        this._onAlarmListeners.forEach(listener => {
            // Use try-catch to ensure one failing listener doesn't stop the others
            try {
                listener(alarmDataForListeners);
            } catch (error) {
                console.error(`Error in onAlarm listener for alarm '${name}':`, error);
            }
        });

        // 2. Clear non-repeating alarms after they fire once
        if (!isRepeating) {
            // The `clear` method handles deleting the alarm from the map and stopping the timer.
            this.clear(name);
        }
        // Note: Repeating alarms' timers (setInterval) handle their own recurrence.
    }
}