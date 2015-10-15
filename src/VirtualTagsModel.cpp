#include "VirtualTagsModel.h"

const QString VirtualTagsModel::QUERY =
        QString("SELECT "
            "vt_pending, "
            "vt_completed, "
            "vt_overdue, "
            "vt_due, "
            "vt_today, "
            "vt_yesterday, "
            "vt_tomorrow, "
            "vt_week, "
            "vt_month, "
            "vt_year, "
            "vt_until, "
            "vt_active, "
            "vt_scheduled, "
            "vt_tagged, "
            "vt_annotated, "
            "vt_waiting, "
            "vt_parent, "
            "vt_child, "
            "vt_blocked, "
            "vt_blocking, "
            "vt_ready "
            "FROM virtualtags WHERE uuid='%1'");


VirtualTagsModel::VirtualTagsModel(QObject *parent) : QStringListModel(parent)
{
    this->m_model = new QSqlQueryModel(parent);

    QObject::connect(this, &VirtualTagsModel::reminderUUIDChanged, this, &VirtualTagsModel::refresh);
}

VirtualTagsModel::~VirtualTagsModel()
{
    delete this->m_model;
}


QString VirtualTagsModel::reminderUUID() const
{
    return this->m_reminderUUID;
}

void VirtualTagsModel::setReminderUUID(const QString &uuid)
{
    if(uuid != this->m_reminderUUID)
    {
        this->m_reminderUUID = uuid;

        Q_EMIT reminderUUIDChanged();
    }
}


void VirtualTagsModel::refresh()
{
    QStringList list;

    this->m_model->setQuery(VirtualTagsModel::QUERY.arg(this->m_reminderUUID));

    if(this->m_model->lastError().isValid())
    {
        //FIXME: logfile.
        qDebug() << this->m_model->lastError();
    }
    else
    {
        QSqlRecord r = this->m_model->record(0);

        for(int i=0 ; i<r.count() ; i++)
        {
            if(r.value(i).toBool())
                list << r.fieldName(i);
        }
    }

    this->setStringList(list);
}
