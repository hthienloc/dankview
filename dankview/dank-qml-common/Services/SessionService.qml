pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    readonly property bool hibernateSupported: false

    function logout() {
    }

    function suspend() {
    }

    function hibernate() {
    }

    function reboot() {
    }

    function poweroff() {
    }
}
