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


Dialog {
    id: projectDialog

    property Item selectedItem: null
    property string project: selectedItem ? selectedItem.text : ""

    canAccept: selectedItem

    Column {
        id: headerContainer

        property alias searchField: searchField

        width: projectDialog.width

        DialogHeader {
            id: dialogHeader

            acceptText: project
        }

        SearchField {
            id: searchField

            placeholderText: projectsList.count > 0 ? qsTr("Search") : qsTr("Create a new project")
            width: parent.width

            onTextChanged: {
                selectedItem = null
                projectsModel.setFilterFixedString(text.trim())
            }
        }

        BackgroundItem {
            id: newProject

            property alias text: searchField.text

            visible: ! (searchField.text === "" || (projectsList.count === 1 && searchField.text.toLocaleLowerCase() === projectsModel.get(0).project.toLocaleLowerCase()))

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.paddingMedium
                x: searchField.textLeftMargin - icon.width - spacing

                Image {
                    id: icon

                    height: label.height
                    source: "image://theme/icon-m-add"
                    width: height
                }

                Label {
                    id: label

                    color: newProject.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    textFormat: Text.StyledText
                    text: qsTr("%1 (new project)").arg(Theme.highlightText(searchField.text, searchField.text, Theme.highlightColor))
                }
            }

            onClicked: {
                selectedItem = this
            }
        }
    }

    ProjectsModel {
        id: projectsModel
    }

    SilicaListView
    {
        id: projectsList

        anchors.fill: parent
        currentIndex: -1
        delegate: BackgroundItem {
            id: backgroundItem

            property string text: project

            Label {
                id: label

                anchors.verticalCenter: parent.verticalCenter
                color: searchField.text.length > 0 ? (highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor)
                                                   : (highlighted ? Theme.highlightColor : Theme.primaryColor)
                textFormat: Text.StyledText
                text: Theme.highlightText(project, searchField.text, Theme.highlightColor)
                x: searchField.textLeftMargin
            }

            ListView.onAdd: AddAnimation {
                target: backgroundItem
            }

            ListView.onRemove: RemoveAnimation {
                target: backgroundItem
            }

            onClicked: {
                selectedItem = this
            }
        }
        header: Item {
            id: header

            height: headerContainer.height
            width: headerContainer.width

            Component.onCompleted: {
                headerContainer.parent = header
            }
        }
        model: projectsModel


        VerticalScrollDecorator {}
    }
}