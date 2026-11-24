SELECT table_name FROM user_tables ORDER BY 1;
SELECT constraint_type, COUNT(*) AS total
  FROM user_constraints GROUP BY constraint_type ORDER BY 1;

SELECT index_name, table_name FROM user_indexes ORDER BY 2, 1;
SELECT object_type, object_name, status FROM user_objects
 WHERE object_type IN ('SEQUENCE','TRIGGER','PROCEDURE','FUNCTION','VIEW')
 ORDER BY 1, 2;
SELECT object_type, COUNT(*) AS total,
       SUM(CASE WHEN status = 'VALID' THEN 1 ELSE 0 END) AS validos
  FROM user_objects
 WHERE object_type IN ('SEQUENCE','TRIGGER','PROCEDURE','FUNCTION','VIEW')
 GROUP BY object_type ORDER BY 1;

SELECT * FROM user_sys_privs ORDER BY 2;
SELECT * FROM user_role_privs;
SELECT grantee, table_name, privilege
  FROM user_tab_privs_made
 WHERE grantee LIKE 'RL\_%' ESCAPE '\'
 ORDER BY grantee, table_name, privilege;
