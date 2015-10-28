import QtQuick 2.0
import Sailfish.Silica 1.0

import org.kubler.Reminders 1.0


Page {
    id: page


    property var annotationsModel
    property string reminderDescription


    SilicaListView {
        id: view

        anchors {
            fill: parent
        }
        delegate: ListItem {
            contentHeight: lblAnnotation.contentHeight + 2 * Theme.paddingMedium
            menu: contextMenu

            Label {
                id: lblAnnotation

                anchors {
                    fill: parent
                    bottomMargin: Theme.paddingMedium
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: anchors.leftMargin
                    topMargin: anchors.bottomMargin
                }
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
                font {
                    pixelSize: Theme.fontSizeMedium
                }
                text: model.annotation
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }
        header: PageHeader {
            title: qsTr("Annotations")
            description: reminderDescription
        }
        model: annotationsModel


        Component {
            id: contextMenu

            ContextMenu {
                MenuItem {
                    text: qsTr("Edit")
                    onClicked: {

                    }
                }
                MenuItem {
                    text: qsTr("Remove")
                    onClicked: {

                    }
                }
            }
        }

        PullDownMenu {
            id: menu

            MenuItem {
                text: qsTr("Add an annotation")
            }
        }

        ViewPlaceholder {
            enabled: !view.count
            text: qsTr("No annotation yet !")
            hintText: qsTr("Pull down to create one.")
        }

        VerticalScrollDecorator {}
    }
}
