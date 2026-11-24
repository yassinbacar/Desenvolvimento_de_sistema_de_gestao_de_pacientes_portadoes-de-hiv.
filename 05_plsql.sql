CREATE OR REPLACE FUNCTION fn_supressao_viral (p_valor IN NUMBER)
RETURN VARCHAR2 DETERMINISTIC
IS
BEGIN
  IF p_valor IS NULL THEN
    RETURN NULL;
  ELSIF p_valor < 1000 THEN
    RETURN 'SUPRIMIDA';
  ELSE
    RETURN 'NAO_SUPRIMIDA';
  END IF;
END fn_supressao_viral;
/

CREATE OR REPLACE VIEW vw_faltosos AS
SELECT p.id_paciente, p.nid, p.nome_completo, p.contacto_telefonico,
       MAX(d.data_proximo_levantamento)                    AS data_prevista,
       TRUNC(SYSDATE) - MAX(d.data_proximo_levantamento)   AS dias_atraso
  FROM paciente p
  JOIN consulta c   ON c.id_paciente   = p.id_paciente
  JOIN prescricao pr ON pr.id_consulta = c.id_consulta
  JOIN dispensa d   ON d.id_prescricao = pr.id_prescricao
 WHERE p.estado_paciente = 'ACTIVO'
 GROUP BY p.id_paciente, p.nid, p.nome_completo, p.contacto_telefonico
HAVING MAX(d.data_proximo_levantamento) < TRUNC(SYSDATE);

CREATE OR REPLACE VIEW vw_ultima_carga_viral AS
SELECT id_paciente, data_colheita, valor_resultado,
       fn_supressao_viral(valor_resultado) AS situacao
  FROM (SELECT e.id_paciente, e.data_colheita, e.valor_resultado,
               ROW_NUMBER() OVER (PARTITION BY e.id_paciente
                                  ORDER BY e.data_colheita DESC) AS rn
          FROM exame_laboratorial e
          JOIN tipo_exame t ON t.id_tipo_exame = e.id_tipo_exame
         WHERE t.designacao = 'Carga Viral')
 WHERE rn = 1;

CREATE OR REPLACE PROCEDURE prc_registar_paciente (
  p_nid       IN VARCHAR2,
  p_nome      IN VARCHAR2,
  p_data_nasc IN DATE,
  p_sexo      IN CHAR,
  p_contacto  IN VARCHAR2,
  p_bairro    IN VARCHAR2,
  p_endereco  IN VARCHAR2,
  p_id        OUT NUMBER)
IS
BEGIN
  INSERT INTO paciente (nid, nome_completo, data_nascimento, sexo,
                        contacto_telefonico, bairro, endereco)
  VALUES (p_nid, p_nome, p_data_nasc, p_sexo, p_contacto, p_bairro, p_endereco)
  RETURNING id_paciente INTO p_id;
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20010, 'RN01: NID ja existente: ' || p_nid);
END prc_registar_paciente;
/

CREATE OR REPLACE PROCEDURE prc_registar_teste (
  p_id_paciente IN NUMBER,
  p_id_prof     IN NUMBER,
  p_data        IN DATE,
  p_tipo        IN VARCHAR2,
  p_resultado   IN VARCHAR2,
  p_id          OUT NUMBER)
IS
BEGIN
  INSERT INTO teste_hiv (id_paciente, id_profissional, data_teste,
                         tipo_teste, resultado)
  VALUES (p_id_paciente, p_id_prof, p_data, p_tipo, p_resultado)
  RETURNING id_teste INTO p_id;
END prc_registar_teste;
/

CREATE OR REPLACE PROCEDURE prc_prescrever_regime (
  p_id_consulta IN NUMBER,
  p_id_regime   IN NUMBER,
  p_data_inicio IN DATE,
  p_motivo      IN VARCHAR2 DEFAULT 'INICIO',
  p_id          OUT NUMBER)
IS
  v_pac NUMBER;
  v_act NUMBER;
BEGIN
  SELECT id_paciente INTO v_pac
    FROM consulta WHERE id_consulta = p_id_consulta;

  SELECT COUNT(*) INTO v_act
    FROM prescricao p
    JOIN consulta c ON c.id_consulta = p.id_consulta
   WHERE c.id_paciente = v_pac AND p.data_fim IS NULL;

  IF v_act > 0 AND p_motivo = 'INICIO' THEN
    RAISE_APPLICATION_ERROR(-20012,
      'RN13: a mudanca de regime exige um motivo diferente de INICIO.');
  END IF;

  UPDATE prescricao
     SET data_fim = p_data_inicio
   WHERE data_fim IS NULL
     AND id_consulta IN (SELECT id_consulta FROM consulta
                          WHERE id_paciente = v_pac);

  INSERT INTO prescricao (id_consulta, id_regime, data_inicio, motivo)
  VALUES (p_id_consulta, p_id_regime, p_data_inicio, p_motivo)
  RETURNING id_prescricao INTO p_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20011, 'Consulta inexistente.');
END prc_prescrever_regime;
/

CREATE OR REPLACE PROCEDURE prc_registar_dispensa (
  p_id_prescricao IN NUMBER,
  p_id_prof       IN NUMBER,
  p_data          IN DATE,
  p_dias          IN NUMBER,
  p_id            OUT NUMBER)
IS
  v_cat profissional_saude.categoria%TYPE;
BEGIN
  SELECT categoria INTO v_cat
    FROM profissional_saude WHERE id_profissional = p_id_prof;

  IF v_cat <> 'FARMACEUTICO' THEN
    RAISE_APPLICATION_ERROR(-20013,
      'RN14: a dispensa so pode ser feita por profissional de farmacia.');
  END IF;

  INSERT INTO dispensa (id_prescricao, id_profissional, data_dispensa,
                        quantidade_dias, data_proximo_levantamento)
  VALUES (p_id_prescricao, p_id_prof, p_data, p_dias, p_data + p_dias)
  RETURNING id_dispensa INTO p_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20014, 'Profissional inexistente.');
END prc_registar_dispensa;
/

CREATE OR REPLACE PROCEDURE prc_registar_busca (
  p_id_paciente   IN NUMBER,
  p_data_falta    IN DATE,
  p_data_contacto IN DATE,
  p_meio          IN VARCHAR2,
  p_agente        IN VARCHAR2,
  p_resultado     IN VARCHAR2)
IS
BEGIN
  INSERT INTO busca_activa (id_paciente, data_falta, data_contacto,
                            meio_contacto, agente_responsavel, resultado)
  VALUES (p_id_paciente, p_data_falta, p_data_contacto,
          p_meio, p_agente, p_resultado);
END prc_registar_busca;
/

CREATE OR REPLACE PROCEDURE prc_actualizar_abandonos (
  p_limite_dias IN NUMBER DEFAULT 90,
  p_total       OUT NUMBER)
IS
BEGIN
  UPDATE paciente
     SET estado_paciente = 'ABANDONO'
   WHERE id_paciente IN (SELECT id_paciente FROM vw_faltosos
                          WHERE dias_atraso > p_limite_dias);
  p_total := SQL%ROWCOUNT;
END prc_actualizar_abandonos;
/
