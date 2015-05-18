import QtQuick 2.0
import Sailfish.Silica 1.0

import "../pragma/Helpers.js" as Helpers


ListItem {
    id: listItem

    anchors {
        left: parent.left
        right: parent.right
    }
    contentHeight: Theme.itemSizeMedium

    Label {
        text: Helpers.i18nSmartFolder(name)
    }
}
