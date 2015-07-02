.pragma library

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



/**
 * Returns a translated version of the given status.
 *
 * @param   string  s   Status, as stored in the database.
 * @return  string  Translated value of the given status.
 */
function statusToText(s)
{
    var r = qsTr("Pending")

    switch(s)
    {
        case "c":
            r = qsTr("Completed")
            break
        case "r":
            r = qsTr("Recurring")
            break
        case "w":
            r = qsTr("Waiting")
            break
        case "d":
            r = qsTr("Deleted")
            break
    }

    return r
}

/**
 * Returns a translated version of the given priority.
 *
 * @param   string  p   Priority, as stored in the database.
 * @return  string  Translated value of the given priority.
 */
function proprityToText(p)
{
    var r = qsTr("None")

    switch(p)
    {
        case "L":
            r = qsTr("Low")
            break
        case "M":
            r = qsTr("Medium")
            break
        case "H":
            r = qsTr("High")
            break
    }

    return r
}

/**
 * Formats the given date/time/datetime in a locale-respectful, human-friendly string.
 *
 * @param   string    s     String representing the date/time/datetime we want to display.
 * @return  string          Date representation, according to the locale.
 */
function formatDatetime(s)
{
    var r = "";

    if(Date.parse(s))
    {
        var d = new Date(s);

        // Check if we have a date :
        if(d.getFullYear() && d.getMonth() && d.getDate())
        {
            var dDate = new Date(d.getFullYear(), d.getMonth(), d.getDate());

            var now = new Date();
            var todayDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
            var tomorrowDate = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1);
            var yesterdayDate = new Date(now.getFullYear(), now.getMonth(), now.getDate() - 1);

            switch(dDate.valueOf())
            {
                case todayDate.valueOf():
                    r = qsTr("Today");
                    break;
                case tomorrowDate.valueOf():
                    r = qsTr("Tomorrow");
                    break;
                case yesterdayDate.valueOf():
                    r = qsTr("Yesterday");
                    break;
                default:
                    r = Qt.formatDate(d);   // Defaults to Qt.DefaultLocaleShortDate, which is OK.
                    break;
            }
        }

        // Check if we have a time :
        if(d.getHours() && d.getMinutes())
            r += " " + Qt.formatTime(d);
    }

    return r;
}
