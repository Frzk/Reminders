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

    property string project

    SilicaListView {
        anchors.fill: parent
        delegate: FolderDelegate {}
        header: PageHeader {
            title: qsTr("Reminders")
        }
        model: FoldersModel {
            id: foldersModel
        }
        section {
            criteria: ViewSection.FullString
            delegate: SectionHeader {
                font {
                    capitalization: Font.Capitalize
                }
                text: Helpers.i18nCategory(section)
            }
            property: 'category'
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Add a Reminder...")
            }
            MenuItem {
                text: "Reminder view"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Reminder.qml"))
                }
            }
            MenuItem {
                text: "Reminder editor"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ReminderEditor.qml"))
                }
            }
        }

        VerticalScrollDecorator {}
    }

    //FIXME:
    onStatusChanged: {
        if(status === PageStatus.Active)
        {
            foldersModel.refresh();
        }
    }
}
