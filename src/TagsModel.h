#ifndef TAGSMODEL_H
#define TAGSMODEL_H

#include <QDebug>

#include <QSqlError>
#include <QSqlField>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QSqlTableModel>

#include <QSqlDatabase>
#include <QSqlDriver>

#include "Storage.h"


/*!
   The TagsModel class contains the tags for a specific reminder.

   The model is filled with data as soon as a reminderUUID is set.

   The data is gathered from two SQL tables : 'remindersXtags' and 'tags'.

   We could have used a QSqlRelationalTableModel but due to some limitations, we
   chose to inherit from QSqlTableModel and override the selectStatement() and
   orderByClause() methods.
 */
class TagsModel : public QSqlTableModel
{
    Q_OBJECT

    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(QString reminderUUID READ reminderUUID WRITE setReminderUUID NOTIFY reminderUUIDChanged)

    public:
        explicit    TagsModel(QObject *parent = 0);
        ~TagsModel();

        // Roles:
        enum Roles {
            ReminderUUIDRole = Qt::UserRole + 1,    // UUID of the reminder
            TagIdRole,                              // id of the tag, as set by the database engine
            TagNameRole,                            // Name of the tag
        };

        // QSqlTableModel:
        QHash<int, QByteArray>  roleNames() const;
        QVariant                data(const QModelIndex &index, \
                                     int role = Qt::DisplayRole) const;
        QString                 selectStatement() const;
        QString                 orderByClause() const;

        // Q_PROPERTIES:
        QString                 reminderUUID() const;
        void                    setReminderUUID(const QString &uuid);

        // QML API:
        Q_INVOKABLE bool        update(const QVariantList &values);

    private:
        static const QString    QUERY;
        static const QString    FILTER;
        static const QString    ORDER_BY;
        QString                 m_reminderUUID;
        bool                    m_supportPrepStatement;
        bool                    addValues(const QList<QVariantMap> &values);
        bool                    removeValues(const QStringList &tags);
        double                  createTag(const QString &tag) const;

    signals:
        void                    reminderUUIDChanged();
        void                    countChanged(int) const;

    private slots:
        void                    refresh();
        void                    emitCountChanged() const;


};

#endif // TAGSMODEL_H
