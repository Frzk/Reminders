#include "Storage.h"


// Database information

static const int currentSchemaVersion = 0;


// Database setup

static const QLatin1String setupEncoding("\n PRAGMA encoding = \"UTF-16\";");
static const QLatin1String setupTempStore("\n PRAGMA temp_store = MEMORY;");
static const QLatin1String setupJournal("\n PRAGMA journal_mode = WAL;");
static const QLatin1String setupSynchronous("\n PRAGMA synchronous = NORMAL;");
static const QLatin1String setupForeignKeys("\n PRAGMA foreign_keys = ON;");


// Database creation

static const QLatin1String createRemindersTable(
    "\n CREATE TABLE reminders ("
    "\n     uuid        TEXT PRIMARY KEY,"
    "\n     description TEXT NOT NULL,"
    "\n     priority    TEXT CHECK( priority IN ('', 'L','M','H') ) NOT NULL DEFAULT '',"
    "\n     status      TEXT CHECK( status IN ('p', 'c', 'd', 'r', 'w') ) NOT NULL DEFAULT 'p',"
    "\n     entry       TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')),"
    "\n     start       TEXT,"
    "\n     end         TEXT,"
    "\n     scheduled   TEXT,"
    "\n     due         TEXT,"
    "\n     until       TEXT,"
    "\n     wait        TEXT,"
    "\n     modified    TEXT,"
    "\n     recur       TEXT,"
    "\n     mask        TEXT,"
    "\n     imask       TEXT,"
    "\n     parent      TEXT,"
    "\n     project     TEXT NOT NULL DEFAULT ''"
    "\n );");

static const QLatin1String createAnnotationsTable(
    "\n CREATE TABLE annotations ("
    "\n     id              INTEGER PRIMARY KEY AUTOINCREMENT,"
    "\n     description     TEXT,"
    "\n     reminder_uuid   TEXT,"
    "\n     FOREIGN KEY (reminder_uuid) REFERENCES reminders(uuid) ON DELETE CASCADE"
    "\n );");

static const QLatin1String createDependenciesTable(
    "\n CREATE TABLE dependencies ("
    "\n     reminder_uuid   TEXT NOT NULL,"
    "\n     dependency_uuid TEXT NOT NULL,"
    "\n     PRIMARY KEY (reminder_uuid, dependency_uuid)"
    "\n     FOREIGN KEY (reminder_uuid) REFERENCES reminders(uuid) ON DELETE CASCADE"
    "\n     FOREIGN KEY (dependency_uuid) REFERENCES reminders(uuid) ON DELETE CASCADE"
    "\n );");

static const QLatin1String createTagsTable(
    "\n CREATE TABLE tags ("
    "\n     id  INTEGER PRIMARY KEY AUTOINCREMENT,"
    "\n     tag TEXT UNIQUE NOT NULL"
    "\n );");

static const QLatin1String createRemindersXTagsTable(
    "\n CREATE TABLE remindersXtags ("
    "\n     reminder_uuid   TEXT,"
    "\n     tag_id          INTEGER,"
    "\n     PRIMARY KEY (reminder_uuid, tag_id)"
    "\n     FOREIGN KEY (reminder_uuid) REFERENCES reminders(uuid) ON DELETE CASCADE"
    "\n     FOREIGN KEY (tag_id) REFERENCES tags(id)"
    "\n );");


static const QLatin1String createDeleteUnusedTagsTrigger(
    "\n CREATE TRIGGER delete_unused_tags"
    "\n AFTER DELETE ON remindersXtags"
    "\n FOR EACH ROW"
    "\n WHEN ((SELECT COUNT(tag_id) FROM remindersXtags WHERE tag_id = OLD.tag_id) = 0)"
    "\n BEGIN"
    "\n     DELETE FROM tags WHERE id = OLD.tag_id;"
    "\n END;");


static const QLatin1String createFoldersView(
    "\n CREATE VIEW folders AS"
    "\n     SELECT '01' AS project, COUNT(uuid) AS nb, 'folder' AS category"
    "\n     FROM reminders"
    "\n     WHERE status = 'p' AND date(due) = date('now')"
    "\n     UNION"
    "\n     SELECT '02' AS project, COUNT(uuid) AS nb, 'folder' AS category"
    "\n     FROM reminders"
    "\n     WHERE status = 'p' AND datetime(due) < datetime('now')"
    "\n     UNION"
    "\n     SELECT '03' AS project, COUNT(uuid) AS nb, 'folder' AS category"
    "\n     FROM reminders"
    "\n     WHERE date(due) BETWEEN date('now') AND date('now', '+7 days')"
    "\n     UNION"
    "\n     SELECT '04' AS project, COUNT(uuid) AS nb, 'folder' AS category"
    "\n     FROM reminders"
    "\n     WHERE status = 'p' AND due IS NULL"
    "\n     UNION"
    "\n     SELECT '05' AS project, COUNT(uuid) AS nb, 'folder' AS category"
    "\n     FROM reminders"
    "\n     WHERE status = 'c'"
    "\n     UNION"
    "\n     SELECT '06' AS project, COUNT(uuid) AS nb, 'folder' AS category"
    "\n     FROM reminders"
    "\n     WHERE status = 'd'"
    "\n     UNION"
    "\n     SELECT project, COUNT(NULLIF('c', status)) AS nb, 'project' AS category"
    "\n     FROM reminders"
    "\n     WHERE status = 'p' OR status = 'c'"
    "\n     GROUP BY project;");

static const QLatin1String createHaveNextTagView(
    "\n CREATE VIEW have_next_tag AS"
    "\n     SELECT reminder_uuid"
    "\n     FROM remindersXtags"
    "\n     JOIN tags ON remindersXtags.tag_id = tags.id"
    "\n     WHERE tags.tag = \"next\";");

static const QLatin1String createRemindersView(
    "\n CREATE VIEW reminders_view AS"
    "\n     SELECT"
    "\n         reminders.*,"
    "\n         status <> \"c\" AND status <> \"d\" AND due IS NOT NULL AS due_set,"
    "\n         ((strftime('%s', 'now') - strftime('%s', due)) / 86400.0) AS due_diff,"
    "\n         ((strftime('%s', 'now') - strftime('%s', entry)) / 86400.0) AS age,"
    "\n         COUNT(DISTINCT annotations.id) AS nb_annotations,"
    "\n         COUNT(DISTINCT remindersXtags.tag_id) AS nb_tags,"
    "\n         COUNT(dependencies.reminder_uuid) AS nb_sup"
    "\n     FROM reminders"
    "\n     LEFT JOIN annotations ON reminders.uuid = annotations.reminder_uuid"
    "\n     LEFT JOIN remindersXtags ON reminders.uuid = remindersXtags.reminder_uuid"
    "\n     LEFT JOIN dependencies ON reminders.uuid = dependencies.dependency_uuid"
    "\n     GROUP BY reminders.uuid;");

static const QLatin1String createNbSubtasksView(
    "\n CREATE VIEW nb_subtasks AS"
    "\n     WITH RECURSIVE blocking AS ("
    "\n         SELECT r_uuid, d_uuid FROM subtasks"
    "\n         UNION ALL"
    "\n         SELECT subtasks.r_uuid, blocking.d_uuid  FROM blocking"
    "\n         JOIN subtasks ON blocking.r_uuid = subtasks.d_uuid"
    "\n     ),"
    "\n     subtasks AS ("
    "\n         SELECT dependencies.reminder_uuid AS r_uuid,"
    "\n                dependencies.dependency_uuid AS d_uuid,"
    "\n                reminders.status AS d_status"
    "\n         FROM dependencies"
    "\n         JOIN reminders ON d_uuid = reminders.uuid"
    "\n         WHERE d_status = \"p\""
    "\n     )"
    "\n     SELECT r_uuid, COUNT(d_uuid) AS nb"
    "\n     FROM blocking"
    "\n     GROUP BY r_uuid;");

static const QLatin1String createVirtualTagsView(
    "\n CREATE VIEW virtualtags AS"
    "\n     SELECT uuid,"
    "\n         status = \"p\" AS vt_pending,"
    "\n         status = \"c\" AS vt_completed,"
    "\n         status = \"d\" AS vt_deleted,"
    "\n         due_set = 1 AND datetime(due) < datetime('now') AS vt_overdue,"
    "\n         due_set = 1 AND date(due) BETWEEN date('now') AND date('now', '+7 days') AS vt_due,"
    "\n         due_set = 1 AND date(due) = date('now') AS vt_today,"
    "\n         due_set = 1 AND date(due) = date('now', '-1 day') AS vt_yesterday,"
    "\n         due_set = 1 AND date(due) = date('now', '+1 day') AS vt_tomorrow,"
    "\n         due_set = 1 AND strftime('%W-%Y', due) = strftime('%W-%Y', 'now') AS vt_week,"
    "\n         due_set = 1 AND strftime('%m-%Y', due) = strftime('%m-%Y', 'now') AS vt_month,"
    "\n         due_set = 1 AND strftime('%Y', due) = strftime('%Y', 'now') AS vt_year,"
    "\n         until IS NOT NULL AS vt_until,"
    "\n         start IS NOT NULL AND end IS NULL AS vt_active,"
    "\n         scheduled IS NOT NULL AS vt_scheduled,"
    "\n         nb_tags > 0 AS vt_tagged,"
    "\n         nb_annotations > 0 AS vt_annotated,"
    "\n         wait IS NOT NULL AS vt_waiting,"
    "\n         mask IS NOT NULL AS vt_parent,"
    "\n         parent IS NOT NULL AS vt_child,"
    "\n         status = \"p\" AND IFNULL((nb_subtasks.nb > 0), 0) AS vt_blocked,"
    "\n         status = \"p\" AND nb_sup > 0 AS vt_blocking,"
    "\n         status = \"p\" AND IFNULL((nb_subtasks.nb = 0), 1) AND (scheduled IS NULL OR datetime(scheduled) < datetime('now')) AS vt_ready,"
    "\n         COUNT(have_next_tag.reminder_uuid) > 0 AS has_next"
    "\n     FROM reminders_view"
    "\n     LEFT JOIN nb_subtasks ON nb_subtasks.r_uuid = reminders_view.uuid"
    "\n     LEFT JOIN have_next_tag ON have_next_tag.reminder_uuid = reminders_view.uuid"
    "\n     GROUP BY reminders_view.uuid;");

static const QLatin1String createRView(
    "\n CREATE VIEW r AS"
    "\n     SELECT reminders_view.*,"
    "\n     virtualtags.*,"
    "\n     0.0"
    "\n     + (CASE"
    "\n         WHEN age > 365 THEN 1.0"
    "\n         ELSE 1.0 * age / 365"
    "\n         END) * 2.0"
    "\n     + (CASE"
    "\n         WHEN due_diff IS NULL THEN 0.0"
    "\n         WHEN due_diff >= 7.0 THEN 1.0"
    "\n         WHEN due_diff >= -14.0 THEN ((due_diff + 14.0) * 0.8 / 21.0) + 0.2"
    "\n         ELSE 0.2"
    "\n         END) * 12.0"
    "\n     + (CASE nb_annotations"
    "\n         WHEN 0 THEN 0"
    "\n         WHEN 1 THEN 0.8"
    "\n         WHEN 2 THEN 0.9"
    "\n         ELSE 1.0"
    "\n         END) * 1.0"
    "\n     + (CASE nb_tags"
    "\n         WHEN 0 THEN 0"
    "\n         WHEN 1 THEN 0.8"
    "\n         WHEN 2 THEN 0.9"
    "\n         ELSE 1.0"
    "\n         END) * 1.0"
    "\n     + (CASE priority"
    "\n         WHEN 'H' THEN 1.0"
    "\n         WHEN 'M' THEN 0.65"
    "\n         WHEN 'L' THEN 0.3"
    "\n         ELSE 0.0"
    "\n         END) * 6.0"
    "\n     + (CASE project"
    "\n         WHEN '' THEN 0.0"
    "\n         ELSE 1.0"
    "\n         END) * 1.0"
    "\n     + (CASE"
    "\n         WHEN scheduled <> '' AND scheduled < datetime('now') THEN 1.0"
    "\n         ELSE 0.0"
    "\n         END) * 5.0"
    "\n     + has_next * 15.0"
    "\n     + vt_blocking * 8.0"
    "\n     + vt_active * 4.0"
    "\n     + vt_blocked * -5.0"
    "\n     + vt_waiting * -3.0"
    "\n     AS urgency"
    "\n     FROM reminders_view"
    "\n     LEFT JOIN virtualtags"
    "\n     ON reminders_view.uuid = virtualtags.uuid;");


// Statements used to create the database with the current scheme.
static const std::vector<QLatin1String> createStatements =
    {
        createRemindersTable,
        createAnnotationsTable,
        createDependenciesTable,
        createTagsTable,
        createRemindersXTagsTable,
        createDeleteUnusedTagsTrigger,
        createFoldersView,
        createRemindersView,
        createHaveNextTagView,
        createNbSubtasksView,
        createVirtualTagsView,
        createRView,
    };


// Uncomment and complete that stuff whenever a new database scheme is needed :
/*
 * static const QString upgradeVersionFromXToX+1[] =
 *     {
 *          ...
 *          "PRAGMA user_version = X+1",
 *          0   // NULL-terminated
 *     };
 */

/*
 * struct upgradeOperation {
 *     UpgradeFunction fn;
 *     const char **statements;
 * };
 */

/*
 * static upgradeOperation upgradeVersions[] =
 *     {
 *         { 0,  upgradeVersionFromXToX+1 },
 *     };
 */

/*
 * static bool executeUpgradeStatements(QSqlDatabase &database)
 * {
 *
 * }
*/

/**
 * @brief Executes the given query.
 *
 * @param database
 * @param statement
 * @return bool
 */
static bool execute(QSqlDatabase &database, const QString &statement)
{
    bool r = false;
    QSqlQuery query(database);

    if(!query.exec(statement))
        qDebug() << QString("Query failed %1\n%2").arg(query.lastError().text()).arg(statement);
    else
        r = true;

    return r;
}

/**
 * @brief Tries to set the collation to the current locale. This is especially useful when ordering data.
 *
 * @param database
 * @param localeName
 * @return void
 */
static void configureCollation(QSqlDatabase &database, QString &localeName)
{
    const QString cLocaleName(QString::fromLatin1("C"));

    if(localeName != cLocaleName)
    {
        const QString statement(QString::fromLatin1("SELECT icu_load_collation('%1', 'localeCollation')"));

        if(!execute(database, statement.arg(localeName)))
        {
            qDebug() << QString("Failed to configure collation for locale %1 :\n%2")
                        .arg(localeName)
                        .arg(database.lastError().text());

            localeName = cLocaleName;
        }
    }
}

/**
 * @brief Configures some PRAGMAs on the database.
 *
 * @param database
 * @param localeName
 * @return bool
 */
static bool configureDatabase(QSqlDatabase &database, QString &localeName)
{
    bool r = false;

    if(!execute(database, setupEncoding)
       || !execute(database, setupTempStore)
       || !execute(database, setupJournal)
       || !execute(database, setupSynchronous)
       || !execute(database, setupForeignKeys))
    {
        qDebug() << "Failed to configure the database.";
    }
    else
    {
        r = true;
        configureCollation(database, localeName);
    }

    return r;
}

/**
 * @brief Creates the tables, triggers and views.
 *
 * @see createStatements vector to get a list of all SQL statements that will be executed.
 *
 * @param database
 * @return bool
 */
static bool createDatabase(QSqlDatabase &database)
{
    bool r = false;
    bool goOn = true;
    std::vector<QLatin1String>::const_iterator it;

    for(it = createStatements.begin() ; it != createStatements.end() && goOn ; ++it)
    {
        QSqlQuery query(database);

        if(!query.exec(*it))
            goOn = false;
    }

    if(goOn)
    {
        if(execute(database, QString("PRAGMA user_version = %1").arg(currentSchemaVersion)))
           r = true;
    }

    return r;
}

/**
 * @brief Configures and creates the database.
 *
 * @param database
 * @param localeName
 * @return bool
 */
static bool prepareDatabase(QSqlDatabase &database, QString &localeName)
{
    bool r = false;

    if(configureDatabase(database, localeName) && createDatabase(database))
        r = true;

    return r;
}



Storage::Storage() : m_localeName(QLocale().name())
{
}

Storage::~Storage()
{
    this->m_db.close();
}

Storage::operator QSqlDatabase &()
{
    return this->m_db;
}

Storage::operator QSqlDatabase const &() const
{
    return this->m_db;
}

/**
 * @brief Opens the database.
 *
 * @return bool
 */
bool Storage::openDB()
{
    bool r = true;

    // See where we have to store the database :
    QString path = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    QDir dir = QDir(path);

    // Try to create the directory if it doesn't exist :
    if(!dir.exists() && !dir.mkpath(path))
    {
        r = false;
        qDebug() << QString("Unable to create %1 (needed to store the database).").arg(path);
    }
    else
    {
        path.append(QDir::separator()).append("reminders.sqlite");

        // Does the database already exist ?
        bool db_exists = QFile::exists(path);

        this->m_db = QSqlDatabase::addDatabase("QSQLITE");
        this->m_db.setDatabaseName(QDir::toNativeSeparators(path));

        // From now on, we can assume that the database file exists.
        // If we can't open it, something went wrong during the creation of the database file.
        if(!this->m_db.open())
        {
            r = false;
            qDebug() << QString("Failed to open database :\n%1").arg(this->m_db.lastError().text());
        }
        else
        {
            // The database file can be opened... But did it already exist ?
            if(!db_exists)  // If it didn't exist, we have to prepare it (configure + create tables, views and triggers)
            {
                if(!prepareDatabase(this->m_db, this->m_localeName))
                {
                    r = false;
                    this->m_db.close();
                    qDebug() << QString("Failed to prepare the database :\n%1").arg(this->m_db.lastError().text());
                    qDebug() << QString("Removing %1.").arg(path);
                    QFile::remove(path);
                }
                else
                {
                    qDebug() << "Successfully initialized Reminders database.";
                }
            }
            else            // If it did already exist, we still have to configure it.
            {
                if(!configureDatabase(this->m_db, this->m_localeName))
                {
                    r = false;
                    this->m_db.close();
                    qDebug() << QString("Failed to configure the database :\n%1").arg(this->m_db.lastError().text());
                }
            }

            if(r)
            {
                //Everything seems OK (the database is opened and configured).
                //FIXME: Should we quick-check the database integrity here ?
                //FIXME: Should we check every needed table is here ? How ?
                //FIXME: We still have to check if the database scheme is up-to-date.
                qDebug() << "FIXME: write a function to check user_version.";
            }
        }
    }

    return r;
}

/**
 * @brief Checks if the database is opened.
 *
 * @return bool
 */
bool Storage::isOpen()
{
    return this->m_db.isOpen();
}

/**
 * @brief Storage::isLocalized
 * @return
 */
bool Storage::isLocalized()
{
    return (this->m_localeName != QLatin1String("C"));
}
