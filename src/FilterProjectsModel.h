#ifndef FILTERPROJECTSMODEL_H
#define FILTERPROJECTSMODEL_H

#include <QSortFilterProxyModel>

#include "ProjectsModel.h"

class FilterProjectsModel : public QSortFilterProxyModel
{
    Q_OBJECT


    public:
        explicit FilterProjectsModel(QObject *parent = 0);
        ~FilterProjectsModel();

        // QML API :
        Q_INVOKABLE QVariantMap get(int index) const;


    signals:


    public slots:


    private:
        ProjectsModel           *m_model;
};

#endif // FILTERPROJECTSMODEL_H
