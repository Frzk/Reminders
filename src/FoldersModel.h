#ifndef FOLDERSMODEL_H
#define FOLDERSMODEL_H

#include <QSqlQueryModel>

#include "./Storage.h"

class FoldersModel : public QSqlQueryModel
{
    Q_OBJECT

    public:
        explicit FoldersModel(QObject *parent = 0);
        ~FoldersModel();

        // QSqlQueryModel :
        QVariant                data(const QModelIndex &index, int role = Qt::DisplayRole) const;
        QHash<int, QByteArray>  roleNames() const;

        // QML API :
        Q_INVOKABLE void        refresh();

    signals:

    public slots:

    private:
        const static QString    QUERY;
        Storage*                m_storage;
};

#endif // FOLDERSMODEL_H
