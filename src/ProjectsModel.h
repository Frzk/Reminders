#ifndef PROJECTSMODEL_H
#define PROJECTSMODEL_H

#include <QDebug>
#include <QSqlQueryModel>


class ProjectsModel : public QSqlQueryModel
{
    Q_OBJECT

    public:
        explicit ProjectsModel(QObject *parent = 0);
        ~ProjectsModel();

        // QSqlQueryModel :
        QVariant                data(const QModelIndex &index, int role = Qt::DisplayRole) const;
        QHash<int, QByteArray>  roleNames() const;

        // QML API :
        Q_INVOKABLE void        refresh();
};

#endif // PROJECTSMODEL_H
