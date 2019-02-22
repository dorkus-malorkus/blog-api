CREATE DOMAIN ID INTEGER;
CREATE DOMAIN EMAIL VARCHAR(320);
CREATE DOMAIN HANDLE VARCHAR(64);
CREATE DOMAIN PASSWORD CHAR(512);
CREATE DOMAIN HEADER TEXT;
CREATE DOMAIN BODY TEXT;
CREATE DOMAIN STYLE TEXT;
CREATE DOMAIN TOPIC VARCHAR(24);
CREATE DOMAIN ACTION VARCHAR(64);


BEGIN;

  CREATE FUNCTION trimIdentifier(str TEXT)
    RETURNS TEXT AS $$
      SELECT trim((SELECT regexp_replace((SELECT regexp_replace(str, '^[^[:alnum:]]+', '', 'gi') LIMIT 1), '[^[:alnum:]]+$', '', 'gi') LIMIT 1));
    $$ LANGUAGE SQL;

  CREATE FUNCTION sanitizeIdentifier(inp TEXT)
    RETURNS TEXT AS $$
      SELECT lower((SELECT trimIdentifier((SELECT regexp_replace(inp, '[^[:alpha:]^[:digit:]]+', '-', 'gi') LIMIT 1)) LIMIT 1));
    $$ LANGUAGE SQL;

COMMIT;


\include_relative build/logs.sql
\include_relative build/authors.sql
\include_relative build/posts.sql


BEGIN;

  GRANT ALL ON SCHEMA posts TO "dm-api";
  GRANT ALL ON SCHEMA authors TO "dm-api";
  GRANT ALL ON SCHEMA logs TO "dm-api";

  GRANT SELECT ON TABLE authors TO "dm-api";
  GRANT INSERT ON TABLE authors TO "dm-api";
  GRANT UPDATE ON TABLE authors TO "dm-api";

  GRANT SELECT ON TABLE authors.passwords TO "dm-api";
  GRANT INSERT ON TABLE authors.passwords TO "dm-api";
  GRANT UPDATE ON TABLE authors.passwords TO "dm-api";

  GRANT SELECT ON TABLE authors.handles TO "dm-api";
  GRANT INSERT ON TABLE authors.handles TO "dm-api";
  GRANT UPDATE ON TABLE authors.handles TO "dm-api";

  GRANT SELECT ON TABLE authors.emails TO "dm-api";
  GRANT INSERT ON TABLE authors.emails TO "dm-api";
  GRANT UPDATE ON TABLE authors.emails TO "dm-api";

  GRANT SELECT ON TABLE authors.configurations TO "dm-api";
  GRANT INSERT ON TABLE authors.configurations TO "dm-api";
  GRANT UPDATE ON TABLE authors.configurations TO "dm-api";

  GRANT SELECT ON TABLE posts TO "dm-api";
  GRANT INSERT ON TABLE posts TO "dm-api";
  GRANT UPDATE ON TABLE posts TO "dm-api";

  GRANT SELECT ON TABLE topics TO "dm-api";
  GRANT INSERT ON TABLE topics TO "dm-api";
  GRANT UPDATE ON TABLE topics TO "dm-api";

  GRANT SELECT ON TABLE posts.associations TO "dm-api";
  GRANT INSERT ON TABLE posts.associations TO "dm-api";
  GRANT UPDATE ON TABLE posts.associations TO "dm-api";

  GRANT SELECT ON TABLE posts.content TO "dm-api";
  GRANT INSERT ON TABLE posts.content TO "dm-api";
  GRANT UPDATE ON TABLE posts.content TO "dm-api";

  GRANT SELECT ON TABLE posts.configurations TO "dm-api";
  GRANT INSERT ON TABLE posts.configurations TO "dm-api";
  GRANT UPDATE ON TABLE posts.configurations TO "dm-api";

  GRANT SELECT ON TABLE posts.topics TO "dm-api";
  GRANT INSERT ON TABLE posts.topics TO "dm-api";
  GRANT UPDATE ON TABLE posts.topics TO "dm-api";

  GRANT SELECT ON TABLE logs TO "dm-api";

  GRANT SELECT ON TABLE logs.entries TO "dm-api";

COMMIT;
