#ifndef SORTFILTERSELECTIONMODEL_H
#define SORTFILTERSELECTIONMODEL_H

#include <QObject>

#include <QDebug>

#include <QAbstractItemModel>
#include <QAbstractListModel>
#include <QModelIndex>
#include <QPersistentModelIndex>
#include <QVariantList>
#include <QVariantMap>

#include "SortFilterModel.h"

class SortFilterSelectionModel : public SortFilterModel
{
    Q_OBJECT

    Q_PROPERTY(int selectionCount READ selectionCount NOTIFY selectionCountChanged)

    public:
        explicit SortFilterSelectionModel(QObject *parent = 0);
        ~SortFilterSelectionModel();

        // QAbstractListModel:
        QVariant                                data(const QModelIndex & index, int role = Qt::DisplayRole) const;
        QHash<int, QByteArray>                  roleNames() const;

        // Q_PROPERTIES:
        int                                     selectionCount() const;

        // QML API:
        Q_INVOKABLE QVariantList                selection() const;
        Q_INVOKABLE void                        select(int row);
        Q_INVOKABLE void                        deselect(int row);
        Q_INVOKABLE bool                        append(const QVariantMap &values);
        Q_INVOKABLE bool                        remove(int row);

        // Other public methods:
        QList<QPersistentModelIndex>            indexes() const;
        void                                    select(const QPersistentModelIndex &persistentSourceIndex);
        void                                    deselect(const QPersistentModelIndex &persistentSourceIndex);
        bool                                    toggleSelected(const QPersistentModelIndex &persistentSourceIndex);

    signals:
        void                                    selectionCountChanged(int) const;

    public slots:
        void                                    clearSelection();

    private:
        static const QString                    SELECTED_ROLENAME;
        QList<QPersistentModelIndex>            m_indexes;
        int                                     roleFromName(const QString &roleName) const;
        int                                     selectedRole() const;
};

#endif // SORTFILTERSELECTIONMODEL_H
