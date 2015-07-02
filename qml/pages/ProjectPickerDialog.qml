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


Dialog {
    id: projectDialog


    property string projectName: projectsList.headerItem.newProject.checked ? projectsList.headerItem.newProject.text : projectsList.selectedValue


    canAccept: projectName !== ""


    SilicaListView
    {
        id: projectsList

        property Item selectedItem: null
        property string selectedValue: selectedItem ? selectedItem.text : ""

        onSelectedItemChanged: {
            console.log(selectedItem)
        }

        anchors.fill: parent
        currentIndex: -1
        delegate: TextSwitch {
            checked: false
            text: Theme.highlightText(project, projectsList.headerItem.search.text, Theme.highlightColor)

            onCheckedChanged: {
                if(checked)
                {
                    if(projectsList.selectedItem)
                        projectsList.selectedItem.checked = false

                    projectsList.selectedItem = this
                }
                else
                {
                    projectsList.selectedItem = null
                }
            }
        }
        header: Column {

            property alias search: search
            property alias newProject: newProject

            width: parent.width

            DialogHeader {
                id: dialogHeader

                acceptText: projectName
            }

            SearchField {
                id: search

                width: parent.width

                onTextChanged: {
                    model.update(text)
                }
            }

            TextSwitch {
                id: newProject

                description: checked ? "" : qsTr("Check to create this project.")
                height: Theme.itemSizeMedium
                text: search.text
                visible: search.text !== ""
            }
        }
        model: ListModel {
            id: model

            property var projects: ["Testing", "Home", "Reminders", "StrasbourgParking", "Helmo", "SprayGallery"]

            function update(terms)
            {
                clear();
                for(var i=0 ; i<projects.length ; i++)
                {
                    if(terms === "" || projects[i].toLowerCase().indexOf(terms.toLowerCase()) >= 0)
                        append({ project: projects[i] })
                }
            }

            Component.onCompleted: update("")
        }


        VerticalScrollDecorator {}
    }

    Binding {
        property: "checked"
        target: projectsList.headerItem.newProject
        value: projectsList.count === 0 && projectsList.headerItem.search.text !== 0
    }

    Binding {
        property: "enabled"
        target: projectsList.headerItem.newProject
        value: projectsList.count !== 1 || projectsList.headerItem.search.text !== model.get(0).project
    }

    //FIXME
    //  When we have an exact match,
    //  modify the model and set selected=true for the corresponding item.
    //  Setting selected=true will trigger an "onCheckedChanged" that will unselect all other items.
    //  This will set projectsList.selectedItem, and projectsList.selectedValue.
    //  At least, it will set projectDialog.projectName.
    /*
    Binding {
        property: "selected"
        target: model.get(0)
        value: projectsList.count === 1 && projectsList.headerItem.search.text === model.get(0).project
    }
    */


    onAccepted: {
        //FIXME
    }

    Component.onCompleted: {
        console.log(projectsList.contentItem.children[1].children[3])
    }
}
