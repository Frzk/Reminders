/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


import QtQuick 2.0
import Sailfish.Silica 1.0

import org.kubler.Reminders 1.0

import "../components"
import "../pragma/Helpers.js" as Helpers


Page {
    id: page

    property string reminder_uuid: "d1d43cae-60a2-454b-93c3-bab0e6233af9"

    // FIXME: dummy values, for testing purpose
    property var date_created: new Date(2015, 5, 12, 14, 38, 12, 234);
    property var date_updated: new Date();
    property var date_due: new Date();
    property string reminder_status: "p";
    property string reminder_priority: "M";
    property string reminder_description: "This is what I have to do, and it's kinda long, mmmkay ?";
    property string reminder_project: "No project"


    SilicaFlickable
    {
        anchors.fill: parent
        contentHeight: column.height

        RemorsePopup {
            id: remorse
        }

        PullDownMenu {
            /*
             * Actions:
             *    - Move to Trash
             *    - Edit
             *    - Reopen
             *    - Restore
             *    - Mark as completed
             *    - Start
             */
            /*
            MenuItem {
                text: qsTr("Move to Trash")
            }
            */

            MenuItem {
                text: qsTr("Edit")
                //visible: task ? (task.status !== "completed" && task.status !== "deleted") : false

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ReminderEditor.qml"),
                                   {
                                       tagsModel: tagsModel,
                                       annotationsModel: annotationsModel,
                                   });
                }
            }
            /*
            MenuItem {
                text: qsTr("Reopen")
                //visible: task ? task.status === "completed" : false

                onClicked: {
                    markAsPending()
                }
            }

            MenuItem {
                text: qsTr("Restore")
                //visible: task ? task.status === "deleted" : false

                onClicked: {
                    markAsPending()
                }
            }

            MenuItem {
                text: qsTr("Mark as Completed")
                //visible: task ? task.status === "pending" : false

                onClicked: {
                    markAsCompleted()
                }
            }

            MenuItem {
                text: qsTr("Start")
                //visible: task ? (task.status === "pending" && !task.start) : false
            }
            */
        }

        Column {
            id: column

            anchors {
                left: parent.left
                right: parent.right
            }
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr("Task")
            }

            Label {
                id: description

                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingLarge
                }
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
                text: reminder_description
                wrapMode: Text.WordWrap
            }

            SectionHeader {
                text: qsTr("Information")
            }

            DetailItem {
                id: status

                label: qsTr("Status")
                value: Helpers.statusToText(reminder_status)
            }

            DetailItem {
                id: start

                label: qsTr("Started")
                visible: false //task ? task.start : false
            }

            DetailItem {
                id: completed

                label: qsTr("Completed")
                visible: false //task ? task.end : false
            }

            DetailItem {
                id: waiting

                label: qsTr("Waiting")
                visible: false //task ? task.wait : false
            }

            DetailItem {
                id: priority

                label: qsTr("Priority")
                value: Helpers.proprityToText(reminder_priority)
            }

            DetailItem {
                id: project

                label: qsTr("Project")
                value: reminder_project //task ? (task.project ? task.project : qsTr("No project")) : qsTr("No project")
            }

            DetailItem {
                id: due

                label: qsTr("Due for")
                value: Helpers.formatDatetime(date_due)
            }

            DetailItem {
                id: created

                label: qsTr("Created")
                value: Helpers.formatDatetime(date_created)
            }

            DetailItem {
                id: updated

                label: qsTr("Last modified")
                value: Helpers.formatDatetime(date_updated)
            }

            SectionHeader {
                text: qsTr("Tags")
            }

            TagPicker {
                id: tagPicker

                enabled: true
                model: tagsModel
                vmodel: virtualTagsModel
            }

            /*
            SectionHeader {
                text: qsTr("Dependencies")
            }

            DependenciesView {
                editable: false
                model: dependenciesModel
            }
            */

            SectionHeader {
                text: qsTr("Annotations")
            }

            AnnotationsView {
                editable: false
                model: annotationsModel
            }
        }

        VerticalScrollDecorator {}
    }

    /*
    ReminderModel {
        id: reminder

        reminderUUID: reminder_uuid

        onDataChanged: {
            virtualTagsModel.refresh()
        }
    }
    */

    TagsModel {
        id: tagsModel

        reminderUUID: reminder_uuid
    }

    VirtualTagsModel {
        id: virtualTagsModel

        reminderUUID: reminder_uuid
    }

    AnnotationsModel {
        id: annotationsModel

        reminderUUID: reminder_uuid
    }
}
