/**
 *
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"
import "../pragma/Helpers.js" as Helpers


Page {
    id: page

    property string title: "";

    SilicaListView {
        anchors.fill: parent
        delegate: ReminderDelegate {}
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
