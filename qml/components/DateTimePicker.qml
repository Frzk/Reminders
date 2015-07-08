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

import "../pragma/Helpers.js" as Helpers


Column {
    id: root

    property date datetimeObj
    property date dateObj
    property date timeObj

    anchors {
        left: parent.left
        right: parent.right
    }

    ValueButton {
        id: datePicker

        label: Date.parse(dateObj) ? qsTr("Due date") : qsTr("Set a due date")
        value: Helpers.formatDateOnly(dateObj)

        onClicked: {
            var picker = pageStack.push("Sailfish.Silica.DatePickerDialog", { date: new Date() })

            picker.accepted.connect(function() {
                dateObj = picker.date
            });
        }
    }

    ValueButton {
        id: timePicker

        label: Date.parse(timeObj) ? qsTr("Due time") : qsTr("Set a due time")
        value: Helpers.formatTimeOnly(timeObj)
        visible: Date.parse(dateObj)

        onClicked: {
            var picker = pageStack.push("Sailfish.Silica.TimePickerDialog", { date: new Date() })

            picker.accepted.connect(function() {
                timeObj = picker.time
            });
        }
    }

    Component.onCompleted: {
        console.log(dateObj);
        console.log(timeObj);
    }
}
