pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    readonly property bool isRtl: false

    function tr(term, context) {
        return term;
    }
}
