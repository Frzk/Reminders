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

ListItem {
    id: listItem

    anchors {
        left: parent.left
        right: parent.right
    }
    contentHeight: Theme.itemSizeSmall
    menu: category === "project" ? contextMenu : null

    Label {
        id: folderLabel

        anchors {
            left: parent.left
            leftMargin: Theme.paddingLarge
            right: countLabel.left
            rightMargin: Theme.paddingLarge
            verticalCenter: parent.verticalCenter
        }
        color: highlighted ? Theme.highlightColor : Theme.primaryColor
        font.pixelSize: Theme.fontSizeMedium
        text: value
        truncationMode: TruncationMode.Fade
    }
    Label
    {
        id: countLabel

        anchors {
            baseline: folderLabel.baseline
            right: parent.right
            rightMargin: Theme.paddingLarge
        }
        color: highlighted ? Theme.highlightColor : Theme.secondaryColor
        font.pixelSize: Theme.fontSizeSmall
        horizontalAlignment: Text.AlignRight
        text: nbItems
        truncationMode: TruncationMode.Fade
    }

    Component {
        id: contextMenu

        ContextMenu {
            MenuItem {
                text: qsTr("Rename")
                onClicked: edit()
            }
        }
    }

    ListView.onAdd: AddAnimation {
        target: listItem
    }

    ListView.onRemove: RemoveAnimation {
        target: listItem
    }

    onClicked: {
        console.log("Reminders for " + value)
        if(category === "project")
            pageStack.push(Qt.resolvedUrl("../pages/Project.qml"), {projectName: value})
        else
            pageStack.push(Qt.resolvedUrl("../pages/" + page))
    }

    function edit() {
        pageStack.push(Qt.resolvedUrl("../pages/EditProjectDialog.qml"), {listName: value})
    }
}
