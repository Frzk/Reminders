#ifndef REMINDERSSTORAGE_H
#define REMINDERSSTORAGE_H

#include <QObject>
#include <QDebug>

#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlQueryModel>
#include <QSqlTableModel>

#include <QDir>
#include <QFile>
#include <QLatin1String>
#include <QStandardPaths>
#include <QString>
#include <QVariant>

class Storage
{
    public:
        explicit Storage();
        ~Storage();

        bool openDB();
        bool isOpen();

        operator QSqlDatabase &();
        operator QSqlDatabase const &() const;

    private:
        QSqlDatabase    m_db;
};

#endif // REMINDERSSTORAGE_H
