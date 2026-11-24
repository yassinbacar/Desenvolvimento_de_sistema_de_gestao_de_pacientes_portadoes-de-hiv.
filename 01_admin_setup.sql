SET VERIFY OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF SYS_CONTEXT('USERENV','CON_NAME') <> 'FREEPDB1' THEN
    RAISE_APPLICATION_ERROR(-20999,
      'Ligue-se a FREEPDB1 (servico //localhost:1521/FREEPDB1)');
  END IF;
END;
/

DECLARE
  v_dir VARCHAR2(500);
BEGIN
  SELECT REGEXP_REPLACE(file_name, '[^/\\]+$', '') INTO v_dir
    FROM dba_data_files
   WHERE tablespace_name = 'SYSTEM' AND ROWNUM = 1;

  EXECUTE IMMEDIATE 'CREATE TABLESPACE ts_hiv_dados DATAFILE ''' || v_dir ||
    'ts_hiv_dados01.dbf'' SIZE 100M AUTOEXTEND ON NEXT 10M MAXSIZE 1G';
  EXECUTE IMMEDIATE 'CREATE TABLESPACE ts_hiv_idx DATAFILE ''' || v_dir ||
    'ts_hiv_idx01.dbf'' SIZE 50M AUTOEXTEND ON NEXT 10M MAXSIZE 500M';
  DBMS_OUTPUT.PUT_LINE('Tablespaces criados em: ' || v_dir);
END;
/

CREATE USER hiv_machava IDENTIFIED BY "&v_pwd"
  DEFAULT TABLESPACE ts_hiv_dados
  TEMPORARY TABLESPACE temp
  QUOTA UNLIMITED ON ts_hiv_dados
  QUOTA UNLIMITED ON ts_hiv_idx;

GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE TRIGGER,
      CREATE PROCEDURE, CREATE VIEW TO hiv_machava;

CREATE ROLE rl_medico;
CREATE ROLE rl_laboratorio;
CREATE ROLE rl_farmacia;
CREATE ROLE rl_administrador;

GRANT CREATE SESSION TO rl_medico, rl_laboratorio, rl_farmacia, rl_administrador;
