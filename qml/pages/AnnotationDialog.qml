import QtQuick 2.0
import Sailfish.Silica 1.0

import org.kubler.Reminders 1.0


Dialog {
    id: dialog

    property alias annotation: annotationArea.text
    property bool isNew: false

    DialogHeader {
        id: header

        title: isNew ? qsTr("New annotation") : qsTr("Annotation")
    }

    TextArea {
        id: annotationArea

        anchors {
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            right: parent.right
            rightMargin: anchors.leftMargin
            top: header.bottom
        }
        placeholderText: qsTr("Annotation")
    }
}
