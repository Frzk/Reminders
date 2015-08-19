#include "ProjectsModel.h"



enum Roles {
    NameRole = Qt::UserRole + 1,        // Name of the project
    //NbRole,                             // Number of reminders in THIS project
};



ProjectsModel::ProjectsModel(QObject *parent) : QSqlQueryModel(parent)
{
    this->refresh();
}

ProjectsModel::~ProjectsModel()
{
}

QHash<int, QByteArray> ProjectsModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    roles[NameRole] = "project";
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
}
