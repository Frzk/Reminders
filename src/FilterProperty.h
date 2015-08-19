#ifndef FILTERPROPERTY_H
#define FILTERPROPERTY_H

#include <QObject>
#include <QRegExp>

class FilterProperty : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString property READ property WRITE setProperty NOTIFY propertyChanged)
    Q_PROPERTY(QString value READ value WRITE setValue NOTIFY valueChanged)

    public:
        explicit FilterProperty(QObject *parent = 0);

        QString     property() const;
        QString     value() const;
        void        setProperty(const QString &property);
        void        setValue(const QString &value);

    private:
        QString     m_property;
        QString     m_value;

    signals:
        void        propertyChanged();
        void        valueChanged();
};

#endif // FILTERPROPERTY_H
