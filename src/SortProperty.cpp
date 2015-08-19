#include "SortProperty.h"

SortProperty::SortProperty(QObject *parent) : QObject(parent)
{
}

QString SortProperty::property() const
{
    return this->m_property;
}

Qt::SortOrder SortProperty::order() const
{
    return this->m_order;
}

void SortProperty::setProperty(const QString &property)
{
    this->m_property = property;
    Q_EMIT propertyChanged();
}

void SortProperty::setOrder(Qt::SortOrder order)
{
    this->m_order = order;
    Q_EMIT orderChanged();
}
