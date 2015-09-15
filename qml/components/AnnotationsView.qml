/*



 */

//FIXME:
// Replace by Item { ColumnView BackgroundItem } ?

import QtQuick 2.0
import Sailfish.Silica 1.0

import org.kubler.Reminders 1.0

Column {
    id: root

    property variant model
    property bool editable: true //FIXME: set default to false

    Repeater {
        delegate: ListItem {
            contentHeight: lblAnnotation.contentHeight + 2 * Theme.paddingMedium

            Label {
                id: lblAnnotation

                anchors {
                    bottom: parent.bottom
                    bottomMargin: Theme.paddingMedium
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                    top: parent.top
                    topMargin: Theme.paddingMedium
                }
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
                font {
                    pixelSize: Theme.fontSizeSmall
                }
                text: model.annotation
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }
        model: root.model
    }

    ViewPlaceholder {
        enabled: !root.model.count
        text: qsTr("No annotation.")
    }

    BackgroundItem {
        id: addAnnotation

        visible: root.editable

        Item {
            anchors {
                fill: parent
                margins: Theme.paddingLarge
                verticalCenter: parent.verticalCenter
            }

            Image {
                id: icon

                anchors {
                    left: parent.left
                    rightMargin: Theme.paddingLarge
                }
                height: lblAddAnnotation.height
                source: "image://theme/icon-m-add"
                width: height
            }

            Label {
                id: lblAddAnnotation

                anchors {
                    left: icon.right
                    leftMargin: Theme.paddingLarge
                    //right: parent.right
                }
                color: addAnnotation.highlighted ? Theme.highlightColor : Theme.primaryColor
                text: qsTr("Add a new annotation...")
            }
        }
    }
}
