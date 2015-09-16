#ifndef TAGSSELECTIONMODEL_H
#define TAGSSELECTIONMODEL_H

#include <QDebug>

#include <QSqlQuery>
#include <QSqlRecord>
#include <QSqlTableModel>

class TagsSelectionModel : public QSqlTableModel
{
    Q_OBJECT

    //FIXME: should be notifiable:
    Q_PROPERTY(int count READ rowCount)

    public:
        explicit TagsSelectionModel(QObject *parent = 0);
        ~TagsSelectionModel();

        // Roles:
        enum Roles {
            TagIdRole = Qt::UserRole + 1,       // id of the tag, as set by the database
            TagNameRole,                        // Name of the tag
            IsSelected,                         // Whether the tag is selected or not
        };

        // QSqlTableModel :
        QVariant                data(const QModelIndex &index, int role = Qt::DisplayRole) const;
        QHash<int, QByteArray>  roleNames() const;
        bool                    setData(const QModelIndex &index, const QVariant &value, int role);

    private:
        static const QString    QUERY;
};

#endif // TAGSSELECTIONMODEL_H
