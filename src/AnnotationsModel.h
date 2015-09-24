#ifndef ANNOTATIONSMODEL_H
#define ANNOTATIONSMODEL_H

#include <QDebug>

#include <QSqlQuery>    //FIXME: remove (or let) this line when .cpp:90 is fixed.
#include <QSqlRecord>
#include <QSqlTableModel>

class AnnotationsModel : public QSqlTableModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(QString reminderUUID READ reminderUUID WRITE setReminderUUID NOTIFY reminderUUIDChanged)

    // insertRecord(int row, const QSqlRecord & record)
    // setData(const QModelIndex & index, const QVariant & value, int role=Qt::EditRole)
    // removeRows(int row, int count, const QModelIndex & parent=QModelIndex())

    public:
        explicit AnnotationsModel(QObject *parent = 0);
        ~AnnotationsModel();

        // Roles:
        enum Roles {
            AnnotationIdRole = Qt::UserRole + 1,
            AnnotationRole,
        };

        // QSqlTableModel :
        QVariant                data(const QModelIndex &index, int role = Qt::DisplayRole) const;
        QHash<int, QByteArray>  roleNames() const;

        // Properties :
        QString                 reminderUUID() const;
        void                    setReminderUUID(const QString &uuid);

        // QML API :
        Q_INVOKABLE bool        add(const QString & annotation);
        Q_INVOKABLE bool        remove(int row);
        Q_INVOKABLE bool        update(int row, const QString & annotation);

        //
        void                    refresh();

    signals:
        void                    reminderUUIDChanged() const;
        void                    countChanged(int) const;

    private:
        static const QString    FILTER;
        QString                 m_reminderUUID;

    private slots:
        void                    emitCountChanged() const;
};

#endif // ANNOTATIONSMODEL_H
