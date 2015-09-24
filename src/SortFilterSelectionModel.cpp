#include "SortFilterSelectionModel.h"


const QString SortFilterSelectionModel::SELECTED_ROLENAME = "isSelected";


SortFilterSelectionModel::SortFilterSelectionModel(QObject *parent) : SortFilterModel(parent)
{
    this->m_indexes = QList<QPersistentModelIndex>();

    QObject::connect(this, &SortFilterSelectionModel::modelReset, this, &SortFilterSelectionModel::clearSelection);
}

SortFilterSelectionModel::~SortFilterSelectionModel()
{
    this->clearSelection();
}


QVariant SortFilterSelectionModel::data(const QModelIndex &index, int role) const
{
    QVariant r;

    if(role == this->selectedRole())
    {
        QModelIndex sourceIndex = this->mapToSource(index);
        r = QVariant(this->m_indexes.contains(QPersistentModelIndex(sourceIndex)));
    }
    else
    {
        r = QSortFilterProxyModel::data(index, role);
    }

    return r;
}

QHash<int, QByteArray> SortFilterSelectionModel::roleNames() const
{
    QHash<int, QByteArray> roles = QHash<int, QByteArray>();

    if(this->sourceModel())
    {
        roles = this->sourceModel()->roleNames();
        int nextRole = Qt::UserRole + roles.size() + 1;
        roles[nextRole] = SortFilterSelectionModel::SELECTED_ROLENAME.toLatin1();
    }

    return roles;
}


int SortFilterSelectionModel::selectionCount() const
{
    return this->m_indexes.size();
}


QVariantList SortFilterSelectionModel::selection() const
{
    QVariantList r;
    const QHash<int, QByteArray> roles = this->roleNames();
    QHash<int, QByteArray>::const_iterator it;

    for(int i=0 ; i<this->m_indexes.size() ; i++)
    {
        QPersistentModelIndex idx = this->m_indexes.at(i);
        QVariantMap map;

        it = roles.constBegin();

        while(it != roles.constEnd())
        {
            map.insert(it.value(), idx.data(it.key()));
            ++it;
        }

        r.append(map);
    }

    return r;
}

void SortFilterSelectionModel::select(int row)
{
    QModelIndex proxyIndex = this->index(row, 0);
    QPersistentModelIndex persistentSourceIndex = QPersistentModelIndex(this->mapToSource(proxyIndex));

    this->select(persistentSourceIndex);
}

void SortFilterSelectionModel::deselect(int row)
{
    QModelIndex proxyIndex = this->index(row, 0);
    QPersistentModelIndex persistentSourceIndex = QPersistentModelIndex(this->mapToSource(proxyIndex));

    this->deselect(persistentSourceIndex);
}

bool SortFilterSelectionModel::append(const QVariantMap &values)
{
    bool selectNewItem = false;

    int newRow = this->sourceModel()->rowCount();
    bool r = this->sourceModel()->insertRow(newRow);

    if(r)
    {
        QModelIndex sourceIndex = this->sourceModel()->index(newRow, 0);

        QMap<QString, QVariant>::const_iterator i = values.constBegin();
        while(i != values.constEnd())
        {
            if(i.key() == SortFilterSelectionModel::SELECTED_ROLENAME && i.value().toBool())
            {
                selectNewItem = true;
            }
            else
            {
                int role = this->roleFromName(i.key());
                r = r && this->sourceModel()->setData(sourceIndex, i.value(), role);
            }

            i++;
        }

        if(selectNewItem)
        {
            QPersistentModelIndex persistentSourceIndex = QPersistentModelIndex(sourceIndex);
            this->select(persistentSourceIndex);
        }
    }

    return r;
}

bool SortFilterSelectionModel::remove(int row)
{
    QModelIndex proxyIndex = this->index(row, 0);
    QModelIndex sourceIndex =this->mapToSource(proxyIndex);

    this->deselect(QPersistentModelIndex(sourceIndex));

    return this->sourceModel()->removeRow(sourceIndex.row());
}


QList<QPersistentModelIndex> SortFilterSelectionModel::indexes() const
{
    return this->m_indexes;
}

void SortFilterSelectionModel::select(const QPersistentModelIndex &persistentSourceIndex)
{
    if(persistentSourceIndex.isValid())
    {
        if(!this->m_indexes.contains(persistentSourceIndex)) // Proceed only if not already in selection.
        {
            this->m_indexes.append(persistentSourceIndex);

            QModelIndex proxyIndex = this->mapFromSource(persistentSourceIndex);

            Q_EMIT this->selectionCountChanged(this->selectionCount());
            Q_EMIT this->dataChanged(proxyIndex, proxyIndex, QVector<int>(1, this->selectedRole()));
        }
    }
}

void SortFilterSelectionModel::deselect(const QPersistentModelIndex &persistentSourceIndex)
{
    if(persistentSourceIndex.isValid())
    {
        bool removed = this->m_indexes.removeOne(persistentSourceIndex);

        if(removed)
        {
            QModelIndex proxyIndex = this->mapFromSource(persistentSourceIndex);

            Q_EMIT this->selectionCountChanged(this->selectionCount());
            Q_EMIT this->dataChanged(proxyIndex, proxyIndex, QVector<int>(1, this->selectedRole()));
        }
    }
}

bool SortFilterSelectionModel::toggleSelected(const QPersistentModelIndex &idx)
{
    bool r = false;

    if(idx.isValid())
    {
        if(this->m_indexes.contains(idx))
        {
            r = this->m_indexes.removeOne(idx);
        }
        else
        {
            this->m_indexes.append(idx);
            r = true;
        }

        if(r)
        {
            QModelIndex proxyIndex = this->mapFromSource(idx);

            Q_EMIT this->selectionCountChanged(this->selectionCount());
            Q_EMIT this->dataChanged(proxyIndex, proxyIndex, QVector<int>(1, this->selectedRole()));
        }
    }

    return r;
}


void SortFilterSelectionModel::clearSelection()
{
    this->m_indexes.clear();
    //FIXME: we certainly should also emit dataChanged here.
    Q_EMIT this->selectionCountChanged(this->selectionCount());
}


int SortFilterSelectionModel::roleFromName(const QString &roleName) const
{
    const QHash<int, QByteArray> roles = this->roleNames();
    return roles.key(roleName.toLatin1(), 0);
}

int SortFilterSelectionModel::selectedRole() const
{
    return this->roleFromName(SortFilterSelectionModel::SELECTED_ROLENAME);
}
