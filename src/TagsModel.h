#ifndef TAGSMODEL_H
#define TAGSMODEL_H

#include <QDebug>

#include <QSqlQuery>
#include <QSqlRelationalTableModel>

class TagsModel : public QSqlRelationalTableModel
{
    Q_OBJECT

    Q_PROPERTY(int count READ rowCount)
    Q_PROPERTY(QString reminderUUID READ reminderUUID WRITE setReminderUUID NOTIFY reminderUUIDChanged)

    public:
        explicit    TagsModel(QObject *parent = 0);
        ~TagsModel();

        // QSqlRelationalTableModel :
        QHash<int, QByteArray>  roleNames() const;
        QVariant                data(const QModelIndex &index, int role = Qt::DisplayRole) const;

        // Q_PROPORTIES :
        QString                 reminderUUID() const;
        void                    setReminderUUID(const QString &uuid);

    private:
        static const QString    FILTER;
        QString                 m_reminderUUID;

    signals:
        void                    reminderUUIDChanged();

    private slots:
        void                    refresh();
};

#endif // TAGSMODEL_H
