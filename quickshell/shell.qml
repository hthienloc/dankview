//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_WAYLAND_DISABLE_WINDOWDECORATION=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Material
//@ pragma UseQApplication
//@ pragma AppId com.danklinux.dankview

import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Modules.ImageViewer

ShellRoot {
    id: root

    ImageViewerWindow {
        id: viewerWindow
    }
}
