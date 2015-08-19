/*



 */

import QtQuick 2.0
import Sailfish.Silica 1.0

import org.kubler.Reminders 1.0

BackgroundItem {
    id: root

    property alias model: tags.model

    height: tagFlow.height + 2 * Theme.paddingMedium
    width: parent.width

    Flow {
        id: tagFlow

        anchors {
            left: parent.left
            leftMargin: Theme.paddingLarge
            right: parent.right
            rightMargin: Theme.paddingLarge
            verticalCenter: parent.verticalCenter
        }
        spacing: Theme.paddingMedium

        Repeater {
            id: tags

            delegate: Tag {
                enabled: false
                selected: true
                tag: model.tag
            }
        }
    }

    onClicked: {
        var picker = pageStack.push(tagPickerDialog);
    }



    Component {
        id: tagPickerDialog

        Dialog {
            id: dialog

            property string filter

            SilicaFlickable {
                anchors {
                    fill: parent
                }

                Column {
                    id: column

                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    height: contentHeight

                    DialogHeader {
                        id: dialogHeader
                    }

                    SearchField {
                        id: searchField

                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                    }

                    Flow {
                        id: selection

                        anchors {
                            left: parent.left
                            margins: Theme.paddingLarge
                            right: parent.right
                        }
                        height: parent.height - searchField.height - column.spacing
                        spacing: Theme.paddingMedium

                        Repeater {
                            delegate: Tag {
                                id: tag

                                selected: model.selected
                                tag: model.tag

                                ListView.onAdd: AddAnimation {
                                    target: tag
                                }

                                ListView.onRemove: RemoveAnimation {
                                    target: tag
                                }
                            }
                            model: tagsModel
                        }
                    }
                }

                VerticalScrollDecorator {}
            }

            ListModel {
                id: tags

                ListElement {
                    tag: "quick"
                    selected: false
                }
                ListElement {
                    tag: "idea"
                    selected: false
                }
                ListElement {
                    tag: "health"
                    selected: false
                }
                ListElement {
                    tag: "work"
                    selected: false
                }
                ListElement {
                    tag: "SailfishOS"
                    selected: true
                }
                ListElement {
                    tag: "dev"
                    selected: true
                }
                ListElement {
                    tag: "sport"
                    selected: false
                }
                ListElement {
                    tag: "tagged"
                    selected: false
                }
                ListElement {
                    tag: "testing"
                    selected: true
                }
                ListElement {
                    tag: "Reminders app"
                    selected: false
                }
                ListElement {
                    tag: "UI"
                    selected: false
                }
                ListElement {
                    tag: "UX"
                    selected: true
                }
                ListElement {
                    tag: "WIP"
                    selected: true
                }
            }

            SortFilterModel {
                id: tagsModel

                filter {
                    property: "tag"
                    value: searchField.text
                }
                sort {
                    property: "tag"
                    order: Qt.AscendingOrder
                }
                model: tags
            }
        }
    }
}
