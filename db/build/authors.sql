

BEGIN;
  CREATE SCHEMA IF NOT EXISTS "authors";

  CREATE TABLE authors.handles (
    longform    HANDLE      UNIQUE
  );

  CREATE TABLE authors.emails (
    address     EMAIL       UNIQUE,
    author      HANDLE      UNIQUE

    --FOREIGN KEY(author) REFERENCES authors.handles(longform)
 );

  CREATE TABLE authors.passwords (
    hash        PASSWORD,
    author      HANDLE      UNIQUE

    --FOREIGN KEY(author) REFERENCES authors.handles(longform)
  );

  CREATE TABLE authors.configurations (
    active      BOOLEAN     DEFAULT FALSE,
    searchable  BOOLEAN     DEFAULT FALSE,
    commenting  BOOLEAN     DEFAULT FALSE,

    author      HANDLE      UNIQUE

    --FOREIGN KEY(author) REFERENCES authors.handles(longform)
  );

  CREATE VIEW authors AS
    SELECT
      ae.address AS email,
      ah.longform AS handle,
      ac.active AS active,
      ac.searchable AS searchable,
      ac.commenting AS commenting,
      upd_logs.timestamp AS updated,
      crt_logs.timestamp AS created
    FROM authors.emails ae
    INNER JOIN authors.handles ah ON ah.longform = ae.author
    INNER JOIN authors.configurations ac ON ac.author = ae.author
    LEFT JOIN logs upd_logs
      ON upd_logs.target = ah.longform
      AND upd_logs.timestamp = (
        SELECT MAX(timestamp) FROM logs
        WHERE target = ah.longform
          AND UPPER(action) = 'API-UPDATE-AUTHOR'
      )
    LEFT JOIN logs crt_logs
      ON crt_logs.target = ah.longform
      AND crt_logs.timestamp = (
        SELECT MAX(timestamp) FROM logs
        WHERE target = ah.longform
          AND UPPER(action) = 'API-CREATE-AUTHOR'
      )
    ORDER BY crt_logs.timestamp, upd_logs.timestamp, ah.longform DESC;

  CREATE RULE catchUpdateToAuthorsView AS ON UPDATE TO authors
    DO INSTEAD
      NOTHING;

  CREATE RULE updateAuthorsEmail AS ON UPDATE TO authors
    DO ALSO
      UPDATE authors.emails
      SET
        address = NEW.email
      WHERE author = NEW.handle;

  CREATE RULE updateAuthorsConfiguration AS ON UPDATE TO authors
    DO ALSO
      UPDATE authors.configurations
      SET
        active = NEW.active,
        searchable = NEW.searchable,
        commenting = NEW.commenting
      WHERE author = NEW.handle;


  CREATE RULE catchInsertIntoAuthorsView AS ON INSERT TO authors
    DO INSTEAD
     NOTHING;

  CREATE RULE createNewAuthorsHandle AS ON INSERT TO authors
    DO ALSO
      INSERT INTO authors.handles(longform) VALUES (
        NEW.handle
      );

  CREATE RULE createNewAuthorsEmail AS ON INSERT TO authors
    DO ALSO
      INSERT INTO authors.emails(author, address) VALUES (
        NEW.handle, NEW.email
      );

  CREATE RULE createNewAuthorsConfiguration AS ON INSERT TO authors
    DO ALSO
      INSERT INTO authors.configurations(author, active, searchable, commenting) VALUES (
        NEW.handle, NEW.active, NEW.searchable, NEW.commenting
      );

  CREATE RULE doNotDeleteAuthors AS ON DELETE TO authors
    DO INSTEAD
      UPDATE authors SET active = false WHERE handle = OLD.handle;


  CREATE FUNCTION setPassword(authId ID, input PASSWORD)
    RETURNS VOID AS $$
      BEGIN
        UPDATE authors.passwords SET hash = input WHERE author = authId;
      END;
    $$ LANGUAGE plpgsql;

  CREATE FUNCTION checkPassword(auth HANDLE, pw PASSWORD)
    RETURNS BOOLEAN AS $$
      SELECT CASE
        WHEN hash = pw THEN
          true
        ELSE
          false
        END
      FROM authors.passwords
      WHERE author = auth
      LIMIT 1;
    $$ LANGUAGE SQL;

  CREATE RULE logNewAuthorsEntry AS ON INSERT TO authors
    DO ALSO
      INSERT INTO logs(admin, target, action) VALUES (
        CURRENT_USER, NEW.handle, 'API-CREATE-AUTHOR'
      );

  CREATE RULE logUpdateAuthorsEntry AS ON UPDATE TO authors
    DO ALSO
      INSERT INTO logs(admin, target, action) VALUES (
        CURRENT_USER, NEW.handle, 'API-UPDATE-AUTHOR'
      );

COMMIT;
