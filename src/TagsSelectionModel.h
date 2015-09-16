#ifndef TAGSSELECTIONMODEL_H
#define TAGSSELECTIONMODEL_H

#include <QDebug>

#include <QSqlQuery>
#include <QSqlRecord>
#include <QSqlTableModel>

class TagsSelectionModel : public QSqlTableModel
{
    Q_OBJECT

    Q_PROPERTY(int count READ rowCount)

    public:
        explicit TagsSelectionModel(QObject *parent = 0);
        ~TagsSelectionModel();

        enum Roles {
            TagIdRole = Qt::UserRole + 1,       // id of the tag
            TagNameRole,                        // Name of the tag
            IsSelected,                         // Whether the tag is selected or not
        };

        // QSqlTableModel :
        QVariant                data(const QModelIndex &index, int role = Qt::DisplayRole) const;
        QHash<int, QByteArray>  roleNames() const;
        bool                    setData(const QModelIndex &index, const QVariant &value, int role);
};

#endif // TAGSSELECTIONMODEL_H
