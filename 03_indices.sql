CREATE INDEX ix_paciente_nome
  ON paciente (UPPER(nome_completo))
  TABLESPACE ts_hiv_idx;
CREATE INDEX ix_paciente_estado
  ON paciente (estado_paciente)
  TABLESPACE ts_hiv_idx;

CREATE INDEX ix_teste_paciente
  ON teste_hiv (id_paciente, resultado)
  TABLESPACE ts_hiv_idx;
CREATE INDEX ix_teste_prof
  ON teste_hiv (id_profissional)
  TABLESPACE ts_hiv_idx;

CREATE INDEX ix_consulta_pac_data
  ON consulta (id_paciente, data_consulta)
  TABLESPACE ts_hiv_idx;
CREATE INDEX ix_consulta_prof
  ON consulta (id_profissional)
  TABLESPACE ts_hiv_idx;

CREATE INDEX ix_exame_pac_tipo
  ON exame_laboratorial (id_paciente, id_tipo_exame, data_colheita)
  TABLESPACE ts_hiv_idx;
CREATE INDEX ix_exame_consulta
  ON exame_laboratorial (id_consulta)
  TABLESPACE ts_hiv_idx;
CREATE INDEX ix_exame_prof
  ON exame_laboratorial (id_profissional)
  TABLESPACE ts_hiv_idx;

CREATE INDEX ix_composicao_med
  ON composicao_regime (id_medicamento)
  TABLESPACE ts_hiv_idx;

CREATE INDEX ix_prescricao_cons
  ON prescricao (id_consulta)
  TABLESPACE ts_hiv_idx;
CREATE INDEX ix_prescricao_regime
  ON prescricao (id_regime)
  TABLESPACE ts_hiv_idx;

CREATE INDEX ix_dispensa_presc
  ON dispensa (id_prescricao)
  TABLESPACE ts_hiv_idx;
CREATE INDEX ix_dispensa_prof
  ON dispensa (id_profissional)
  TABLESPACE ts_hiv_idx;
CREATE INDEX ix_dispensa_proximo
  ON dispensa (data_proximo_levantamento)
  TABLESPACE ts_hiv_idx;

CREATE INDEX ix_busca_paciente
  ON busca_activa (id_paciente, data_falta)
  TABLESPACE ts_hiv_idx;
