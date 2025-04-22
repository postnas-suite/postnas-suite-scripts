SET client_encoding TO 'UTF8';
SET search_path = :"alkis_schema", :"parent_schema", :"postgis_schema", public;


SELECT 'Grants';

GRANT usage on SCHEMA public To public;
GRANT SELECT ON  ALL SEQUENCES IN SCHEMA public TO lesenows;
GRANT SELECT ON  ALL TABLES IN SCHEMA public TO lesenows;
GRANT EXECUTE ON  ALL FUNCTIONS IN SCHEMA public TO lesenows;

