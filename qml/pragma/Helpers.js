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
