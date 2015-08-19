#include "FilterProperty.h"

FilterProperty::FilterProperty(QObject *parent) : QObject(parent)
{
}

QString FilterProperty::property() const
{
    return this->m_property;
}

QString FilterProperty::value() const
{
    return this->m_value;
}

void FilterProperty::setProperty(const QString &property)
{
    if(property != this->m_property)
    {
        this->m_property = property;
        Q_EMIT propertyChanged();
    }
}

void FilterProperty::setValue(const QString &value)
{
    if(value != this->m_value)
    {
        this->m_value = value;
        Q_EMIT valueChanged();
    }
}
