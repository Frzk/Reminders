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

/**
 * TODOS and FIXMES:
 *   - Due date / time picker
 *   - Create new Project dialog
 *   - Dependencies
 *   - Annotations
 *   - Dialog.onAccepted
 *   - Tags editor dialog
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"
import "../pragma/Helpers.js" as Helpers

Dialog {
    id: dialog


    //property int taskIndex: -1
    //property var task: null


    SilicaFlickable
    {
        anchors.fill: parent

        VerticalScrollDecorator {}

        DialogHeader {
            id: header

            acceptText: qsTr("Save") //taskIndex >= 0 ? qsTr("Update") : qsTr("Create")
        }

        TextArea {
            id: description

            anchors {
                left: parent.left
                right: parent.right
                top: header.bottom
            }
            font {
                pixelSize: Theme.fontSizeLarge
            }
            label: placeholderText
            placeholderText: qsTr("Description")
            text: "This is what I have to do, and it's kinda long, mmmkay ?"
            wrapMode: Text.WordWrap

            EnterKey.enabled: text.length > 0
            EnterKey.iconSource: "image://theme/icon-m-enter-next"
        }

        SectionHeader {
            id: sectionInformation
            anchors {
                top: description.bottom
            }
            text: qsTr("Information")
        }

        ComboBox {
            id: priority

            anchors {
                top: sectionInformation.bottom
            }
            label: qsTr("Priority")
            menu: ContextMenu {
                MenuItem { text: qsTr("No priority") }
                MenuItem { text: qsTr("Low") }
                MenuItem { text: qsTr("Medium") }
                MenuItem { text: qsTr("High") }
            }

            onValueChanged: console.log("New priority: ", value)
        }
/*
        ValueButton {
            id: status

            anchors {
                top: priority.bottom
            }
            label: qsTr("Status")
            value: qsTr("Pending")
            enabled: false
        }
*/
        ValueButton {
            id: project

            anchors {
                top: priority.bottom
            }
            label: qsTr("Project")
            value: qsTr("No project")

            onClicked: {
                var projectPicker = pageStack.push(Qt.resolvedUrl("../pages/ProjectPickerDialog.qml"))

                projectPicker.accepted.connect(function() {
                    value = projectPicker.project
                    console.log("New project : ", value)
                })
            }
        }

        DateTimePicker {
            id: dateTimePicker

            anchors {
                top: project.bottom
            }
            dateLabel: qsTr("Due date")
            timeLabel: qsTr("Due time")
        }
/*
        ValueButton
        {
            id: waitDate

            property bool _menuOpen: waitDateContextMenu !== null && waitDateContextMenu.parent === waitDate
            property variant valueObject    // This is the real value, the one that will be stored in the database.
                                            // The built-in value property is only suitable for displaying purpose.

            anchors {
                top: dueDate.bottom
            }
            description: value ? ""
                               : qsTr("The task will remain hidden until this date.")
            height: contentItem.height + (_menuOpen ? waitDateContextMenu.height : 0)
            label: value ? qsTr("Don't show before") : qsTr("Set a wait date")

            DatePickerDialog {
                id: waitPicker

                onAccepted: {
                    waitDate.valueObject = date
                }

                onOpened: {
                    if(waitDate.valueObject)
                        waitPicker.date = waitDate.valueObject
                }
            }

            ContextMenu {
                id: waitDateContextMenu

                MenuItem {
                    text: qsTr("Remove wait date")
                    onClicked: {
                        waitDateRemorse.execute(waitDate, qsTr("Removing wait date"), function() {
                            waitDate.valueObject = null
                        }, 3000)
                    }
                }
            }

            RemorseItem {
                id: waitDateRemorse
            }

            onClicked: {
                pageStack.push(waitPicker)
            }

            onPressAndHold: {
                if(valueObject)
                    waitDateContextMenu.show(waitDate)
            }

            onValueObjectChanged: {
                value = Utils.formatDatetime(valueObject)
            }
        }
*/
/*
        BackgroundItem {
            id: tagEditor

            property alias tags: tags
            property alias vtags: vtags

            anchors {
                top: waitDate.bottom
            }
            contentHeight: visible ? tagEditorColumn.height + Theme.paddingLarge : 0
            height: contentItem.height

            Column {
                id: tagEditorColumn

                anchors {
                    left: parent.left
                    right: parent.right
                }

                SectionHeader {
                    text: qsTr("Tags")
                }

                Flow {
                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: Theme.paddingLarge
                    }
                    spacing: Theme.paddingMedium

                    Repeater {
                        id: tags

                        delegate: Tag {
                            color: Qt.rgba(255, 255, 255, 0.2)
                            tag: model.value
                        }
                    }

                    Repeater {
                        id: vtags

                        delegate: Tag {
                            tag: model.value
                        }
                    }
                }
            }

            onClicked: {
                console.log("Open Tag editor dialog.")
            }
        }
*/
/*
        SectionHeader {
            text: qsTr("Dependencies")
        }

        SectionHeader {
            text: qsTr("Annotations")
        }
*/
    }


    onAccepted: {
        //FIXME: todo
    }
}
