import QtQuick 2.0
import Sailfish.Silica 1.0

import org.kubler.Reminders 1.0

Dialog {
    id: dialog


    property TagsSelectionModel availableTags
    property TagsModel selectedTags


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

                Tag {
                    id: newItem

                    tag: searchField.text.trim()
                    selected: false
                    visible: ! (searchField.text === ""
                                         || (filterableModel.count === 1
                                             && searchField.text.toLocaleLowerCase() === filterableModel.data(0, "tag").toLocaleLowerCase()))

                    onClicked: {
                        filterableModel.append({
                            tag_id: -1,
                            tag: searchField.text.trim(),
                            isSelected: true
                        })
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
                                filterableModel.remove(index)
                            else
                                filterableModel.set(index, "isSelected", !isSelected)
                        }
                    }
                    model: filterableModel
                }
            }
        }

        VerticalScrollDecorator {}
    }

    SortFilterModel {
        id: filterableModel

        sourceModel: availableTags
        filter {
            property: "tag"
            value: searchField.text
        }
        sort {
            property: "tag"
            order: Qt.AscendingOrder
        }
    }


    onRejected: {
        availableTags.revertAll()
    }
}
