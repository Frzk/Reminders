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

import "../components"


Page {
    id: page

    /**
     * Return the translated name of the given section.
     * Needed because we can't use qsTr in the ListModel :(
     */
    function i18nCategory(c)
    {
        var r = qsTr("Smart Folders")

        if(c === "project")
            r = qsTr("Projects")

        return r
    }

    /**
     * Return the translated name for the Smart Folders.
     * Smart Folders are gathered from the database with an "id-number"
     * that need to be transformed into a suitable, human-friendly name.
     */
    function i18nSmartFolder(n)
    {
        var r = "";

        switch(n)
        {
            case "01":
                r = qsTr("Today");
                break;
            case "02":
                r = qsTr("Overdue");
                break;
            case "03":
                r = qsTr("Next 7 days");
                break;
            case "04":
                r = qsTr("Someday");
                break;
            case "05":
                r = qsTr("Completed");
                break;
            case "06":
                r = qsTr("Trash");
                break;
            default:
                r = n;
                break;
        }

        return r;
    }

    SilicaListView {
        anchors.fill: parent
        delegate: FolderDelegate {}
        header: PageHeader {
            title: qsTr("Reminders")
        }
        model: foldersModel
        section {
            criteria: ViewSection.FullString
            delegate: SectionHeader {
                font {
                    capitalization: Font.Capitalize
                }
                text: i18nCategory(section)
            }
            property: 'category'
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Add a Reminder...")
            }
        }

        VerticalScrollDecorator {}
    }

    /*
    onStatusChanged: {
        if(status === PageStatus.Active)
        {
            foldersModel.refresh();
        }
    }
    */
}
