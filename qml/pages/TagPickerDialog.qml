import QtQuick 2.0
import Sailfish.Silica 1.0

import org.kubler.Reminders 1.0

import "../components"

Dialog {
    id: dialog


    property TagsModel selectedTags
    property alias selection: selectionModel
    property alias model: selectionModel.sourceModel


    function appendTag()
    {
        if(newItem.visible)
            selectionModel.append({
                tag_id: -1,
                tag: searchField.text.trim(),
                isSelected: true
            })
        else
            selectionModel.select(0)
    }


    SortFilterSelectionModel {
        id: selectionModel

        sourceModel: AvailableTagsModel {}
        filter {
            property: "tag"
            value: searchField.text
        }
        sort {
            property: "tag"
            order: Qt.AscendingOrder
        }
    }

    SilicaFlickable {

        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column

            anchors {
                left: parent.left
                right: parent.right
            }

            DialogHeader {
                id: dialogHeader
            }

            SearchField {
                id: searchField

                anchors {
                    left: parent.left
                    right: parent.right
                }

                EnterKey.enabled: text.length > 0
                EnterKey.onClicked: {
                    appendTag()
                    this.text = ""
                }
            }

            Flow {
                id: selection

                anchors {
                    left: parent.left
                    margins: Theme.paddingLarge
                    right: parent.right
                }
                //height: parent.height - searchField.height - column.spacing
                spacing: Theme.paddingLarge

                Tag {
                    id: newItem

                    tag: searchField.text.trim()
                    selected: false
                    // This item always visible unless :
                    //     - searchField is empty ;
                    //     - OR there is already a tag by that exact name.
                    visible: ! (searchField.text === "" || selectionModel.contains("tag", searchField.text.toLocaleLowerCase()))

                    onClicked: {
                        appendTag()
                        this.selected = false
                        searchField.text = ""
                    }
                }

                Repeater {
                    delegate: Tag {
                        id: tagDelegate

                        selected: isSelected
                        tag: model.tag

                        onClicked: {
                            if(tag_id === -1)
                                selectionModel.remove(index)
                            else
                            {
                                if(!selected)
                                    selectionModel.select(index)
                                else
                                    selectionModel.deselect(index)
                            }
                        }
                    }
                    model: selectionModel
                }
            }
        }

        VerticalScrollDecorator {}
    }


    Component.onCompleted: {
        for(var i=0 ; i<selectionModel.count ; i++)
        {
            selectionModel.select(i);
        }
    }
}
