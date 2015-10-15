/*



 */

//FIXME:
// Replace by Item { ColumnView BackgroundItem } ?

import QtQuick 2.0
import Sailfish.Silica 1.0

import org.kubler.Reminders 1.0


BackgroundItem {
    id: root

    property variant model


    anchors {
        left: parent.left
        right: parent.right
    }
    height: column.height


    Column {
        id: column

        anchors {
            left: parent.left
            right: parent.right
        }

        Repeater {
            delegate: ListItem {
                contentHeight: lblAnnotation.contentHeight + 2 * Theme.paddingMedium
                enabled: false

                Label {
                    id: lblAnnotation

                    anchors {
                        fill: parent
                        bottomMargin: Theme.paddingMedium
                        leftMargin: Theme.horizontalPageMargin
                        rightMargin: anchors.leftMargin
                        topMargin: anchors.bottomMargin
                    }
                    color: root.highlighted ? Theme.highlightColor : Theme.primaryColor
                    font {
                        pixelSize: Theme.fontSizeMedium
                    }
                    text: model.annotation
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
            }
            model: root.model
        }
    }


    onClicked: {

    }
}
