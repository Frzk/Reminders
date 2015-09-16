#include "TagsSelectionModel.h"


TagsSelectionModel::TagsSelectionModel(QObject *parent) : QSqlTableModel(parent)
{
    this->setEditStrategy(EditStrategy::OnManualSubmit);
    //this->setTable("tags");
    //this->setSort(1, Qt::AscendingOrder);
    this->setQuery(QSqlQuery("SELECT id, tag, 0 AS isSelected FROM tags ORDER BY tag ASC;"));
    this->select();
}

TagsSelectionModel::~TagsSelectionModel()
{
}


QVariant TagsSelectionModel::data(const QModelIndex &index, int role) const
{
    QVariant r;

    if(role >= Qt::UserRole)
    {
        int columnIndex = role - Qt::UserRole - 1;
        QModelIndex idx = this->index(index.row(), columnIndex);

        r = QSqlTableModel::data(idx, Qt::DisplayRole);
    }
    else
    {
        r = QSqlTableModel::data(index, role);
    }

    return r;
}

bool TagsSelectionModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    bool r;

    if(role >= Qt::UserRole)
    {
        int columnIndex = role - Qt::UserRole - 1;
        QModelIndex idx = this->index(index.row(), columnIndex);

        r = QSqlTableModel::setData(idx, value, Qt::EditRole);
    }
    else
    {
        r = QSqlTableModel::setData(index, value, role);
    }

    return r;
}

QHash<int, QByteArray> TagsSelectionModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    roles[TagIdRole] = "tag_id";
    roles[TagNameRole] = "tag";
    roles[IsSelected] = "isSelected";

    return roles;
}


bool TagsSelectionModel::append(const QVariantMap &values)
{
    qDebug() << "Adding" << values << "to the model.";

    QSqlRecord record = this->record();
    //record.setValue(0, -1);
    record.setValue(1, values.value("tag").toString());
    record.setValue(2, values.value("isSelected").toBool());

    return this->insertRecord(-1, record);
}
