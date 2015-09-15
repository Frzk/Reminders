import QtQuick 2.0
import Sailfish.Silica 1.0

import org.kubler.Reminders 1.0

Dialog {
    id: dialog

    property variant availableTags
    property variant selectedTags

    function init()
    {
        console.log("Initializing _tags...")
        console.log(sourceModel.count, "tags to add.")

        _tags.clear();

        for(var i=0 ; i<availableTags.count ; i++)
        {
            var current = availableTags.get(i)

            _tags.append({
                tag_id: current.tag_id,
                tag: current.tag,
                selected: false,
                deletable: false,
            })

            console.log("+", current.tag)
        }

        /*
        for(var j=0 ; j<selectedTags.count ; j++)
        {
            var current = selectedTags.get(j);
            // find current.tag in _tags

            _tags.setProperty( , "selected", true);
        }
        */
    }

    function createTag(tag)
    {
        _tags.append({
            tag_id: -1,
            tag: tag,
            selected: true,
            deletable: true,
        });

        this.selected = false;
        searchField.text = "";
    }

    function removeTag(tag)
    {
        var found = false;

        for(var j = _tags.count-1 ; j > 0 && !found ; j--)
        {
            if(_tags.get(j).tag === tag)
            {
                _tags.remove(j);
                found = true;
            }
        }

        return found;
    }

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
            //height: contentHeight

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
                                             && searchField.text.toLocaleLowerCase() === filterableModel.get(0).tag.toLocaleLowerCase()))

                    onClicked: {
                        createTag(searchField.text.trim())
                    }
                }

                Repeater {
                    delegate: Tag {
                        id: tagDelegate

                        selected: model.selected
                        tag: model.tag

                        onClicked: {
                            if(deletable)
                                removeTag(model.tag)
                            else
                            {
                                console.log("Index:", index);
                                var r = filterableModel.sourceModel.setProperty(filterableModel.getSourceIndex(index), "selected", !model.selected);
                                console.log("Success ?", r);
                            }
                        }
                    }
                    model: filterableModel
                }
            }
        }

        VerticalScrollDecorator {}
    }

    ListModel {
        id: _tags
    }

    SortFilterModel {
        id: filterableModel

        sourceModel: _tags
        filter {
            property: "tag"
            value: searchField.text
        }
        sort {
            property: "tag"
            order: Qt.AscendingOrder
        }
    }

    /*
    SortFilterModel {
        id: selected

        sourceModel: dialog.sourceModel
        filter {
            property: "selected"
            value: "true"
        }
        sort {
            property: "tag"
            order: Qt.AscendingOrder
        }
    }
    */

    onAccepted: {
        console.log("Accepted !")
        var st = [];

        for(var i=0 ; i<_tags.count ; i++)
        {
            if(_tags.get(i).selected)
                st.push(_tags.get(i).tag);
        }

        selectedTags = st;

        console.log("New tags:", st.join(","));
    }

    Component.onCompleted: {
        init()
    }
}
