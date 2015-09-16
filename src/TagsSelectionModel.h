#ifndef TAGSSELECTIONMODEL_H
#define TAGSSELECTIONMODEL_H

#include <QDebug>

#include <QSqlQuery>
#include <QSqlRecord>
#include <QSqlTableModel>

class TagsSelectionModel : public QSqlTableModel
{
    Q_OBJECT

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

        // QML API :
        Q_INVOKABLE bool        append(const QVariantMap &values);
        //Q_INVOKABLE void        setSelected(const TagsModel & selection);
        //Q_INVOKABLE void        createMissingTags();
};

#endif // TAGSSELECTIONMODEL_H
