

BEGIN;
  CREATE SCHEMA IF NOT EXISTS "posts";

  CREATE TABLE posts.associations (
    handle    HANDLE        UNIQUE NOT NULL,
    author    HANDLE        NOT NULL,
    parent    HANDLE        DEFAULT NULL

    --FOREIGN KEY(parent) REFERENCES posts.associations(handle)
  );

  CREATE TABLE posts.content (
    header      HEADER      DEFAULT '',
    subheader   HEADER      DEFAULT '',
    body        BODY        NOT NULL,

    post        HANDLE      UNIQUE NOT NULL

    --FOREIGN KEY(post) REFERENCES posts.associations(handle)
  );

  CREATE TABLE posts.configurations (
    active      BOOLEAN     DEFAULT FALSE,
    searchable  BOOLEAN     DEFAULT FALSE,
    commenting  BOOLEAN     DEFAULT FALSE,
    expanded    BOOLEAN     DEFAULT FALSE,

    post        HANDLE      UNIQUE NOT NULL

    --FOREIGN KEY(post) REFERENCES posts.associations(handle)
  );

  CREATE TABLE posts.topics (
    handle    TOPIC     NOT NULL,

    post      HANDLE    NOT NULL

    --FOREIGN KEY(post) REFERENCES posts.associations(handle)
  );


  CREATE VIEW posts AS
    SELECT
      pa.handle AS handle,
      pa.author AS author,
      pa.parent AS parent,
      pc.body AS body,
      pc.header AS header,
      pc.subheader AS subheader,
      pcfg.searchable AS searchable,
      pcfg.commenting AS commenting,
      pcfg.active AS active,
      pcfg.expanded AS expanded,
      pt.handle AS topic,
      upd_logs.timestamp AS updated,
      crt_logs.timestamp AS created
    FROM posts.associations pa
    INNER JOIN posts.content pc ON pc.post = pa.handle
    INNER JOIN posts.configurations pcfg ON pcfg.post = pa.handle
    LEFT JOIN logs upd_logs
      ON upd_logs.target = pa.handle
      AND upd_logs.timestamp = (
        SELECT MAX(timestamp) FROM logs
        WHERE target = pa.handle
          AND UPPER(action) = 'API-UPDATE-POST'
      )
    LEFT JOIN logs crt_logs
      ON crt_logs.target = pa.handle
      AND crt_logs.timestamp = (
        SELECT MAX(timestamp) FROM logs
        WHERE target = pa.handle
          AND UPPER(action) = 'API-CREATE-POST'
      )
    RIGHT JOIN posts.topics pt ON pt.post = pa.handle
    GROUP BY
      pcfg.active, pa.handle, pa.author, crt_logs.timestamp, pt.handle,
      pa.parent, pc.header, pc.body, pc.subheader, pcfg.expanded,
      pcfg.searchable, pcfg.commenting, upd_logs.timestamp
    ORDER BY crt_logs.timestamp, upd_logs.timestamp, pa.handle DESC;


  CREATE VIEW topics AS
    SELECT
      DISTINCT pt.handle AS handle,
      pt.handle AS topic,
      (SELECT active FROM posts.configurations WHERE post = pt.post) AS active,
      (SELECT searchable FROM posts.configurations WHERE post = pt.post) AS searchable

    FROM posts.topics pt
    INNER JOIN posts.associations pa ON pa.handle = pt.post
    INNER JOIN posts.configurations pcfg ON pcfg.post = pa.handle
    WHERE pcfg.active IS TRUE AND pcfg.searchable IS TRUE;


  CREATE RULE catchUpdateToPostsView AS ON UPDATE TO posts
    DO INSTEAD
      NOTHING;

  CREATE RULE updatePostsAssociations AS ON UPDATE TO posts
    DO ALSO
      UPDATE posts.associations
      SET
        author = NEW.author,
        parent = NEW.parent
      WHERE handle = NEW.handle;

  CREATE RULE updatePostsContent AS ON UPDATE TO posts
    DO ALSO
      UPDATE posts.content
      SET
        header = NEW.header,
        subheader = NEW.subheader,
        body = NEW.body
      WHERE post = NEW.handle;

  CREATE RULE updatePostsConfiguration AS ON UPDATE TO posts
    DO ALSO
      UPDATE posts.configurations
      SET
        active = NEW.active,
        searchable = NEW.searchable,
        commenting = NEW.commenting
      WHERE post = NEW.handle;


  CREATE RULE catchInsertIntoPostsView AS ON INSERT TO posts
    DO INSTEAD
      NOTHING;

  CREATE RULE createNewPostsAssociation AS ON INSERT TO posts
    DO ALSO
      INSERT INTO posts.associations(handle, author, parent) VALUES (
        sanitizeIdentifier(NEW.header::TEXT)::HANDLE, NEW.author, NEW.parent
      );

  CREATE RULE createNewPostsContent AS ON INSERT TO posts
    DO ALSO
      INSERT INTO posts.content(post, header, subheader, body) VALUES (
        sanitizeIdentifier(NEW.header::TEXT)::HANDLE, NEW.header, NEW.subheader, NEW.body
      );

  CREATE RULE createNewPostsConfiguration AS ON INSERT TO posts
    DO ALSO
      INSERT INTO posts.configurations(post, active, searchable, commenting) VALUES (
        sanitizeIdentifier(NEW.header::TEXT)::HANDLE, NEW.active, NEW.searchable, NEW.commenting
      );

  --CREATE RULE createNewPostsTopic AS ON INSERT TO posts
  --  DO ALSO
  --    INSERT INTO posts.topics(post, handle) VALUES (
  --      sanitizeIdentifier(NEW.header::TEXT)::HANDLE, LOWER(NEW.topic)
  --    );


  CREATE RULE doNotDeletePosts AS ON DELETE TO posts
    DO INSTEAD
      UPDATE posts SET active = false WHERE handle = OLD.handle;

  --CREATE RULE doNotDeletePostsAssociations AS ON DELETE TO posts.associations DO NOTHING;
  --CREATE RULE doNotDeletePostsContent AS ON DELETE TO posts.content DO NOTHING;
  --CREATE RULE doNotDeletePostsTopics AS ON DELETE TO posts.topics DO NOTHING;
  --CREATE RULE doNotDeletePostsConfigurations AS ON DELETE TO posts.configurations DO NOTHING;

  CREATE RULE logNewPostsEntry AS ON INSERT TO posts
    DO ALSO
      INSERT INTO logs(admin, target, action) VALUES (
        CURRENT_USER,
        sanitizeIdentifier(NEW.header::TEXT)::HANDLE,
        'API-CREATE-POST'
      );

  CREATE RULE logUpdatePostsEntry AS ON UPDATE TO posts
    DO ALSO
      INSERT INTO logs(admin, target, action) VALUES (
        CURRENT_USER,
        sanitizeIdentifier(NEW.header::TEXT)::HANDLE,
        'API-UPDATE-POST'
      );

COMMIT;
