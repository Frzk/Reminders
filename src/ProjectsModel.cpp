#include "ProjectsModel.h"



enum Roles {
    NameRole = Qt::UserRole + 1,        // Name of the project
    //IsSelectedRole,                     // Whether THIS project is the current one for the reminder
    //NbRole,                             // Number of reminders in THIS project
};



ProjectsModel::ProjectsModel(QObject *parent) : QSqlQueryModel(parent)
{
}

ProjectsModel::~ProjectsModel()
{
}

QHash<int, QByteArray> ProjectsModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    roles[NameRole] = "project";
    //roles[IsSelectedRole] = "isSelected";
    //roles[NbRole] = "nb";

    return roles;
}

QVariant ProjectsModel::data(const QModelIndex &index, int role) const
{
    QVariant r = QSqlQueryModel::data(index, role);

    if(role >= Qt::UserRole)
    {
        int columnIndex = role - Qt::UserRole - 1;
        QModelIndex idx = this->index(index.row(), columnIndex);

        r = QSqlQueryModel::data(idx, Qt::DisplayRole);
    }

    return r;
}

void ProjectsModel::refresh()
{
    this->setQuery("SELECT DISTINCT project FROM reminders ORDER BY project COLLATE localeCollation ASC");

    qDebug() << QString("ProjectsModel refreshed !");
}


/*
QString ProjectsModel::getSelectedProject() const
{
    return this->m_selectedProject;
}

bool ProjectsModel::setSelectedProject(const QString &s)
{
    bool r = false;

    if(s != this->m_selectedProject)
    {
        this->m_selectedProject = s;
        r = true;
        emit selectedProjectChanged();
    }

    return r;
}
*/
