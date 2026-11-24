CREATE OR REPLACE TRIGGER trg_paciente_data_nasc
BEFORE INSERT OR UPDATE OF data_nascimento ON paciente
FOR EACH ROW
BEGIN
  IF :NEW.data_nascimento > SYSDATE THEN
    RAISE_APPLICATION_ERROR(-20001,
      'RN20: a data de nascimento nao pode ser posterior a data actual.');
  END IF;
END trg_paciente_data_nasc;
/

CREATE OR REPLACE TRIGGER trg_consulta_teste_reactivo
BEFORE INSERT ON consulta
FOR EACH ROW
DECLARE
  v_n NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_n
    FROM teste_hiv
   WHERE id_paciente = :NEW.id_paciente
     AND resultado = 'REACTIVO';
  IF v_n = 0 THEN
    RAISE_APPLICATION_ERROR(-20002,
      'RN02: o paciente nao tem teste de HIV REACTIVO registado.');
  END IF;
END trg_consulta_teste_reactivo;
/

CREATE OR REPLACE TRIGGER trg_prescricao_unica_activa
FOR INSERT OR UPDATE OF data_fim, id_consulta ON prescricao
COMPOUND TRIGGER
  TYPE t_ids IS TABLE OF prescricao.id_consulta%TYPE INDEX BY PLS_INTEGER;
  g_ids t_ids;

  BEFORE EACH ROW IS
  BEGIN
    g_ids(g_ids.COUNT + 1) := :NEW.id_consulta;
  END BEFORE EACH ROW;

  AFTER STATEMENT IS
    v_pac NUMBER;
    v_act NUMBER;
  BEGIN
    FOR i IN 1 .. g_ids.COUNT LOOP
      SELECT id_paciente INTO v_pac
        FROM consulta WHERE id_consulta = g_ids(i);
      SELECT COUNT(*) INTO v_act
        FROM prescricao p
        JOIN consulta c ON c.id_consulta = p.id_consulta
       WHERE c.id_paciente = v_pac
         AND p.data_fim IS NULL;
      IF v_act > 1 THEN
        RAISE_APPLICATION_ERROR(-20003,
          'RN12: o paciente ja tem uma prescricao activa.');
      END IF;
    END LOOP;
    g_ids.DELETE;
  END AFTER STATEMENT;
END trg_prescricao_unica_activa;
/

CREATE OR REPLACE TRIGGER trg_dispensa_presc_activa
BEFORE INSERT ON dispensa
FOR EACH ROW
DECLARE
  v_fim prescricao.data_fim%TYPE;
BEGIN
  SELECT data_fim INTO v_fim
    FROM prescricao WHERE id_prescricao = :NEW.id_prescricao;
  IF v_fim IS NOT NULL AND v_fim < :NEW.data_dispensa THEN
    RAISE_APPLICATION_ERROR(-20004,
      'RN15: a prescricao ja foi encerrada em ' ||
      TO_CHAR(v_fim, 'DD/MM/YYYY') || '.');
  END IF;
END trg_dispensa_presc_activa;
/

CREATE OR REPLACE TRIGGER trg_busca_actualiza_estado
AFTER INSERT ON busca_activa
FOR EACH ROW
BEGIN
  IF :NEW.resultado IN ('TRANSFERIDO', 'OBITO') THEN
    UPDATE paciente SET estado_paciente = :NEW.resultado
     WHERE id_paciente = :NEW.id_paciente;
  ELSIF :NEW.resultado = 'REGRESSOU' THEN
    UPDATE paciente SET estado_paciente = 'ACTIVO'
     WHERE id_paciente = :NEW.id_paciente;
  END IF;
END trg_busca_actualiza_estado;
/

BEGIN
  FOR t IN (SELECT column_value AS nome
              FROM TABLE(sys.odcivarchar2list('PACIENTE','TESTE_HIV','CONSULTA',
                   'EXAME_LABORATORIAL','PRESCRICAO','DISPENSA','BUSCA_ACTIVA')))
  LOOP
    EXECUTE IMMEDIATE
      'CREATE OR REPLACE TRIGGER trg_bd_' || t.nome ||
      ' BEFORE DELETE ON ' || t.nome ||
      ' BEGIN RAISE_APPLICATION_ERROR(-20005, ' ||
      '''RN19: eliminacao fisica nao permitida em ' || t.nome || '''); END;';
  END LOOP;
END;
/
