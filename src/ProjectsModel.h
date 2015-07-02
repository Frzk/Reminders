#ifndef PROJECTSMODEL_H
#define PROJECTSMODEL_H

#include <QDebug>
#include <QSqlQueryModel>


class ProjectsModel : public QSqlQueryModel
{
    Q_OBJECT

    //Q_PROPERTY(QString selectedProject READ getSelectedProject WRITE setSelectedProject NOTIFY selectedProjectChanged)

    public:
        explicit ProjectsModel(QObject *parent = 0);
        ~ProjectsModel();

        // QSqlQueryModel :
        QVariant                data(const QModelIndex &index, int role = Qt::DisplayRole) const;
        QHash<int, QByteArray>  roleNames() const;

        // Properties :
        //QString                 getSelectedProject() const;
        //bool                    setSelectedProject(const QString &s);

        // QML API :
        Q_INVOKABLE void        refresh();

    signals:
        //void                    selectedProjectChanged();

    public slots:

    private:
        //QString                 m_selectedProject;

};

#endif // PROJECTSMODEL_H
