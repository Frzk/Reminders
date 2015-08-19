#include "SortFilterModel.h"

SortFilterModel::SortFilterModel(QObject *parent) : QSortFilterProxyModel(parent)
{
    this->setDynamicSortFilter(true);
    this->setFilterCaseSensitivity(Qt::CaseInsensitive);
    this->setSortCaseSensitivity(Qt::CaseInsensitive);

    QObject::connect(this, &SortFilterModel::modelReset, this, &SortFilterModel::countChanged);
    QObject::connect(this, &SortFilterModel::rowsInserted, this, &SortFilterModel::countChanged);
    QObject::connect(this, &SortFilterModel::rowsRemoved, this, &SortFilterModel::countChanged);

    QObject::connect(&(this->m_filter), &FilterProperty::propertyChanged, this, &SortFilterModel::filterChanged);
    QObject::connect(&(this->m_filter), &FilterProperty::valueChanged, this, &SortFilterModel::filterChanged);
    QObject::connect(&(this->m_sort), &SortProperty::propertyChanged, this, &SortFilterModel::sortChanged);
    QObject::connect(&(this->m_sort), &SortProperty::orderChanged, this, &SortFilterModel::sortChanged);
}



SortProperty* SortFilterModel::sortProperty()
{
    return &(this->m_sort);
}

FilterProperty* SortFilterModel::filterProperty()
{
    return &(this->m_filter);
}


void SortFilterModel::setModel(QAbstractItemModel *model)
{
    if(model != NULL)
    {
        if(model != this->sourceModel())
        {
            if(this->sourceModel() != NULL)
                this->sourceModel()->disconnect(this);

            this->setSourceModel(model);
            this->setFilterRole(this->roleFromName(this->m_filter.property()));
            this->setSortRole(this->roleFromName(this->m_sort.property()));

            Q_EMIT modelChanged();
        }
    }
}



QHash<int, QByteArray> SortFilterModel::roleNames() const
{
    return this->sourceModel() ? this->sourceModel()->roleNames() : QHash<int, QByteArray>();
}

bool SortFilterModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    bool r = false;

    if(this->filterRegExp().isEmpty())  // No filter.
        r = true;
    else
        r = QSortFilterProxyModel::filterAcceptsRow(source_row, source_parent);

    return r;
}



QVariantMap SortFilterModel::get(int row) const
{
    QVariantMap r;

    const QHash<int, QByteArray> roles = this->roleNames();
    QHash<int, QByteArray>::const_iterator i = roles.constBegin();

    qDebug() << QString("Calling get.");

    while(i != roles.constEnd())
    {
        qDebug() << this->data(row, i.key());
        r.insert(i.value(), this->data(row, i.key()));
        ++i;
    }

    return r;
}

QVariant SortFilterModel::data(int row, int role) const
{
    QVariant r;

    if(this->sourceModel() != NULL)
        r = this->index(row, 0).data(role);

    return r;
}

int SortFilterModel::count() const
{
    return this->rowCount();
}



int SortFilterModel::roleFromName(const QString &roleName) const
{
    const QHash<int, QByteArray> roles = this->roleNames();
    return roles.key(roleName.toLatin1(), 0);
}



void SortFilterModel::filterChanged()
{
    this->setFilterRole(this->roleFromName(this->m_filter.property()));
    this->setFilterFixedString(this->m_filter.value());
}

void SortFilterModel::sortChanged()
{
    this->setSortRole(this->roleFromName(this->m_sort.property()));
    this->sort(this->sortColumn() != -1 ? this->sortColumn() : 0, this->m_sort.order());
}
