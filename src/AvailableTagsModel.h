#ifndef AVAILABLETAGSMODEL_H
#define AVAILABLETAGSMODEL_H

#include <QDebug>

#include <QSqlError>
#include <QSqlTableModel>

class AvailableTagsModel : public QSqlTableModel
{
    Q_OBJECT

    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

    public:
        explicit AvailableTagsModel(QObject *parent = 0);
        ~AvailableTagsModel();

        // Roles:
        enum Roles {
            TagIdRole = Qt::UserRole + 1,       // id of the tag, as set by the database
            TagNameRole,                        // Name of the tag
        };

        // QSqlTableModel:
        QVariant                data(const QModelIndex &index, int role = Qt::DisplayRole) const;
        QHash<int, QByteArray>  roleNames() const;
        bool                    setData(const QModelIndex &index, const QVariant &value, int role);

    signals:
        void                    countChanged(int) const;

    private slots:
        void                    emitCountChanged() const;
};

#endif // AVAILABLETAGSMODEL_H
