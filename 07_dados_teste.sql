SET SERVEROUTPUT ON

INSERT INTO tipo_exame (designacao, unidade_medida) VALUES ('CD4', 'celulas/mm3');
INSERT INTO tipo_exame (designacao, unidade_medida) VALUES ('Carga Viral', 'copias/ml');
INSERT INTO tipo_exame (designacao, unidade_medida) VALUES ('Hemoglobina', 'g/dl');

INSERT INTO medicamento (nome_generico, dosagem, forma_farmaceutica)
  VALUES ('Tenofovir (TDF)', '300 mg', 'Comprimido');
INSERT INTO medicamento (nome_generico, dosagem, forma_farmaceutica)
  VALUES ('Lamivudina (3TC)', '300 mg', 'Comprimido');
INSERT INTO medicamento (nome_generico, dosagem, forma_farmaceutica)
  VALUES ('Dolutegravir (DTG)', '50 mg', 'Comprimido');
INSERT INTO medicamento (nome_generico, dosagem, forma_farmaceutica)
  VALUES ('Zidovudina (AZT)', '300 mg', 'Comprimido');
INSERT INTO medicamento (nome_generico, dosagem, forma_farmaceutica)
  VALUES ('Lopinavir/ritonavir (LPV/r)', '200/50 mg', 'Comprimido');

INSERT INTO regime_tarv (codigo, descricao, linha_tratamento)
  VALUES ('TDF+3TC+DTG', 'Tenofovir + Lamivudina + Dolutegravir', 1);
INSERT INTO regime_tarv (codigo, descricao, linha_tratamento)
  VALUES ('AZT+3TC+LPV/r', 'Zidovudina + Lamivudina + Lopinavir/ritonavir', 2);

INSERT INTO composicao_regime (id_regime, id_medicamento, posologia)
SELECT r.id_regime, m.id_medicamento, c.posologia
  FROM (SELECT 'TDF+3TC+DTG' reg, 'Tenofovir (TDF)' med,
               '1 comprimido ao deitar' posologia FROM dual
        UNION ALL SELECT 'TDF+3TC+DTG', 'Lamivudina (3TC)',
               '1 comprimido ao deitar' FROM dual
        UNION ALL SELECT 'TDF+3TC+DTG', 'Dolutegravir (DTG)',
               '1 comprimido ao deitar' FROM dual
        UNION ALL SELECT 'AZT+3TC+LPV/r', 'Zidovudina (AZT)',
               '1 comprimido de 12 em 12 h' FROM dual
        UNION ALL SELECT 'AZT+3TC+LPV/r', 'Lamivudina (3TC)',
               '1 comprimido de 12 em 12 h' FROM dual
        UNION ALL SELECT 'AZT+3TC+LPV/r', 'Lopinavir/ritonavir (LPV/r)',
               '2 comprimidos de 12 em 12 h' FROM dual) c
  JOIN regime_tarv r ON r.codigo = c.reg
  JOIN medicamento m ON m.nome_generico = c.med;

DECLARE
  v_hoje DATE := TRUNC(SYSDATE);
  v_med NUMBER; v_enf NUMBER; v_lab NUMBER; v_far NUMBER; v_con NUMBER;
  v_p1 NUMBER; v_p2 NUMBER; v_p3 NUMBER; v_p4 NUMBER; v_p5 NUMBER; v_p6 NUMBER;
  v_r1 NUMBER; v_r2 NUMBER; v_cd4 NUMBER; v_cv NUMBER;
  v_id NUMBER; v_c NUMBER; v_pr NUMBER;

  PROCEDURE prof (p_nome VARCHAR2, p_cat VARCHAR2, p_reg VARCHAR2, o_id OUT NUMBER) IS
  BEGIN
    INSERT INTO profissional_saude (nome_completo, categoria, num_registo, contacto)
    VALUES (p_nome, p_cat, p_reg, '84 000 0000')
    RETURNING id_profissional INTO o_id;
  END;

  PROCEDURE teste (p_pac NUMBER, p_data DATE, p_tipo VARCHAR2, p_res VARCHAR2) IS
    v NUMBER;
  BEGIN
    prc_registar_teste(p_pac, v_con, p_data, p_tipo, p_res, v);
  END;

  PROCEDURE cons (p_pac NUMBER, p_data DATE, p_tipo VARCHAR2, p_peso NUMBER,
                  p_est NUMBER, p_prox DATE, o_id OUT NUMBER) IS
  BEGIN
    INSERT INTO consulta (id_paciente, id_profissional, data_consulta,
                          tipo_consulta, peso_kg, estadio_oms, data_proxima_consulta)
    VALUES (p_pac, v_med, p_data, p_tipo, p_peso, p_est, p_prox)
    RETURNING id_consulta INTO o_id;
  END;

  PROCEDURE exame (p_pac NUMBER, p_tipo NUMBER, p_cons NUMBER, p_data DATE,
                   p_valor NUMBER) IS
  BEGIN
    INSERT INTO exame_laboratorial (id_paciente, id_tipo_exame, id_consulta,
                                    id_profissional, data_colheita,
                                    data_resultado, valor_resultado)
    VALUES (p_pac, p_tipo, p_cons, v_lab, p_data, p_data + 2, p_valor);
  END;
BEGIN
  prof('Amelia Cossa',      'MEDICO',             'MED-0001', v_med);
  prof('Bernardo Mabjaia',  'ENFERMEIRO',         'ENF-0002', v_enf);
  prof('Carla Sitoe',       'TECNICO_LABORATORIO','LAB-0003', v_lab);
  prof('Domingos Chongo',   'FARMACEUTICO',       'FAR-0004', v_far);
  prof('Esperanca Tembe',   'CONSELHEIRO',        'CON-0005', v_con);

  SELECT id_tipo_exame INTO v_cd4 FROM tipo_exame WHERE designacao = 'CD4';
  SELECT id_tipo_exame INTO v_cv  FROM tipo_exame WHERE designacao = 'Carga Viral';
  SELECT id_regime INTO v_r1 FROM regime_tarv WHERE codigo = 'TDF+3TC+DTG';
  SELECT id_regime INTO v_r2 FROM regime_tarv WHERE codigo = 'AZT+3TC+LPV/r';

  prc_registar_paciente('NID-0001', 'Ana Maria Macie', DATE '1985-03-12', 'F',
                        '84 000 0001', 'Machava Sede', 'Casa 12', v_p1);
  prc_registar_paciente('NID-0002', 'Joao Pedro Nhaca', DATE '1979-07-30', 'M',
                        '84 000 0002', 'Machava Socimol', 'Casa 7', v_p2);
  prc_registar_paciente('NID-0003', 'Luisa Fernando Bila', DATE '1992-11-05', 'F',
                        '84 000 0003', 'Machava Sede', 'Casa 31', v_p3);
  prc_registar_paciente('NID-0004', 'Carlos Alberto Uamusse', DATE '1988-01-20', 'M',
                        '84 000 0004', 'Machava Socimol', 'Casa 4', v_p4);
  prc_registar_paciente('NID-0005', 'Marta Isabel Nhantumbo', DATE '2001-06-18', 'F',
                        '84 000 0005', 'Machava Sede', 'Casa 22', v_p5);
  prc_registar_paciente('NID-0006', 'Rui Manuel Timana', DATE '1995-09-09', 'M',
                        '84 000 0006', 'Machava Sede', 'Casa 9', v_p6);

  teste(v_p1, v_hoje - 260, 'DIAGNOSTICO', 'REACTIVO');
  cons(v_p1, v_hoje - 258, 'INICIAL', 62, 2, v_hoje - 228, v_c);
  exame(v_p1, v_cd4, v_c, v_hoje - 258, 310);
  exame(v_p1, v_cv,  v_c, v_hoje - 258, 45000);
  prc_prescrever_regime(v_c, v_r1, v_hoje - 258, 'INICIO', v_pr);
  prc_registar_dispensa(v_pr, v_far, v_hoje - 258, 30, v_id);
  cons(v_p1, v_hoje - 60, 'SEGUIMENTO', 65, 1, v_hoje + 30, v_c);
  exame(v_p1, v_cv, v_c, v_hoje - 60, 200);
  prc_registar_dispensa(v_pr, v_far, v_hoje - 20, 90, v_id);

  teste(v_p2, v_hoje - 240, 'DIAGNOSTICO', 'REACTIVO');
  cons(v_p2, v_hoje - 238, 'INICIAL', 70, 3, v_hoje - 208, v_c);
  exame(v_p2, v_cd4, v_c, v_hoje - 238, 180);
  exame(v_p2, v_cv,  v_c, v_hoje - 238, 150000);
  prc_prescrever_regime(v_c, v_r1, v_hoje - 238, 'INICIO', v_pr);
  prc_registar_dispensa(v_pr, v_far, v_hoje - 238, 30, v_id);
  cons(v_p2, v_hoje - 100, 'SEGUIMENTO', 68, 3, v_hoje - 70, v_c);
  exame(v_p2, v_cv, v_c, v_hoje - 100, 5200);
  prc_prescrever_regime(v_c, v_r2, v_hoje - 100, 'FALENCIA_TERAPEUTICA', v_pr);
  prc_registar_dispensa(v_pr, v_far, v_hoje - 45, 30, v_id);

  teste(v_p3, v_hoje - 30, 'DIAGNOSTICO', 'REACTIVO');
  cons(v_p3, v_hoje - 28, 'INICIAL', 58, 2, v_hoje + 32, v_c);
  exame(v_p3, v_cd4, v_c, v_hoje - 28, 420);
  prc_prescrever_regime(v_c, v_r1, v_hoje - 28, 'INICIO', v_pr);
  prc_registar_dispensa(v_pr, v_far, v_hoje - 28, 60, v_id);

  teste(v_p4, v_hoje - 200, 'DIAGNOSTICO', 'REACTIVO');
  cons(v_p4, v_hoje - 198, 'INICIAL', 74, 2, v_hoje - 168, v_c);
  prc_prescrever_regime(v_c, v_r1, v_hoje - 198, 'INICIO', v_pr);
  prc_registar_dispensa(v_pr, v_far, v_hoje - 150, 30, v_id);
  prc_registar_busca(v_p4, v_hoje - 120, v_hoje - 115, 'TELEFONE',
                     'Esperanca Tembe', 'NAO_LOCALIZADO');

  teste(v_p5, v_hoje - 60, 'DIAGNOSTICO', 'REACTIVO');
  cons(v_p5, v_hoje - 58, 'INICIAL', 55, 1, v_hoje - 28, v_c);
  prc_prescrever_regime(v_c, v_r1, v_hoje - 58, 'INICIO', v_pr);
  prc_registar_dispensa(v_pr, v_far, v_hoje - 40, 30, v_id);

  teste(v_p6, v_hoje - 5, 'DIAGNOSTICO', 'NAO_REACTIVO');

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Dados de teste inseridos com sucesso.');
END;
/
