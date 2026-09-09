pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    property var fileBrowserSettings: ({})
    property string wallpaperLastPath: ""
    property string profileLastPath: ""

    function saveCache() {
    }
}
