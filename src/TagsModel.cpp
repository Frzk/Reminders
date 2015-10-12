#include "TagsModel.h"


const QString TagsModel::QUERY =
        QString("SELECT r.reminder_uuid, r.tag_id, t.tag "
                "FROM remindersXtags r "
                "JOIN tags t ON r.tag_id = t.id");

const QString TagsModel::FILTER =
        QString("reminder_uuid='%1'");

const QString TagsModel::ORDER_BY =
        QString("ORDER BY tag ASC;");


TagsModel::TagsModel(QObject *parent) : QSqlTableModel(parent)
{
    QObject::connect(this, &TagsModel::rowsInserted,
                     this, &TagsModel::emitCountChanged);
    QObject::connect(this, &TagsModel::rowsRemoved,
                     this, &TagsModel::emitCountChanged);

    this->setTable("remindersXtags");
    this->setEditStrategy(QSqlTableModel::OnManualSubmit);

    this->m_supportPrepStatement = this->database().driver()->hasFeature(
                QSqlDriver::PreparedQueries);

    QObject::connect(this, &TagsModel::reminderUUIDChanged,
                     this, &TagsModel::refresh);
}

TagsModel::~TagsModel()
{
}

QHash<int, QByteArray> TagsModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    roles[ReminderUUIDRole] = "reminder_uuid";
    roles[TagIdRole] = "tag_id";
    roles[TagNameRole] = "tag";

    return roles;
}

QVariant TagsModel::data(const QModelIndex &index, int role) const
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

QString TagsModel::selectStatement() const
{
    QString stmt = TagsModel::QUERY;

    // Sets filter (WHERE clause) :
    if(!this->filter().isEmpty())
        stmt.append(QLatin1String(" "))
            .append(QLatin1String("WHERE "))
            .append(this->filter());

    // Sets sort (ORDER BY clause) :
    stmt.append(QLatin1String(" "))
        .append(this->orderByClause());

    return stmt;
}

QString TagsModel::orderByClause() const
{
    return TagsModel::ORDER_BY;
}


QString TagsModel::reminderUUID() const
{
    return this->m_reminderUUID;
}

void TagsModel::setReminderUUID(const QString &uuid)
{
    if(uuid != this->m_reminderUUID)
    {
        this->m_reminderUUID = uuid;
        Q_EMIT reminderUUIDChanged();
    }
}


bool TagsModel::update(const QVariantList &values)
{
    bool r = false;

    QStringList toBeRemoved;
    QList<QVariantMap> toBeAdded;

    // We first mark all tags in the model to be removed.
    for(int i=0 ; i<this->rowCount() ; i++)
    {
        const QString t = this->data(this->index(i, 0), TagNameRole).toString();
        toBeRemoved << t;
    }

    //
    // Then loop through the given values and see what has to be :
    //   - added (only present in values),
    //   - removed (only present in model),
    //   - or ignored (present in both model and values).

    for(int i=values.size()-1 ; i>=0 ; i--)
    {
        const QVariantMap current = values.at(i).toMap();
        const QString tag = current.value("tag").toString();

        if(!toBeRemoved.removeOne(tag))
            toBeAdded << current;
    }

    r = this->addValues(toBeAdded) && this->removeValues(toBeRemoved);

    //
    // Note that at this point, we may have created tags that may not be used.
    // We just keep going...

    if(r)
    {
        this->submitAll();
    }
    else
    {
        //FIXME: logfile.
        qDebug() << this->lastError();
        this->revertAll();
    }

    return r;
}


/*!
    Adds given tags to the model.

    The new values come from QML, and should have been filtered by
    TagsModel::update() before.

    Returns true if the model has been successfully updated or false on error.

    WARNING: this method DOES NOT update the database. Inserted items are
    cached. Use submitAll() to actually write the changes to the database.
 */
bool TagsModel::addValues(const QList<QVariantMap> &values)
{
    bool r = true;

    if(values.count() > 0)
    {
        for(int i=0 ; i<values.size() ; i++)
        {
            QVariantMap current = values.at(i);

            //
            // If the tag has an id of -1, it means that it has just been
            // created and doesn't exist in the DB yet.
            // We first have to INSERT it in the tags table, so that the
            // database assign an id to it.

            if(current.value("tag_id").toDouble() == -1)
            {
                current["tag_id"] = this->createTag(
                            current.value("tag").toString());
            }

            //
            // Now we can update our model.

            if(current.value("tag_id").toDouble() != -1)
            {
                QSqlRecord record = this->record();

                record.setValue("reminder_uuid", this->m_reminderUUID);
                record.setValue("tag_id", current.value("tag_id").toDouble());

                //
                // Explicitely ask not to care about the "tag" column :
                record.setGenerated("tag", false);

                r = r && this->insertRecord(-1, record);
            }
        }
    }

    return r;
}

/*!
    Removes given tags from the model.

    Returns true if all the tags have been removed or false on error.

    WARNING: this method DOES NOT update the database. Removed items are
    cached. Use submitAll() to actually write the changes to the database.
 */

bool TagsModel::removeValues(const QStringList &tags)
{
    bool r = true;

    for(int i=0 ; i<tags.count() ; i++)
    {
        QModelIndexList results = this->match(
                    this->index(0, 0),
                    TagNameRole,
                    tags.at(i),
                    1,
                    Qt::MatchExactly);

        r = r && this->removeRow(results.at(0).row());
    }

    return r;
}

/*!
    Creates a new tag.

    Insert a new tag in the tags table.

    Returns the new tag id (set by the database) on success or -1 on error.
 */
double TagsModel::createTag(const QString &tag) const
{
    double r = -1;

    QSqlRecord tagRecord;
    tagRecord.append(QSqlField("tag"));
    tagRecord.setValue("tag", tag);

    QString stmt = this->database().driver()->sqlStatement(
                QSqlDriver::InsertStatement,
                "tags",
                tagRecord,
                this->m_supportPrepStatement);

    const QSqlQuery tagQuery = Storage::exec(
                stmt,
                this->m_supportPrepStatement,
                tagRecord,
                QSqlRecord());  // No where clause to apply.

    if(!tagQuery.lastError().isValid())
        r = tagQuery.lastInsertId().toDouble();
    else
        //FIXME: logfile.
        qDebug() << tagQuery.lastError();

    return r;
}

/*!
    Refreshes the model.

    This slot is called when \a m_reminderUUID changes.
 */
void TagsModel::refresh()
{
    if(!this->m_reminderUUID.isEmpty())
        this->setFilter(TagsModel::FILTER.arg(this->m_reminderUUID));
    else
        this->setFilter("");

    if(!this->query().isActive())
        this->select();

    qDebug() << this->query().lastQuery();
}

void TagsModel::emitCountChanged() const
{
    Q_EMIT this->countChanged(this->rowCount());
}
