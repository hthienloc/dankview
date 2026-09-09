pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    function scoped(module) {
        return {
            debug: (...args) => console.log(`[${module}]`, ...args),
            info: (...args) => console.info(`[${module}]`, ...args),
            warn: (...args) => console.warn(`[${module}]`, ...args),
            error: (...args) => console.error(`[${module}]`, ...args)
        };
    }
}
