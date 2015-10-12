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

SortFilterModel::~SortFilterModel()
{
    if(this->sourceModel() != NULL)
        this->sourceModel()->disconnect(this);
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

    while(i != roles.constEnd())
    {
        r.insert(i.value(), this->data(row, i.key()));
        ++i;
    }

    return r;
}

QVariant SortFilterModel::data(int row, const QString &roleName) const
{
    int role = this->roleFromName(roleName);

    return this->data(row, role);
}

bool SortFilterModel::set(int row, const QString &roleName, const QVariant &value)
{
    int role = this->roleFromName(roleName);

    // Since QML only gives us a row, we set column to zero.
    // It's then up to the sourceModel to fix this column value in its `setData()` implementation.
    // This may be done depending on the given role.
    QModelIndex proxyIndex = this->index(row, 0);
    QModelIndex sourceIndex = this->mapToSource(proxyIndex);

    return this->sourceModel()->setData(sourceIndex, value, role);
}

bool SortFilterModel::append(const QVariantMap &values)
{
    int newRow = this->sourceModel()->rowCount();
    bool r = this->sourceModel()->insertRow(newRow);

    if(r)
    {
        QModelIndex sourceIndex = this->sourceModel()->index(newRow, 0);

        QMap<QString, QVariant>::const_iterator i = values.constBegin();
        while(i != values.constEnd())
        {
            int role = this->roleFromName(i.key());
            r = r && this->sourceModel()->setData(sourceIndex, i.value(), role);
            i++;
        }
    }

    return r;
}

bool SortFilterModel::remove(int row)
{
    return this->removeRow(row);
}

bool SortFilterModel::contains(const QString &roleName, const QVariant &value) const
{
    int role = this->roleFromName(roleName);

    QModelIndex start = this->index(0, 0);

    QModelIndexList searchResults = this->match(start, role, value, 1, Qt::MatchExactly);
    bool r = !searchResults.isEmpty();

    return r;
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


QVariant SortFilterModel::data(int row, int role) const
{
    QVariant r;

    if(this->sourceModel() != NULL)
        r = this->index(row, 0).data(role);

    return r;
}

int SortFilterModel::roleFromName(const QString &roleName) const
{
    const QHash<int, QByteArray> roles = this->roleNames();
    return roles.key(roleName.toLatin1(), 0);
}
