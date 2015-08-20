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

/**
 * The default Tag is a Label with a transparent background and a Theme.primaryColor color.
 *
 * When enabled, a Tag can be selected or deselected.
 *
 * If enabled and selected :
 *     The background is shown,
 *     The label color is Theme.highlightColor.
 *
 * If not enabled and selected : (typically, when you just want to display a list of Tags)
 *     The background is shown,
 *     The label color is Theme.primaryColor.
 *
 * If unselected (regardless of enabled) :
 *     The background is transparent,
 *     The label color is Theme.primaryColor.
 *
 */

MouseArea {
    id: root

    property alias color: rect.color
    property alias fontSize: label.font.pixelSize
    property alias highlighted: root.pressed
    property alias tag: label.text
    property bool selected: true

    height: label.height + Theme.paddingSmall * 2
    width: label.width + Theme.paddingLarge * 2


    Rectangle {
        id: rect

        anchors {
            centerIn: parent
            fill: parent
        }
        color: "transparent"
        radius: 9

        Label {
            id: label

            anchors {
                centerIn: parent
            }
            color: Theme.primaryColor
            font {
                //capitalization: Font.AllLowercase
                pixelSize: Theme.fontSizeExtraSmall
            }
        }
    }

    onClicked: {
        selected = !selected
    }

    ListView.onAdd: AddAnimation {
        target: root
    }

    ListView.onRemove: RemoveAnimation {
        target: root
    }

    states: [
        State {
            name: "SELECTED_ENABLED"
            when: root.selected && root.enabled

            PropertyChanges {
                color: Theme.rgba(Theme.highlightBackgroundColor, 0.15)
                target: rect
            }

            PropertyChanges {
                color: Theme.highlightColor
                target: label
            }
        },

        State {
            name: "SELECTED_DISABLED"
            extend: "SELECTED_ENABLED"
            when: root.selected && !root.enabled

            PropertyChanges {
                color: Theme.primaryColor
                target: label
            }
        }
    ]

    transitions: [
        Transition {
            reversible: true
            to: "*"

            ParallelAnimation {
                ColorAnimation {
                    duration: 100
                    easing.type: Easing.InOutQuad
                    target: rect
                }

                ColorAnimation {
                    duration: 100
                    easing.type: Easing.InOutQuad
                    target: label
                }
            }
        }
    ]
}
