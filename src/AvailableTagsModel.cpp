#include "AvailableTagsModel.h"


AvailableTagsModel::AvailableTagsModel(QObject *parent) : QSqlTableModel(parent)
{
    QObject::connect(this, &AvailableTagsModel::rowsInserted, this, &AvailableTagsModel::emitCountChanged);
    QObject::connect(this, &AvailableTagsModel::rowsRemoved, this, &AvailableTagsModel::emitCountChanged);

    this->setTable("tags");
    this->setSort(1, Qt::AscendingOrder);
    this->setEditStrategy(EditStrategy::OnManualSubmit);
    this->select();
}

AvailableTagsModel::~AvailableTagsModel()
{
}


QVariant AvailableTagsModel::data(const QModelIndex &index, int role) const
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

bool AvailableTagsModel::setData(const QModelIndex &index, const QVariant &value, int role)
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

QHash<int, QByteArray> AvailableTagsModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    roles[TagIdRole] = "tag_id";
    roles[TagNameRole] = "tag";

    return roles;
}


void AvailableTagsModel::emitCountChanged() const
{
    Q_EMIT this->countChanged(this->rowCount());
}
