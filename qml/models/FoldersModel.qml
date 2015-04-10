import QtQuick 2.0

//import "database.js" as Storage

ListModel {
    id: model


    signal refresh();


    ListElement {
        value: "Today"
        nbItems: 0
        page: "Today.qml"
        category: "folder"
    }
    ListElement {
        value: "Next 7 days"
        nbItems: 0
        page: "Week.qml"
        category: "folder"
    }
    ListElement {
        value: "Overdue"
        nbItems: 0
        page: "Overdue.qml"
        category: "folder"
    }
    ListElement {
        value: "Someday"
        nbItems: 0
        page: "Someday.qml"
        category: "folder"
    }
    ListElement {
        value: "Completed"
        nbItems: 0
        page: "Completed.qml"
        category: "folder"
    }
    ListElement {
        value: "Trash"
        nbItems: 0
        page: "Deleted.qml"
        category: "folder"
    }

    /**
     * Load projects from projectsModel and append them to our Model.
     */
    function load()
    {
        var offset = 6                      // We have 6 Folders before the Projects
        var old_n = model.count - offset    // Number of Projects before the update
        var new_n = projectsModel.count     // Number of Projects right now

        // We remove the extra items from the model :
        while(old_n > new_n)
        {
            old_n -= 1
            remove(offset + old_n)  // Remove the last item
        }

        for(var i=0 ; i<projectsModel.count ; i++)
        {
            model.set(offset + i, projectsModel.get(i))
        }
    }

    /**
     * Update counters for folders.
     */
    function updateCounters()
    {
        model.setProperty(0, "nbItems", Storage.countTodayTasks())
        model.setProperty(1, "nbItems", Storage.countWeekTasks())
        model.setProperty(2, "nbItems", Storage.countOverdueTasks())
        model.setProperty(3, "nbItems", Storage.countSomedayTasks())
        model.setProperty(4, "nbItems", Storage.countCompletedTasks())
        model.setProperty(5, "nbItems", Storage.countDeletedTasks())
    }

/*
    Component.onCompleted: {
        projectsModel.dataLoaded.connect(load)

        refresh.connect(updateCounters)
        refresh.connect(projectsModel.refresh)
    }
*/
}
