/**
 *
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../pragma/Helpers.js" as Helpers


Page {
    id: page

    property string title: "";

    SilicaListView {
        anchors.fill: parent
        delegate: ListItem {
            id: listItem

            anchors {
                left: parent.left
                right: parent.right
            }
            contentHeight: Theme.itemSizeSmall

            Label {
                text: Helpers.i18nSmartFolder(name)
            }
        }
        header: PageHeader {
            title: Helpers.i18nSmartFolder(page.title)
        }
        /*
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
        */

        VerticalScrollDecorator {}
    }
}
