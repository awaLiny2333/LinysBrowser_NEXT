// Currently empty api.
// TODO: Finish declarativeNetRequest.js

/**
 * Standalone implementation of chrome.declarativeNetRequest API.
 * * Assumes `cathrome_eventListener` is available in the scope as per instructions.
 */
class cathrome_declarativeNetRequest {
    constructor() {
        // --- Internal State Storage (Simulation) ---
        /** @type {cathrome_declarativeNetRequest.Rule[]} */
        this._dynamicRules = [];
        /** @type {cathrome_declarativeNetRequest.Rule[]} */
        this._sessionRules = [];

        // Simulating Manifest Static Rulesets
        // Structure: { id: string, enabled: boolean, rules: Rule[], disabledRuleIds: Set<number> }
        /** @type {Map<string, Object>} */
        this._staticRulesets = new Map();

        // Limits (Counters)
        this._getMatchedRulesCallCount = 0;
        this._lastQuotaReset = Date.now();

        // --- Events ---
        this.onRuleMatchedDebug = new cathrome_eventListener();
    }

    // ==========================================
    //              PROPERTIES (Constants)
    // ==========================================

    static DYNAMIC_RULESET_ID = "_dynamic";
    static SESSION_RULESET_ID = "_session";

    static MAX_NUMBER_OF_DYNAMIC_RULES = 30000;
    static MAX_NUMBER_OF_UNSAFE_DYNAMIC_RULES = 5000;
    static MAX_NUMBER_OF_SESSION_RULES = 5000;
    static MAX_NUMBER_OF_UNSAFE_SESSION_RULES = 5000;
    static MAX_NUMBER_OF_STATIC_RULESETS = 100;
    static MAX_NUMBER_OF_ENABLED_STATIC_RULESETS = 50;
    static MAX_NUMBER_OF_REGEX_RULES = 1000;
    static GUARANTEED_MINIMUM_STATIC_RULES = 30000;

    static GETMATCHEDRULES_QUOTA_INTERVAL = 10; // Minutes
    static MAX_GETMATCHEDRULES_CALLS_PER_INTERVAL = 20;

    // ==========================================
    //           TYPES (Static Nested Classes)
    // ==========================================

    /** Enum: ResourceType */
    static ResourceType = {
        MAIN_FRAME: "main_frame",
        SUB_FRAME: "sub_frame",
        STYLESHEET: "stylesheet",
        SCRIPT: "script",
        IMAGE: "image",
        FONT: "font",
        OBJECT: "object",
        XMLHTTPREQUEST: "xmlhttprequest",
        PING: "ping",
        CSP_REPORT: "csp_report",
        MEDIA: "media",
        WEBSOCKET: "websocket",
        WEBTRANSPORT: "webtransport",
        WEBBUNDLE: "webbundle",
        OTHER: "other"
    };

    /** Enum: RuleActionType */
    static RuleActionType = {
        BLOCK: "block",
        REDIRECT: "redirect",
        ALLOW: "allow",
        UPGRADE_SCHEME: "upgradeScheme",
        MODIFY_HEADERS: "modifyHeaders",
        ALLOW_ALL_REQUESTS: "allowAllRequests"
    };

    /** Enum: HeaderOperation */
    static HeaderOperation = {
        APPEND: "append",
        SET: "set",
        REMOVE: "remove"
    };

    /** Enum: DomainType */
    static DomainType = {
        FIRST_PARTY: "firstParty",
        THIRD_PARTY: "thirdParty"
    };

    /** Enum: RequestMethod */
    static RequestMethod = {
        CONNECT: "connect",
        DELETE: "delete",
        GET: "get",
        HEAD: "head",
        OPTIONS: "options",
        PATCH: "patch",
        POST: "post",
        PUT: "put",
        OTHER: "other"
    };

    /** Enum: UnsupportedRegexReason */
    static UnsupportedRegexReason = {
        SYNTAX_ERROR: "syntaxError",
        MEMORY_LIMIT_EXCEEDED: "memoryLimitExceeded"
    };

    /** Structure: Rule */
    static Rule = class {
        constructor(data = {}) {
            /** @type {number} */
            this.id = data.id;
            /** @type {number} */
            this.priority = data.priority || 1;
            /** @type {cathrome_declarativeNetRequest.RuleAction} */
            this.action = data.action;
            /** @type {cathrome_declarativeNetRequest.RuleCondition} */
            this.condition = data.condition;
        }
    };

    /** Structure: RuleAction */
    static RuleAction = class {
        constructor(data = {}) {
            this.type = data.type; // RuleActionType
            this.redirect = data.redirect; // Redirect (optional)
            this.requestHeaders = data.requestHeaders; // ModifyHeaderInfo[] (optional)
            this.responseHeaders = data.responseHeaders; // ModifyHeaderInfo[] (optional)
        }
    };

    /** Structure: RuleCondition */
    static RuleCondition = class {
        constructor(data = {}) {
            this.urlFilter = data.urlFilter;
            this.regexFilter = data.regexFilter;
            this.isUrlFilterCaseSensitive = data.isUrlFilterCaseSensitive || false;
            this.domains = data.domains; // Deprecated
            this.excludedDomains = data.excludedDomains; // Deprecated
            this.initiatorDomains = data.initiatorDomains;
            this.excludedInitiatorDomains = data.excludedInitiatorDomains;
            this.requestDomains = data.requestDomains;
            this.excludedRequestDomains = data.excludedRequestDomains;
            this.requestMethods = data.requestMethods;
            this.excludedRequestMethods = data.excludedRequestMethods;
            this.resourceTypes = data.resourceTypes;
            this.excludedResourceTypes = data.excludedResourceTypes;
            this.tabIds = data.tabIds;
            this.excludedTabIds = data.excludedTabIds;
            this.domainType = data.domainType;
        }
    };

    /** Structure: ModifyHeaderInfo */
    static ModifyHeaderInfo = class {
        constructor(data = {}) {
            this.header = data.header;
            this.operation = data.operation; // HeaderOperation
            this.value = data.value;
        }
    };

    /** Structure: Redirect */
    static Redirect = class {
        constructor(data = {}) {
            this.extensionPath = data.extensionPath;
            this.transform = data.transform; // URLTransform
            this.url = data.url;
            this.regexSubstitution = data.regexSubstitution;
        }
    };

    /** Structure: URLTransform */
    static URLTransform = class {
        constructor(data = {}) {
            this.scheme = data.scheme;
            this.host = data.host;
            this.port = data.port;
            this.path = data.path;
            this.query = data.query;
            this.queryTransform = data.queryTransform;
            this.fragment = data.fragment;
            this.username = data.username;
            this.password = data.password;
        }
    };

    /** Structure: RegexOptions */
    static RegexOptions = class {
        constructor(data = {}) {
            this.regex = data.regex;
            this.isCaseSensitive = data.isCaseSensitive !== undefined ? data.isCaseSensitive : true;
            this.requireCapturing = data.requireCapturing || false;
        }
    };

    /** Structure: Ruleset (Manifest definition) */
    static Ruleset = class {
        constructor(data = {}) {
            this.id = data.id;
            this.path = data.path;
            this.enabled = data.enabled;
        }
    };

    // ==========================================
    //                 METHODS
    // ==========================================

    /**
     * Helper to simulate a manifest update or installation of static rules
     * (Not part of official API, but needed for standalone class functionality)
     */
    _simulateStaticRuleset(id, rules, enabled = false) {
        this._staticRulesets.set(id, {
            id,
            enabled,
            rules: rules.map(r => new cathrome_declarativeNetRequest.Rule(r)),
            disabledRuleIds: new Set()
        });
    }

    /**
     * Modifies the current set of dynamic rules.
     * @param {Object} options - {addRules, removeRuleIds}
     * @returns {Promise<void>}
     */
    async updateDynamicRules(options) {
        const { addRules = [], removeRuleIds = [] } = options;

        // 1. Remove rules
        if (removeRuleIds.length > 0) {
            const removeSet = new Set(removeRuleIds);
            this._dynamicRules = this._dynamicRules.filter(rule => !removeSet.has(rule.id));
        }

        // 2. Add rules (Check limits in a real implementation, skipping for brevity)
        if (addRules.length > 0) {
            addRules.forEach(rule => {
                // Basic validation: ensure ID and action exist
                if (!rule.id || !rule.action) throw new Error("Invalid rule structure");
                this._dynamicRules.push(new cathrome_declarativeNetRequest.Rule(rule));
            });
        }
    }

    /**
     * Returns the current set of dynamic rules.
     * @param {Object} [filter] - {ruleIds}
     * @returns {Promise<Rule[]>}
     */
    async getDynamicRules(filter) {
        if (!filter || !filter.ruleIds) {
            return JSON.parse(JSON.stringify(this._dynamicRules));
        }
        const filterSet = new Set(filter.ruleIds);
        const result = this._dynamicRules.filter(r => filterSet.has(r.id));
        return JSON.parse(JSON.stringify(result));
    }

    /**
     * Modifies the current set of session scoped rules.
     * @param {Object} options - {addRules, removeRuleIds}
     * @returns {Promise<void>}
     */
    async updateSessionRules(options) {
        const { addRules = [], removeRuleIds = [] } = options;

        if (removeRuleIds.length > 0) {
            const removeSet = new Set(removeRuleIds);
            this._sessionRules = this._sessionRules.filter(rule => !removeSet.has(rule.id));
        }

        if (addRules.length > 0) {
            addRules.forEach(rule => {
                this._sessionRules.push(new cathrome_declarativeNetRequest.Rule(rule));
            });
        }
    }

    /**
     * Returns the current set of session scoped rules.
     * @param {Object} [filter] - {ruleIds}
     * @returns {Promise<Rule[]>}
     */
    async getSessionRules(filter) {
        if (!filter || !filter.ruleIds) {
            return JSON.parse(JSON.stringify(this._sessionRules));
        }
        const filterSet = new Set(filter.ruleIds);
        const result = this._sessionRules.filter(r => filterSet.has(r.id));
        return JSON.parse(JSON.stringify(result));
    }

    /**
     * Updates the set of enabled static rulesets.
     * @param {Object} options - {enableRulesetIds, disableRulesetIds}
     * @returns {Promise<void>}
     */
    async updateEnabledRulesets(options) {
        const { enableRulesetIds = [], disableRulesetIds = [] } = options;

        // Disable
        disableRulesetIds.forEach(id => {
            if (this._staticRulesets.has(id)) {
                this._staticRulesets.get(id).enabled = false;
            }
        });

        // Enable (Check limit MAX_NUMBER_OF_ENABLED_STATIC_RULESETS here in real logic)
        enableRulesetIds.forEach(id => {
            if (this._staticRulesets.has(id)) {
                this._staticRulesets.get(id).enabled = true;
            }
        });
    }

    /**
     * Returns the ids for the current set of enabled static rulesets.
     * @returns {Promise<string[]>}
     */
    async getEnabledRulesets() {
        const enabled = [];
        for (const [id, data] of this._staticRulesets.entries()) {
            if (data.enabled) enabled.push(id);
        }
        return enabled;
    }

    /**
     * Disables and enables individual static rules in a Ruleset.
     * @param {Object} options - {rulesetId, disableRuleIds, enableRuleIds}
     * @returns {Promise<void>}
     */
    async updateStaticRules(options) {
        const { rulesetId, disableRuleIds = [], enableRuleIds = [] } = options;

        if (!this._staticRulesets.has(rulesetId)) {
            // In Chrome this might fail silently or throw depending on context
            throw new Error(`Ruleset ${rulesetId} not found`);
        }

        const ruleset = this._staticRulesets.get(rulesetId);

        disableRuleIds.forEach(id => ruleset.disabledRuleIds.add(id));
        enableRuleIds.forEach(id => ruleset.disabledRuleIds.delete(id));
    }

    /**
     * Returns the list of static rules in the given Ruleset that are currently disabled.
     * @param {Object} options - {rulesetId}
     * @returns {Promise<number[]>}
     */
    async getDisabledRuleIds(options) {
        const { rulesetId } = options;
        if (!this._staticRulesets.has(rulesetId)) {
            throw new Error(`Ruleset ${rulesetId} not found`);
        }
        return Array.from(this._staticRulesets.get(rulesetId).disabledRuleIds);
    }

    /**
     * Returns the available static rule count.
     * @returns {Promise<number>}
     */
    async getAvailableStaticRuleCount() {
        // Simplified calculation based on constants
        return cathrome_declarativeNetRequest.GUARANTEED_MINIMUM_STATIC_RULES;
    }

    /**
     * Checks if a regex is supported.
     * @param {RegexOptions} regexOptions
     * @returns {Promise<{isSupported: boolean, reason?: string}>}
     */
    async isRegexSupported(regexOptions) {
        try {
            const flags = regexOptions.isCaseSensitive ? '' : 'i';
            new RegExp(regexOptions.regex, flags);
            return { isSupported: true };
        } catch (e) {
            return {
                isSupported: false,
                reason: cathrome_declarativeNetRequest.UnsupportedRegexReason.SYNTAX_ERROR
            };
        }
    }

    /**
     * Configures extension action options (badge text).
     * @param {Object} options
     * @returns {Promise<void>}
     */
    async setExtensionActionOptions(options) {
        // Just a stub in standalone class, as it affects UI
        return Promise.resolve();
    }

    /**
     * Returns matched rules (Debug).
     * @param {Object} [filter]
     * @returns {Promise<Object>} RulesMatchedDetails
     */
    async getMatchedRules(filter) {
        // Enforce Quota
        const now = Date.now();
        if (now - this._lastQuotaReset > cathrome_declarativeNetRequest.GETMATCHEDRULES_QUOTA_INTERVAL * 60000) {
            this._getMatchedRulesCallCount = 0;
            this._lastQuotaReset = now;
        }

        if (this._getMatchedRulesCallCount >= cathrome_declarativeNetRequest.MAX_GETMATCHEDRULES_CALLS_PER_INTERVAL) {
            throw new Error("Quota exceeded for getMatchedRules");
        }
        this._getMatchedRulesCallCount++;

        // In a real browser, this returns historical matches.
        // Here we return an empty structure as we aren't sniffing real traffic.
        return { rulesMatchedInfo: [] };
    }

    /**
     * Tests a hypothetical request against matching rules.
     * @param {Object} request - TestMatchRequestDetails
     * @returns {Promise<{matchedRules: Array}>} TestMatchOutcomeResult
     */
    async testMatchOutcome(request) {
        // Gather all active rules
        let allRules = [
            ...this._sessionRules.map(r => ({ rule: r, origin: 'session' })),
            ...this._dynamicRules.map(r => ({ rule: r, origin: 'dynamic' }))
        ];

        for (const [id, set] of this._staticRulesets.entries()) {
            if (set.enabled) {
                set.rules.forEach(r => {
                    if (!set.disabledRuleIds.has(r.id)) {
                        allRules.push({ rule: r, origin: 'static', rulesetId: id });
                    }
                });
            }
        }

        // Filter rules that match the request (Simplified Matching Logic)
        const matches = allRules.filter(item => this._ruleMatchesRequest(item.rule, request));

        // Sort by Priority and Action Type
        // Order: Allow > Block > Upgrade > Redirect (Simplified)
        const actionPriority = {
            'allow': 4,
            'allowAllRequests': 4,
            'block': 3,
            'upgradeScheme': 2,
            'redirect': 1,
            'modifyHeaders': 0
        };

        matches.sort((a, b) => {
            const pA = a.rule.priority || 1;
            const pB = b.rule.priority || 1;
            if (pA !== pB) return pB - pA; // Higher priority first

            const actionA = actionPriority[a.rule.action.type] || 0;
            const actionB = actionPriority[b.rule.action.type] || 0;
            return actionB - actionA;
        });

        // Determine the "winning" rule (simplified)
        // Note: modifyHeaders are handled differently in reality (combined),
        // but testMatchOutcome usually returns the generic match.

        const matchedRules = matches.map(m => ({
            rule: m.rule,
            ruleId: m.rule.id,
            rulesetId: m.rulesetId || (m.origin === 'dynamic' ? cathrome_declarativeNetRequest.DYNAMIC_RULESET_ID : cathrome_declarativeNetRequest.SESSION_RULESET_ID)
        }));

        return { matchedRules };
    }

    /**
     * Internal helper to check if a rule matches a request.
     * NOTE: This is a simplified matcher (exact string, substring, or regex).
     * It does NOT implement the full Chrome URL pattern matching spec.
     */
    _ruleMatchesRequest(rule, request) {
        const condition = rule.condition;
        const url = request.url;

        // 1. Method check
        if (condition.requestMethods && !condition.requestMethods.includes(request.method.toLowerCase())) return false;
        if (condition.excludedRequestMethods && condition.excludedRequestMethods.includes(request.method.toLowerCase())) return false;

        // 2. ResourceType check
        if (condition.resourceTypes && !condition.resourceTypes.includes(request.type)) return false;

        // 3. URL Filter
        if (condition.urlFilter) {
            // Very basic simulation of urlFilter
            const filter = condition.urlFilter;
            if (filter === "*") return true;
            // Handle | anchors loosely
            const cleanFilter = filter.replace(/^\|\|/, '').replace(/\^/g, '');
            if (!url.includes(cleanFilter)) return false;
        }

        // 4. Regex Filter
        if (condition.regexFilter) {
            try {
                const flags = condition.isUrlFilterCaseSensitive ? '' : 'i';
                const re = new RegExp(condition.regexFilter, flags);
                if (!re.test(url)) return false;
            } catch (e) {
                return false;
            }
        }

        return true;
    }

    /**
     * Interacts with CatsBridge and update rules.
     * */
    _afterUpdate() {

    }
}