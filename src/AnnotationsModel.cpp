#include "AnnotationsModel.h"


const QString AnnotationsModel::FILTER = QString("reminder_uuid='%1'");


AnnotationsModel::AnnotationsModel(QObject * parent) : QSqlTableModel(parent)
{
    QObject::connect(this, &AnnotationsModel::rowsInserted, this, &AnnotationsModel::emitCountChanged);
    QObject::connect(this, &AnnotationsModel::rowsRemoved, this, &AnnotationsModel::emitCountChanged);

    this->setTable("annotations");
    this->setSort(1, Qt::AscendingOrder);
    this->setEditStrategy(QSqlTableModel::OnManualSubmit);

    QObject::connect(this, &AnnotationsModel::reminderUUIDChanged, this, &AnnotationsModel::refresh);
}

AnnotationsModel::~AnnotationsModel()
{
}

QHash<int, QByteArray> AnnotationsModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    roles[AnnotationIdRole] = "annotation_id";
    roles[AnnotationRole] = "annotation";

    return roles;
}

QVariant AnnotationsModel::data(const QModelIndex &index, int role) const
{
    QVariant r = QSqlTableModel::data(index, role);

    if(role >= Qt::UserRole)
    {
        int columnIndex = role - Qt::UserRole - 1;
        QModelIndex idx = this->index(index.row(), columnIndex);

        r = QSqlTableModel::data(idx, Qt::DisplayRole);
    }

    return r;
}


QString AnnotationsModel::reminderUUID() const
{
    return this->m_reminderUUID;
}

void AnnotationsModel::setReminderUUID(const QString & uuid)
{
    if(uuid != this->m_reminderUUID)
    {
        this->m_reminderUUID = uuid;
        Q_EMIT reminderUUIDChanged();
    }
}


bool AnnotationsModel::add(const QString & annotation)
{
    QSqlRecord record = this->record();
    record.setValue("annotation", annotation);

    return this->insertRecord(-1, record);
}

bool AnnotationsModel::remove(int row)
{
    return this->removeRows(row, 1);
}

bool AnnotationsModel::update(int row, const QString & annotation)
{
    QModelIndex index = this->index(row, 0);

    return this->setData(index, annotation, AnnotationsModel::AnnotationRole);
}


void AnnotationsModel::refresh()
{
    this->setFilter(AnnotationsModel::FILTER.arg(this->m_reminderUUID));

    /*
     * We have to test if the query is active or not to avoid populating the model twice.
     * (it may have already been populated by setFilter().)
     *
     * See http://doc.qt.io/qt-5/qsqltablemodel.html#setFilter for further details.
     */
    if(!this->query().isActive())
        this->select();
}


void AnnotationsModel::emitCountChanged() const
{
    Q_EMIT this->countChanged(this->rowCount());
}
