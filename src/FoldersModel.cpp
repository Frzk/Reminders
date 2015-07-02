#include "FoldersModel.h"



enum Roles {
    NameRole = Qt::UserRole + 1,        // Name of the folder/project
    NbRole,                             // Number of items contained in this folder
    CategoryRole,                       // Category (either "folder" or "project")
};



FoldersModel::FoldersModel(QObject *parent) : QSqlQueryModel(parent)
{
}

FoldersModel::~FoldersModel()
{
}

QHash<int, QByteArray> FoldersModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    roles[NameRole] = "name";
    roles[NbRole] = "nb";
    roles[CategoryRole] = "category";

    return roles;
}

QVariant FoldersModel::data(const QModelIndex &index, int role) const
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

void FoldersModel::refresh()
{
    this->setQuery("SELECT project, nb, category FROM folders ORDER BY project COLLATE localeCollation ASC");

    qDebug() << QString("FoldersModel refreshed !");
}
