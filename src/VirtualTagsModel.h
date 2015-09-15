#ifndef VIRTUALTAGSMODEL_H
#define VIRTUALTAGSMODEL_H

#include <QSqlError>
#include <QSqlQueryModel>
#include <QSqlRecord>
#include <QStringListModel>


class VirtualTagsModel : public QStringListModel
{
    Q_OBJECT

    Q_PROPERTY(QString reminderUUID READ reminderUUID WRITE setReminderUUID NOTIFY reminderUUIDChanged)

    public:
        explicit VirtualTagsModel(QObject *parent = 0);
        ~VirtualTagsModel();

        // Q_PROPERTIES :
        QString                 reminderUUID() const;
        void                    setReminderUUID(const QString &uuid);

    private:
        static const QString    QUERY;
        QString                 m_reminderUUID;
        QSqlQueryModel          * m_model;

    signals:
        void                    reminderUUIDChanged();

    private slots:
        void                    refresh();
};

#endif // VIRTUALTAGSMODEL_H
