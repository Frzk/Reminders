#include "TagsModel.h"


const QString TagsModel::FILTER = QString("reminder_uuid='%1'");


TagsModel::TagsModel(QObject *parent) : QSqlRelationalTableModel(parent)
{
    this->setTable("remindersXtags");
    this->setRelation(1, QSqlRelation("tags", "id", "tag"));
    this->setSort(1, Qt::AscendingOrder);
    this->setEditStrategy(QSqlTableModel::OnManualSubmit);

    QObject::connect(this, &TagsModel::reminderUUIDChanged, this, &TagsModel::refresh);
}

TagsModel::~TagsModel()
{
}

QHash<int, QByteArray> TagsModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    roles[TagIdRole] = "tag_id";
    roles[TagNameRole] = "tag";

    return roles;
}

QVariant TagsModel::data(const QModelIndex &index, int role) const
{
    QVariant r = QSqlRelationalTableModel::data(index, role);

    if(role >= Qt::UserRole)
    {
        int columnIndex = role - Qt::UserRole - 1;
        QModelIndex idx = this->index(index.row(), columnIndex);

        r = QSqlRelationalTableModel::data(idx, Qt::DisplayRole);
    }

    return r;
}


QString TagsModel::reminderUUID() const
{
    return this->m_reminderUUID;
}

void TagsModel::setReminderUUID(const QString &uuid)
{
    if(uuid != this->m_reminderUUID)
    {
        this->m_reminderUUID = uuid;
        Q_EMIT reminderUUIDChanged();
    }
}


void TagsModel::refresh()
{
    if(!this->m_reminderUUID.isEmpty())
        this->setFilter(TagsModel::FILTER.arg(this->m_reminderUUID));
    else
        this->setFilter("");    // Remove filter.

    /*
     * We have to test if the query is active or not to avoid populating the model twice.
     * (it may have already been populated by setFilter().)
     *
     * See http://doc.qt.io/qt-5/qsqltablemodel.html#setFilter for further details.
     */
    if(!this->query().isActive())
        this->select();
}
