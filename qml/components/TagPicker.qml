/*



 */

import QtQuick 2.0
import Sailfish.Silica 1.0

import org.kubler.Reminders 1.0

import "../components"

BackgroundItem {
    id: root

    property TagsModel model

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
            id: tagsRepeater

            delegate: Tag {
                enabled: false
                selected: true
                tag: model.tag
            }
            model: root.model
        }
    }

    onClicked: {
        var picker = pageStack.push("TagPickerDialog.qml", { availableTags: availableTags, selectedTags: root.model });

        picker.accepted.connect(function() {
            console.log("Selection :")
            var newTags = picker.selection.selection();

            for(var i=0 ; i<newTags.length ; i++)
            {
                console.log("  ", newTags[i].tag_id, ":", newTags[i].tag);
            }

            //root.model = newTags;
        });
    }

    AvailableTagsModel {
        id: availableTags
    }
}
