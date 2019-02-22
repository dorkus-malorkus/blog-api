

BEGIN;
  CREATE SCHEMA IF NOT EXISTS "logs";

  CREATE TABLE logs.entries (
    admin     HANDLE      NOT NULL,
    target    HANDLE      DEFAULT NULL,

    action    ACTION      NOT NULL,
    comment   TEXT        DEFAULT NULL,

    timestamp   TIMESTAMP   DEFAULT CURRENT_TIMESTAMP
  );

  CREATE VIEW logs.actions AS
    SELECT
      DISTINCT le.action AS action
    FROM logs.entries le;

  CREATE VIEW logs AS
    SELECT *
    FROM logs.entries le;

  CREATE RULE createNewLogEntry AS ON INSERT TO logs
    DO INSTEAD
      INSERT INTO logs.entries(admin, action, comment, target) VALUES (
        NEW.admin, sanitizeIdentifier(NEW.action)::ACTION, NEW.comment, NEW.target
      );

  CREATE RULE blockLogDeletions AS ON DELETE TO logs DO NOTHING;
  CREATE RULE blockLogUpdates AS ON UPDATE TO logs DO NOTHING;

  --CREATE RULE blockAllLogDeletions AS ON DELETE TO logs.entries DO NOTHING;
  --CREATE RULE blockAllLogUpdates AS ON UPDATE TO logs.entries DO NOTHING;

COMMIT;
