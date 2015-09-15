#include "TagsSelectionModel.h"


enum Roles {
    TagIdRole = Qt::UserRole + 1,       // id of the tag
    TagNameRole,                        // Name of the tag
    IsSelected,                         // Whether the tag is selected or not
};


TagsSelectionModel::TagsSelectionModel(QObject *parent) : QSqlTableModel(parent)
{
    this->setEditStrategy(EditStrategy::OnManualSubmit);
    this->setTable("tags");
    this->setSort(1, Qt::AscendingOrder);
    this->select();
}

TagsSelectionModel::~TagsSelectionModel()
{
}


QVariant TagsSelectionModel::data(const QModelIndex &index, int role) const
{
    QVariant r = QSqlTableModel::data(index, role);

    if(role >= Qt::UserRole)
    {
        int columnIndex = role - Qt::UserRole - 1;
        QModelIndex idx = this->index(index.row(), columnIndex);

        r = QSqlTableModel::data(idx, Qt::DisplayRole);
    }

    return r;
}

QHash<int, QByteArray> FoldersModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    roles[TagIdRole] = "tag_id";
    roles[TagNameRole] = "tag";
    roles[IsSelected] = "isSelected";

    return roles;
}
