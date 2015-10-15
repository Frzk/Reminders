-- Jolla : sqlite v.3.8.5
-- ISO 8601 : 1977-04-22T06:00:00Z = strftime('%Y-%m-%dT%H:%M:%SZ', 'now')

--SQLITE:
.mode columns
.headers ON
.timer ON

PRAGMA foreign_keys = ON;   -- NEEDED to get ON DELETE CASCADE working.
--

-- TABLES

CREATE TABLE reminders (
    uuid        TEXT PRIMARY KEY,
    description TEXT NOT NULL,
    priority    TEXT CHECK( priority IN ('', 'L','M','H') ) NOT NULL DEFAULT '',
    status      TEXT CHECK( status IN ('p', 'c', 'd', 'r', 'w') ) NOT NULL DEFAULT 'p',
    entry       TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')),
    start       TEXT,
    end         TEXT,
    scheduled   TEXT,
    due         TEXT,
    until       TEXT,
    wait        TEXT,
    modified    TEXT,
    recur       TEXT,
    mask        TEXT,
    imask       TEXT,
    parent      TEXT,
    project     TEXT NOT NULL DEFAULT ''
);


CREATE TABLE annotations (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    description     TEXT,
    reminder_uuid   TEXT,
    FOREIGN KEY (reminder_uuid) REFERENCES reminders(uuid) ON DELETE CASCADE
);


CREATE TABLE dependencies (
    reminder_uuid   TEXT NOT NULL,
    dependency_uuid TEXT NOT NULL,
    PRIMARY KEY (reminder_uuid, dependency_uuid)
    FOREIGN KEY (reminder_uuid) REFERENCES reminders(uuid) ON DELETE CASCADE
    FOREIGN KEY (dependency_uuid) REFERENCES reminders(uuid) ON DELETE CASCADE
);


CREATE TABLE tags (
    id  INTEGER PRIMARY KEY AUTOINCREMENT,
    tag TEXT UNIQUE NOT NULL
);

CREATE TABLE remindersXtags (
    reminder_uuid   TEXT,
    tag_id          INTEGER,
    PRIMARY KEY (reminder_uuid, tag_id)
    FOREIGN KEY (reminder_uuid) REFERENCES reminders(uuid) ON DELETE CASCADE
    FOREIGN KEY (tag_id) REFERENCES tags(id)
);


-- TRIGGERS

--FIXME: TRIGGERS don't work on SELECT. Find something else.
--
-- before selecting in reminders, update <wait> if needed.
--CREATE TRIGGER update_wait
--    BEFORE SELECT ON reminders
--    FOR EACH ROW
--    WHEN datetime(wait) >= datetime('now')
--    BEGIN
--        UPDATE reminders SET wait = NULL WHERE id = OLD.id;
--    END;

-- when updating a reminder, also set <modified> to now.
CREATE TRIGGER update_modified
    AFTER UPDATE ON reminders
    FOR EACH ROW
    BEGIN
        UPDATE reminders SET modified = strftime("%Y-%m-%dT%H:%M:%SZ", 'now') WHERE uuid = OLD.uuid;
    END;

-- when updating the <status> of a reminder to 'd' or 'c', also set <end> to now.
CREATE TRIGGER update_end
    AFTER UPDATE OF status ON reminders
    FOR EACH ROW
    WHEN NEW.status = 'd' OR NEW.status = 'c'
    BEGIN
        UPDATE reminders SET end = strftime("%Y-%m-%dT%H:%M:%SZ", 'now') WHERE uuid = OLD.uuid;
    END;

-- when updating the <status> of a reminder to 'p', also set <end> to NULL.
CREATE TRIGGER delete_end
    AFTER UPDATE OF status ON reminders
    FOR EACH ROW
    WHEN NEW.status = 'p' AND (OLD.status = 'd' OR OLD.status = 'c')
    BEGIN
        UPDATE reminders SET end = NULL WHERE uuid = OLD.uuid;
    END;

-- when setting <wait>, also set <status> to 'w'.
CREATE TRIGGER update_status_waiting_on
    AFTER UPDATE OF wait ON reminders
    FOR EACH ROW
    WHEN NEW.wait IS NOT NULL
    BEGIN
        UPDATE reminders SET status = 'w' WHERE uuid = OLD.uuid;
    END;

-- when setting <wait> to NULL, also set <status> to 'p'.
CREATE TRIGGER update_status_waiting_off
    AFTER UPDATE OF wait ON reminders
    FOR EACH ROW
    WHEN NEW.wait IS NULL
    BEGIN
        UPDATE reminders SET status = 'p' WHERE uuid = OLD.uuid;
    END;

-- when deleting a reminder, also delete tags that are not used anymore.
--   Note: The trigger is set on remindersXtags, and can also, in fact, be triggered by the ON CASCADE deletion.
CREATE TRIGGER delete_unused_tags
    AFTER DELETE ON remindersXtags
    FOR EACH ROW
    WHEN ((SELECT COUNT(tag_id) FROM remindersXtags WHERE tag_id = OLD.tag_id) = 0)
    BEGIN
        DELETE FROM tags WHERE id = OLD.tag_id;
    END;

-- when setting <recur>, also set status to 'recurring'.
--   Note: we also MUST set <due> and we also CAN set <until>.
CREATE TRIGGER update_status_recurring_on
    AFTER UPDATE OF recur ON reminders
    FOR EACH ROW
    WHEN NEW.recur IS NOT NULL
    BEGIN
        UPDATE reminders SET status = 'r' WHERE uuid = OLD.uuid;
    END;


-- VIEWS

CREATE VIEW folders AS
    SELECT "01" AS project, COUNT(uuid) AS nb, 'folder' AS category
    FROM reminders
    WHERE status = 'p' AND date(due) = date('now')
    UNION
    SELECT "02" AS project, COUNT(uuid) AS nb, 'folder' AS category
    FROM reminders
    WHERE status = 'p' AND datetime(due) < datetime('now')
    UNION
    SELECT "03" AS project, COUNT(uuid) AS nb, 'folder' AS category
    FROM reminders
    WHERE date(due) BETWEEN date('now') AND date('now', '+7 days')
    UNION
    SELECT "04" AS project, COUNT(uuid) AS nb, 'folder' AS category
    FROM reminders
    WHERE status = 'p' AND due IS NULL
    UNION
    SELECT "05" AS project, COUNT(uuid) AS nb, 'folder' AS category
    FROM reminders
    WHERE status = 'c'
    UNION
    SELECT "06" AS project, COUNT(uuid) AS nb, 'folder' AS category
    FROM reminders
    WHERE status = 'd'
    UNION
    SELECT project, COUNT(NULLIF('c', status)) AS nb, 'project' AS category
    FROM reminders
    WHERE status = 'p' OR status = 'c'
    GROUP BY project;


CREATE VIEW have_next_tag AS
    SELECT reminder_uuid
    FROM remindersXtags
    JOIN tags ON remindersXtags.tag_id = tags.id
    WHERE tags.tag = "next";


CREATE VIEW reminders_view AS
    SELECT
        reminders.*,
        -- All of the following are set to ease the computation of urgency and/or virtualtags.
        status <> 'c' AND status <> 'd' AND due IS NOT NULL AS due_set,
        ((strftime('%s', 'now') - strftime('%s', due)) / 86400.0) AS due_diff,
        ((strftime('%s', 'now') - strftime('%s', entry)) / 86400.0) AS age,
        COUNT(DISTINCT annotations.id) AS nb_annotations,
        COUNT(DISTINCT remindersXtags.tag_id) AS nb_tags,
        COUNT(dependencies.reminder_uuid) AS nb_sup
    FROM reminders
    LEFT JOIN annotations ON reminders.uuid = annotations.reminder_uuid
    LEFT JOIN remindersXtags ON reminders.uuid = remindersXtags.reminder_uuid
    LEFT JOIN dependencies ON reminders.uuid = dependencies.dependency_uuid
    GROUP BY reminders.uuid;


CREATE VIEW nb_subtasks AS
    WITH RECURSIVE blocking AS (
        SELECT r_uuid, d_uuid FROM subtasks
        UNION ALL
        SELECT subtasks.r_uuid, blocking.d_uuid  FROM blocking
        JOIN subtasks ON blocking.r_uuid = subtasks.d_uuid
    ),
    subtasks AS (
        SELECT dependencies.reminder_uuid AS r_uuid, dependencies.dependency_uuid AS d_uuid, reminders.status AS d_status FROM dependencies
        JOIN reminders ON d_uuid = reminders.uuid
        WHERE d_status = 'p'
    )
    SELECT r_uuid, COUNT(d_uuid) AS nb
    FROM blocking
    GROUP BY r_uuid;


--unblocked == !blocked
--duetoday  == today
CREATE VIEW virtualtags AS
    SELECT uuid,
        status = "p" AS vt_pending,
        status = "c" AS vt_completed,
        status = "d" AS vt_deleted,
        due_set = 1 AND datetime(due) < datetime('now') AS vt_overdue,
        due_set = 1 AND date(due) BETWEEN date('now') AND date('now', '+7 days') AS vt_due,
        due_set = 1 AND date(due) = date('now') AS vt_today,
        due_set = 1 AND date(due) = date('now', '-1 day') AS vt_yesterday,
        due_set = 1 AND date(due) = date('now', '+1 day') AS vt_tomorrow,
        due_set = 1 AND strftime('%W-%Y', due) = strftime('%W-%Y', 'now') AS vt_week,
        due_set = 1 AND strftime('%m-%Y', due) = strftime('%m-%Y', 'now') AS vt_month,
        due_set = 1 AND strftime('%Y', due) = strftime('%Y', 'now') AS vt_year,
        until IS NOT NULL AS vt_until,
        start IS NOT NULL AND end IS NULL AS vt_active,
        scheduled IS NOT NULL AS vt_scheduled,
        nb_tags > 0 AS vt_tagged,
        nb_annotations > 0 AS vt_annotated,
        wait IS NOT NULL AS vt_waiting,
        mask IS NOT NULL AS vt_parent,
        parent IS NOT NULL AS vt_child,
        status = "p" AND IFNULL((nb_subtasks.nb > 0), 0) AS vt_blocked,
        status = "p" AND nb_sup > 0 AS vt_blocking,
        status = "p" AND IFNULL((nb_subtasks.nb = 0), 1) AND (scheduled IS NULL OR datetime(scheduled) < datetime('now')) AS vt_ready,
        COUNT(have_next_tag.reminder_uuid) > 0 AS has_next
    FROM reminders_view
    LEFT JOIN nb_subtasks ON nb_subtasks.r_uuid = reminders_view.uuid
    LEFT JOIN have_next_tag ON have_next_tag.reminder_uuid = reminders_view.uuid
    GROUP BY reminders_view.uuid;


CREATE VIEW r AS
    SELECT reminders_view.*, 
    virtualtags.*,
    0.0
    -- age :
    + (CASE
        WHEN age > 365 THEN 1.0
        ELSE 1.0 * age / 365
       END) * 2.0

    -- due_date :
    + (CASE
        WHEN due_diff IS NULL THEN 0.0
        WHEN due_diff >= 7.0 THEN 1.0
        WHEN due_diff >= -14.0 THEN ((due_diff + 14.0) * 0.8 / 21.0) + 0.2
        ELSE 0.2
       END) * 12.0

    -- nb_annotations :
    + (CASE nb_annotations
        WHEN 0 THEN 0
        WHEN 1 THEN 0.8
        WHEN 2 THEN 0.9
        ELSE 1.0
       END) * 1.0

    -- nb_tags :
    + (CASE nb_tags
        WHEN 0 THEN 0
        WHEN 1 THEN 0.8
        WHEN 2 THEN 0.9
        ELSE 1.0
       END) * 1.0

    -- priority :
    + (CASE priority
        WHEN 'H' THEN 1.0
        WHEN 'M' THEN 0.65
        WHEN 'L' THEN 0.3
        ELSE 0.0
       END) * 6.0

    -- other (simple) coeffs, depending on data :
    + (CASE project
        WHEN '' THEN 0.0
        ELSE 1.0
       END) * 1.0

    + (CASE
        WHEN scheduled <> '' AND scheduled < datetime('now') THEN 1.0
        ELSE 0.0
       END) * 5.0

    + has_next * 15.0

    -- other (simple) coeffs, depending on virtual tags :
    + vt_blocking * 8.0
    + vt_active * 4.0
    + vt_blocked * -5.0
    + vt_waiting * -3.0
    AS urgency
    FROM reminders_view
    LEFT JOIN virtualtags
    ON reminders_view.uuid = virtualtags.uuid;



-- DUMMY DATA (TESTING PURPOSE) ------------------------------------------------

INSERT INTO reminders(uuid, status, description, due, project, priority) VALUES("d1d43cae-60a2-454b-93c3-bab0e6233af9", "p", "Task 01.", "2015-03-10T14:16:45Z", "Test DB", "");
INSERT INTO reminders(uuid, status, description, due, project, priority) VALUES("ea79c8ed-3abf-4d62-98a5-f27bb4b7ff78", "p", "Task 02.", NULL, "Test DB", "L");
INSERT INTO reminders(uuid, status, description, due, project, priority) VALUES("ab891a89-2737-41f6-be53-4fc07e8f89de", "p", "Task 03.", "2015-03-03T14:16:45Z", "Test DB", "M");
INSERT INTO reminders(uuid, status, description, due, project, priority) VALUES("17211f42-5f0b-453c-a91c-d63fb722bd16", "p", "Task 04.", "2015-03-12T14:16:45Z", "Test DB", "H");
INSERT INTO reminders(uuid, status, description, due, project, priority) VALUES("18ae4075-f223-421a-a852-5d5cd8094cf9", "p", "Task 05.", NULL, "Test DB", "");
INSERT INTO reminders(uuid, status, description, due, project, priority) VALUES("ec8eb8e9-f674-4c82-9b0d-8d41ac91560c", "p", "Task 06.", NULL, "Test DB", "L");
INSERT INTO reminders(uuid, status, description, due, project, priority) VALUES("85642219-e06f-4520-ae74-72f06d541358", "p", "Task 07.", "2015-03-10T14:16:45Z", "Test DB", "M");
INSERT INTO reminders(uuid, status, description, due, project, priority) VALUES("112d0457-3ca0-445e-898a-73e7dca8edf0", "p", "Task 08.", "2015-03-10T14:16:45Z", "Test DB", "H");
INSERT INTO reminders(uuid, status, description, due, project, priority) VALUES("d4b0b6f7-7824-4a5b-a9a5-5512cd6f1fdc", "c", "Task 09.", "2015-03-10T14:16:45Z", "Test DB", "");
INSERT INTO reminders(uuid, status, description, due, project, priority) VALUES("7cc4c89b-e578-4bba-ad25-c151fcd7c935", "d", "Task 10.", "2015-03-10T14:16:45Z", "Test DB", "L");

INSERT INTO annotations(description, reminder_uuid) VALUES('Annotation 1.', 'd1d43cae-60a2-454b-93c3-bab0e6233af9');
INSERT INTO annotations(description, reminder_uuid) VALUES('Annotation 2.', 'd1d43cae-60a2-454b-93c3-bab0e6233af9');
INSERT INTO annotations(description, reminder_uuid) VALUES('Annotation 1.', 'ea79c8ed-3abf-4d62-98a5-f27bb4b7ff78');


INSERT OR IGNORE INTO dependencies(reminder_uuid, dependency_uuid) VALUES('d1d43cae-60a2-454b-93c3-bab0e6233af9', 'ea79c8ed-3abf-4d62-98a5-f27bb4b7ff78');
INSERT OR IGNORE INTO dependencies(reminder_uuid, dependency_uuid) VALUES('d1d43cae-60a2-454b-93c3-bab0e6233af9', 'ab891a89-2737-41f6-be53-4fc07e8f89de');
INSERT OR IGNORE INTO dependencies(reminder_uuid, dependency_uuid) VALUES('ab891a89-2737-41f6-be53-4fc07e8f89de', '17211f42-5f0b-453c-a91c-d63fb722bd16');

-- -----------------------------------------------------------------------------

SELECT uuid, description, urgency, project, status, nb_annotations, nb_tags, due, vt_overdue, vt_yesterday, vt_due, vt_today, vt_tomorrow, vt_blocking, vt_blocked, vt_ready, has_next FROM r ORDER BY urgency DESC;
