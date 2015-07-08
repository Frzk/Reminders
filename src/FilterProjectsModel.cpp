#include "FilterProjectsModel.h"

FilterProjectsModel::FilterProjectsModel(QObject *parent) : QSortFilterProxyModel(parent)
{
    this->m_model = new ProjectsModel(this);
    this->m_model->refresh();

    this->setSourceModel(this->m_model);
    this->setFilterCaseSensitivity(Qt::CaseInsensitive);
    this->setDynamicSortFilter(true);
}

FilterProjectsModel::~FilterProjectsModel()
{
    delete this->m_model;
}

QVariantMap FilterProjectsModel::get(int index) const
{
    QVariantMap r;
    QModelIndex idx = this->index(index, 0);

    r["project"] = this->data(idx, Qt::UserRole + 1).toString();

    return r;
}
