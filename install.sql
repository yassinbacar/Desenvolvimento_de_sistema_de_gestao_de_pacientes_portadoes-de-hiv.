SET VERIFY OFF
SET ECHO OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

ACCEPT v_pwd CHAR PROMPT 'Palavra-passe a definir para HIV_MACHAVA: ' HIDE
ACCEPT v_host CHAR DEFAULT 'localhost:1521' PROMPT 'Host:porta [localhost:1521]: '

SPOOL ../docs/evidencias/install.log

@@01_admin_setup.sql

CONNECT hiv_machava/"&v_pwd"@//&v_host/FREEPDB1

@@02_sequencias_tabelas.sql
@@03_indices.sql
@@04_triggers.sql
@@05_plsql.sql
@@06_perfis_acesso.sql
@@07_dados_teste.sql
@@08_testes_integridade.sql
@@09_contagens.sql
@@10_evidencias.sql

SPOOL OFF
