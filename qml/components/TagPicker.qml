/*



 */

import QtQuick 2.0
import Sailfish.Silica 1.0

import org.kubler.Reminders 1.0

import "../components"

BackgroundItem {
    id: root

    property TagsModel model
    property VirtualTagsModel vmodel

    property var _virtualTags: {
        "vt_pending":   qsTr("pending"),
        "vt_completed": qsTr("completed"),
        "vt_deleted":   qsTr("deleted"),
        "vt_overdue":   qsTr("overdue"),
        "vt_due":       qsTr("due"),
        "vt_today":     qsTr("today"),
        "vt_yesterday": qsTr("yesterday"),
        "vt_tomorrow":  qsTr("tomorrow"),
        "vt_week":      qsTr("week"),
        "vt_month":     qsTr("month"),
        "vt_year":      qsTr("year"),
        "vt_until":     qsTr("until"),
        "vt_active":    qsTr("active"),
        "vt_scheduled": qsTr("scheduled"),
        "vt_tagged":    qsTr("tagged"),
        "vt_annotated": qsTr("annotated"),
        "vt_waiting":   qsTr("waiting"),
        "vt_parent":    qsTr("parent"),
        "vt_child":     qsTr("child"),
        "vt_blocked":   qsTr("blocked"),
        "vt_blocking":  qsTr("blocking"),
        "vt_ready":     qsTr("ready")
    }

    height: tagFlow.height + 2 * Theme.paddingMedium
    width: parent.width

    Flow {
        id: tagFlow

        anchors {
            left: parent.left
            margins: Theme.paddingLarge
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        spacing: Theme.paddingSmall

        Repeater {
            id: tagsRepeater

            delegate: Tag {
                enabled: false
                fontColor: root.highlighted ? Theme.highlightColor : Theme.primaryColor
                tag: model.tag
            }
            model: root.model
        }

        Repeater {
            id: virtualTagsRepeater

            delegate: VirtualTag {
                fontColor: root.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                tag: _virtualTags.hasOwnProperty(display) ? _virtualTags[display] : display
            }
            model: root.vmodel
        }
    }


    onClicked: {
        var picker = pageStack.push("../pages/TagPickerDialog.qml", { selectedTags: root.model })

        picker.accepted.connect(function() {
            var newTags = picker.selection.selection()
            root.model.update(newTags)
            root.vmodel.refresh()
        });

        picker.rejected.connect(function() {
            picker.model.revertAll()
        });
    }
}
