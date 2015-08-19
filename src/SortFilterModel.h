#ifndef SORTFILTERMODEL_H
#define SORTFILTERMODEL_H

#include <QAbstractItemModel>
#include <QDebug>
#include <QSortFilterProxyModel>

#include "FilterProperty.h"
#include "SortProperty.h"

class SortFilterModel : public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(FilterProperty* filter READ filterProperty)
    Q_PROPERTY(SortProperty* sort READ sortProperty)
    Q_PROPERTY(QAbstractItemModel* model READ sourceModel WRITE setModel NOTIFY modelChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

    public:
        explicit SortFilterModel(QObject *parent = 0);

        Q_INVOKABLE QVariantMap get(int row) const;
        Q_INVOKABLE QVariant    data(int row, int role) const;
        Q_INVOKABLE int         count() const;

        QHash<int, QByteArray>  roleNames() const;
        bool                    filterAcceptsRow(int source_row, const QModelIndex &source_parent) const;

        void                    setModel(QAbstractItemModel* model);

    private:
        FilterProperty  m_filter;
        SortProperty    m_sort;

        FilterProperty* filterProperty();
        SortProperty*   sortProperty();

        void            filterChanged();
        void            sortChanged();

        int roleFromName(const QString &roleName) const;

    signals:
        void countChanged();
        void modelChanged();
};

#endif // SORTFILTERMODEL_H
