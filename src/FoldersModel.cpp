#include "FoldersModel.h"

enum Roles {
    NameRole = Qt::UserRole + 1,        // Name of the folder/project
    NbRole,                             // Number of items contained in this folder
    CategoryRole,                       // Category (either "folder" or "project")
};

const QString FoldersModel::QUERY =
    "SELECT project, nb, category FROM folders ORDER BY project %1 ASC";


FoldersModel::FoldersModel(QObject *parent) : QSqlQueryModel(parent)
{
    this->m_storage = new Storage();
    //this->refresh();
}

FoldersModel::~FoldersModel()
{
    delete this->m_storage;
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
    //FIXME: seems weird:
    if(!this->m_storage->isOpen())
        this->m_storage->openDB();

    if(this->m_storage->isLocalized())
        this->setQuery(QUERY.arg("COLLATE localeCollation "), *this->m_storage);
    else
        this->setQuery(QUERY, *this->m_storage);

    qDebug() << QString("FoldersModel refreshed !");
}
