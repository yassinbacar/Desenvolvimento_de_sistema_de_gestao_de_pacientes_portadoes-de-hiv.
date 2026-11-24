SET SERVEROUTPUT ON

DECLARE v_id NUMBER;
BEGIN
  prc_registar_paciente('NID-0001', 'Duplicado', DATE '1990-01-01', 'F',
                        NULL, 'Machava Sede', NULL, v_id);
  DBMS_OUTPUT.PUT_LINE('I01 FALHOU: nao gerou erro');
  ROLLBACK;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('I01 OK -> ' || SQLERRM); ROLLBACK;
END;
/

DECLARE v_id NUMBER;
BEGIN
  prc_registar_paciente('NID-0099', 'Futuro', SYSDATE + 1, 'M',
                        NULL, 'Machava Sede', NULL, v_id);
  DBMS_OUTPUT.PUT_LINE('I02 FALHOU: nao gerou erro');
  ROLLBACK;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('I02 OK -> ' || SQLERRM); ROLLBACK;
END;
/

DECLARE v_pac NUMBER; v_prof NUMBER;
BEGIN
  SELECT id_paciente INTO v_pac FROM paciente WHERE nid = 'NID-0006';
  SELECT id_profissional INTO v_prof FROM profissional_saude WHERE num_registo = 'MED-0001';
  INSERT INTO consulta (id_paciente, id_profissional, data_consulta, tipo_consulta)
  VALUES (v_pac, v_prof, SYSDATE, 'INICIAL');
  DBMS_OUTPUT.PUT_LINE('I03 FALHOU: nao gerou erro');
  ROLLBACK;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('I03 OK -> ' || SQLERRM); ROLLBACK;
END;
/

DECLARE v_pac NUMBER; v_prof NUMBER;
BEGIN
  SELECT id_paciente INTO v_pac FROM paciente WHERE nid = 'NID-0001';
  SELECT id_profissional INTO v_prof FROM profissional_saude WHERE num_registo = 'MED-0001';
  INSERT INTO consulta (id_paciente, id_profissional, data_consulta,
                        tipo_consulta, data_proxima_consulta)
  VALUES (v_pac, v_prof, SYSDATE, 'SEGUIMENTO', SYSDATE - 10);
  DBMS_OUTPUT.PUT_LINE('I04 FALHOU: nao gerou erro');
  ROLLBACK;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('I04 OK -> ' || SQLERRM); ROLLBACK;
END;
/

DECLARE v_cons NUMBER; v_reg NUMBER;
BEGIN
  SELECT c.id_consulta INTO v_cons
    FROM consulta c JOIN paciente p ON p.id_paciente = c.id_paciente
   WHERE p.nid = 'NID-0003' AND ROWNUM = 1;
  SELECT id_regime INTO v_reg FROM regime_tarv WHERE codigo = 'AZT+3TC+LPV/r';
  INSERT INTO prescricao (id_consulta, id_regime, data_inicio, motivo)
  VALUES (v_cons, v_reg, TRUNC(SYSDATE), 'OUTRO');
  DBMS_OUTPUT.PUT_LINE('I05 FALHOU: nao gerou erro');
  ROLLBACK;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('I05 OK -> ' || SQLERRM); ROLLBACK;
END;
/

DECLARE v_cons NUMBER; v_reg NUMBER; v_id NUMBER;
BEGIN
  SELECT c.id_consulta INTO v_cons
    FROM consulta c JOIN paciente p ON p.id_paciente = c.id_paciente
   WHERE p.nid = 'NID-0003' AND ROWNUM = 1;
  SELECT id_regime INTO v_reg FROM regime_tarv WHERE codigo = 'AZT+3TC+LPV/r';
  prc_prescrever_regime(v_cons, v_reg, TRUNC(SYSDATE), 'INICIO', v_id);
  DBMS_OUTPUT.PUT_LINE('I06 FALHOU: nao gerou erro');
  ROLLBACK;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('I06 OK -> ' || SQLERRM); ROLLBACK;
END;
/

DECLARE v_presc NUMBER; v_prof NUMBER; v_id NUMBER;
BEGIN
  SELECT pr.id_prescricao INTO v_presc
    FROM prescricao pr
    JOIN consulta c ON c.id_consulta = pr.id_consulta
    JOIN paciente p ON p.id_paciente = c.id_paciente
   WHERE p.nid = 'NID-0003' AND pr.data_fim IS NULL;
  SELECT id_profissional INTO v_prof FROM profissional_saude WHERE num_registo = 'ENF-0002';
  prc_registar_dispensa(v_presc, v_prof, TRUNC(SYSDATE), 30, v_id);
  DBMS_OUTPUT.PUT_LINE('I07 FALHOU: nao gerou erro');
  ROLLBACK;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('I07 OK -> ' || SQLERRM); ROLLBACK;
END;
/

DECLARE v_presc NUMBER; v_prof NUMBER; v_id NUMBER;
BEGIN
  SELECT pr.id_prescricao INTO v_presc
    FROM prescricao pr
    JOIN consulta c ON c.id_consulta = pr.id_consulta
    JOIN paciente p ON p.id_paciente = c.id_paciente
   WHERE p.nid = 'NID-0002' AND pr.data_fim IS NOT NULL;
  SELECT id_profissional INTO v_prof FROM profissional_saude WHERE num_registo = 'FAR-0004';
  prc_registar_dispensa(v_presc, v_prof, TRUNC(SYSDATE), 30, v_id);
  DBMS_OUTPUT.PUT_LINE('I08 FALHOU: nao gerou erro');
  ROLLBACK;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('I08 OK -> ' || SQLERRM); ROLLBACK;
END;
/

BEGIN
  DELETE FROM consulta WHERE ROWNUM = 1;
  DBMS_OUTPUT.PUT_LINE('I09 FALHOU: nao gerou erro');
  ROLLBACK;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('I09 OK -> ' || SQLERRM); ROLLBACK;
END;
/

DECLARE v_total NUMBER; v_estado VARCHAR2(15);
BEGIN
  prc_actualizar_abandonos(90, v_total);
  SELECT estado_paciente INTO v_estado FROM paciente WHERE nid = 'NID-0004';
  DBMS_OUTPUT.PUT_LINE('I10 pacientes passados a ABANDONO: ' || v_total ||
                       ' | estado do NID-0004: ' || v_estado);
  ROLLBACK;
END;
/

SELECT p.nid, v.data_colheita, v.valor_resultado, v.situacao
  FROM vw_ultima_carga_viral v
  JOIN paciente p ON p.id_paciente = v.id_paciente
 ORDER BY p.nid;

SELECT nid, nome_completo, data_prevista, dias_atraso
  FROM vw_faltosos ORDER BY dias_atraso DESC;
