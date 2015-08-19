#ifndef SORTPROPERTY_H
#define SORTPROPERTY_H

#include <QObject>

class SortProperty : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString property READ property WRITE setProperty NOTIFY propertyChanged)
    Q_PROPERTY(Qt::SortOrder order READ order WRITE setOrder NOTIFY orderChanged)

    public:
        explicit SortProperty(QObject *parent = 0);

        QString         property()  const;
        Qt::SortOrder   order()     const;
        void            setProperty(const QString &property);
        void            setOrder(Qt::SortOrder order);

    private:
        QString         m_property;
        Qt::SortOrder   m_order;

    signals:
        void            propertyChanged();
        void            orderChanged();
};

#endif // SORTPROPERTY_H
