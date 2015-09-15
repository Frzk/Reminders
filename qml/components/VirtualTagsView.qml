/*



 */

import QtQuick 2.0
import Sailfish.Silica 1.0

import org.kubler.Reminders 1.0

import "../components"

Flow {
    id: root

    property VirtualTagsModel model

    property var _virtualTags: {
        "vt_pending": qsTr("pending"),
        "vt_completed": qsTr("completed"),
        "vt_deleted": qsTr("deleted"),
        "vt_overdue": qsTr("overdue"),
        "vt_due": qsTr("due"),
        "vt_today": qsTr("today"),
        "vt_yesterday": qsTr("yesterday"),
        "vt_tomorrow": qsTr("tomorrow"),
        "vt_week": qsTr("week"),
        "vt_month": qsTr("month"),
        "vt_year": qsTr("year"),
        "vt_until": qsTr("until"),
        "vt_active": qsTr("active"),
        "vt_scheduled": qsTr("scheduled"),
        "vt_tagged": qsTr("tagged"),
        "vt_annotated": qsTr("annotated"),
        "vt_waiting": qsTr("waiting"),
        "vt_parent": qsTr("parent"),
        "vt_child": qsTr("child"),
        "vt_blocked": qsTr("blocked"),
        "vt_blocking": qsTr("blocking"),
        "vt_ready": qsTr("ready")
    }

    anchors {
        left: parent.left
        margins: Theme.paddingLarge
        right: parent.right
    }
    spacing: Theme.paddingMedium

    Repeater {
        delegate: Tag {
            enabled: false
            tag: _virtualTags.hasOwnProperty(display) ? _virtualTags[display] : display
        }
        model: root.model
    }
}
