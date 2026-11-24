CREATE SEQUENCE seq_paciente     START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_profissional START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_teste        START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_consulta     START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_tipo_exame   START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_exame        START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_regime       START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_medicamento  START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_prescricao   START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_dispensa     START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_busca        START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE TABLE paciente (
  id_paciente         NUMBER(10)    DEFAULT ON NULL seq_paciente.NEXTVAL,
  nid                 VARCHAR2(20)  NOT NULL,
  nome_completo       VARCHAR2(120) NOT NULL,
  data_nascimento     DATE          NOT NULL,
  sexo                CHAR(1)       NOT NULL,
  contacto_telefonico VARCHAR2(20),
  bairro              VARCHAR2(60)  NOT NULL,
  endereco            VARCHAR2(150),
  data_registo        DATE          DEFAULT SYSDATE NOT NULL,
  estado_paciente     VARCHAR2(15)  DEFAULT 'ACTIVO' NOT NULL,
  CONSTRAINT pk_paciente PRIMARY KEY (id_paciente)
    USING INDEX TABLESPACE ts_hiv_idx,
  CONSTRAINT uk_paciente_nid UNIQUE (nid)
    USING INDEX TABLESPACE ts_hiv_idx,
  CONSTRAINT ck_paciente_sexo CHECK (sexo IN ('M','F')),
  CONSTRAINT ck_paciente_estado CHECK
    (estado_paciente IN ('ACTIVO', 'ABANDONO', 'TRANSFERIDO', 'OBITO'))
) TABLESPACE ts_hiv_dados;

CREATE TABLE profissional_saude (
  id_profissional NUMBER(6)     DEFAULT ON NULL seq_profissional.NEXTVAL,
  nome_completo   VARCHAR2(120) NOT NULL,
  categoria       VARCHAR2(20)  NOT NULL,
  num_registo     VARCHAR2(20)  NOT NULL,
  contacto        VARCHAR2(20),
  activo          CHAR(1)       DEFAULT 'S' NOT NULL,
  CONSTRAINT pk_profissional PRIMARY KEY (id_profissional)
    USING INDEX TABLESPACE ts_hiv_idx,
  CONSTRAINT uk_profissional_registo UNIQUE (num_registo)
    USING INDEX TABLESPACE ts_hiv_idx,
  CONSTRAINT ck_profissional_categoria CHECK (categoria IN
    ('MEDICO', 'ENFERMEIRO', 'TECNICO_MEDICINA', 'TECNICO_LABORATORIO',
     'FARMACEUTICO', 'CONSELHEIRO')),
  CONSTRAINT ck_profissional_activo CHECK (activo IN ('S','N'))
) TABLESPACE ts_hiv_dados;

CREATE TABLE tipo_exame (
  id_tipo_exame  NUMBER(4)    DEFAULT ON NULL seq_tipo_exame.NEXTVAL,
  designacao     VARCHAR2(80) NOT NULL,
  unidade_medida VARCHAR2(20),
  CONSTRAINT pk_tipo_exame PRIMARY KEY (id_tipo_exame)
    USING INDEX TABLESPACE ts_hiv_idx,
  CONSTRAINT uk_tipo_exame_designacao UNIQUE (designacao)
    USING INDEX TABLESPACE ts_hiv_idx
) TABLESPACE ts_hiv_dados;

CREATE TABLE regime_tarv (
  id_regime        NUMBER(4)    DEFAULT ON NULL seq_regime.NEXTVAL,
  codigo           VARCHAR2(30) NOT NULL,
  descricao        VARCHAR2(150),
  linha_tratamento NUMBER(1)    NOT NULL,
  CONSTRAINT pk_regime PRIMARY KEY (id_regime)
    USING INDEX TABLESPACE ts_hiv_idx,
  CONSTRAINT uk_regime_codigo UNIQUE (codigo)
    USING INDEX TABLESPACE ts_hiv_idx,
  CONSTRAINT ck_regime_linha CHECK (linha_tratamento IN (1,2,3))
) TABLESPACE ts_hiv_dados;

CREATE TABLE medicamento (
  id_medicamento     NUMBER(5)    DEFAULT ON NULL seq_medicamento.NEXTVAL,
  nome_generico      VARCHAR2(80) NOT NULL,
  dosagem            VARCHAR2(30) NOT NULL,
  forma_farmaceutica VARCHAR2(30),
  CONSTRAINT pk_medicamento PRIMARY KEY (id_medicamento)
    USING INDEX TABLESPACE ts_hiv_idx,
  CONSTRAINT uk_medicamento UNIQUE (nome_generico, dosagem)
    USING INDEX TABLESPACE ts_hiv_idx
) TABLESPACE ts_hiv_dados;

CREATE TABLE teste_hiv (
  id_teste        NUMBER(10)   DEFAULT ON NULL seq_teste.NEXTVAL,
  id_paciente     NUMBER(10)   NOT NULL,
  id_profissional NUMBER(6)    NOT NULL,
  data_teste      DATE         NOT NULL,
  tipo_teste      VARCHAR2(15) NOT NULL,
  resultado       VARCHAR2(15) NOT NULL,
  CONSTRAINT pk_teste_hiv PRIMARY KEY (id_teste)
    USING INDEX TABLESPACE ts_hiv_idx,
  CONSTRAINT fk_teste_paciente FOREIGN KEY (id_paciente)
    REFERENCES paciente (id_paciente),
  CONSTRAINT fk_teste_profissional FOREIGN KEY (id_profissional)
    REFERENCES profissional_saude (id_profissional),
  CONSTRAINT ck_teste_tipo CHECK
    (tipo_teste IN ('DIAGNOSTICO', 'CONFIRMACAO', 'REPETICAO')),
  CONSTRAINT ck_teste_resultado CHECK
    (resultado IN ('REACTIVO', 'NAO_REACTIVO', 'INDETERMINADO'))
) TABLESPACE ts_hiv_dados;

CREATE TABLE consulta (
  id_consulta           NUMBER(10)    DEFAULT ON NULL seq_consulta.NEXTVAL,
  id_paciente           NUMBER(10)    NOT NULL,
  id_profissional       NUMBER(6)     NOT NULL,
  data_consulta         DATE          NOT NULL,
  tipo_consulta         VARCHAR2(15)  NOT NULL,
  peso_kg               NUMBER(5,2),
  estadio_oms           NUMBER(1),
  observacoes           VARCHAR2(500),
  data_proxima_consulta DATE,
  CONSTRAINT pk_consulta PRIMARY KEY (id_consulta)
    USING INDEX TABLESPACE ts_hiv_idx,
  CONSTRAINT fk_consulta_paciente FOREIGN KEY (id_paciente)
    REFERENCES paciente (id_paciente),
  CONSTRAINT fk_consulta_profissional FOREIGN KEY (id_profissional)
    REFERENCES profissional_saude (id_profissional),
  CONSTRAINT ck_consulta_tipo CHECK
    (tipo_consulta IN ('INICIAL', 'SEGUIMENTO', 'URGENCIA')),
  CONSTRAINT ck_consulta_peso CHECK (peso_kg > 0),
  CONSTRAINT ck_consulta_estadio CHECK (estadio_oms BETWEEN 1 AND 4),
  CONSTRAINT ck_consulta_proxima CHECK
    (data_proxima_consulta IS NULL OR data_proxima_consulta >= data_consulta)
) TABLESPACE ts_hiv_dados;

CREATE TABLE exame_laboratorial (
  id_exame        NUMBER(10)    DEFAULT ON NULL seq_exame.NEXTVAL,
  id_paciente     NUMBER(10)    NOT NULL,
  id_tipo_exame   NUMBER(4)     NOT NULL,
  id_consulta     NUMBER(10),
  id_profissional NUMBER(6)     NOT NULL,
  data_colheita   DATE          NOT NULL,
  data_resultado  DATE,
  valor_resultado NUMBER(12,2),
  CONSTRAINT pk_exame PRIMARY KEY (id_exame)
    USING INDEX TABLESPACE ts_hiv_idx,
  CONSTRAINT fk_exame_paciente FOREIGN KEY (id_paciente)
    REFERENCES paciente (id_paciente),
  CONSTRAINT fk_exame_tipo FOREIGN KEY (id_tipo_exame)
    REFERENCES tipo_exame (id_tipo_exame),
  CONSTRAINT fk_exame_consulta FOREIGN KEY (id_consulta)
    REFERENCES consulta (id_consulta),
  CONSTRAINT fk_exame_profissional FOREIGN KEY (id_profissional)
    REFERENCES profissional_saude (id_profissional),
  CONSTRAINT ck_exame_datas CHECK
    (data_resultado IS NULL OR data_resultado >= data_colheita),
  CONSTRAINT ck_exame_valor CHECK (valor_resultado >= 0)
) TABLESPACE ts_hiv_dados;

CREATE TABLE composicao_regime (
  id_regime      NUMBER(4)    NOT NULL,
  id_medicamento NUMBER(5)    NOT NULL,
  posologia      VARCHAR2(60) NOT NULL,
  CONSTRAINT pk_composicao PRIMARY KEY (id_regime, id_medicamento)
    USING INDEX TABLESPACE ts_hiv_idx,
  CONSTRAINT fk_composicao_regime FOREIGN KEY (id_regime)
    REFERENCES regime_tarv (id_regime),
  CONSTRAINT fk_composicao_medicamento FOREIGN KEY (id_medicamento)
    REFERENCES medicamento (id_medicamento)
) TABLESPACE ts_hiv_dados;

CREATE TABLE prescricao (
  id_prescricao NUMBER(10)   DEFAULT ON NULL seq_prescricao.NEXTVAL,
  id_consulta   NUMBER(10)   NOT NULL,
  id_regime     NUMBER(4)    NOT NULL,
  data_inicio   DATE         NOT NULL,
  data_fim      DATE,
  motivo        VARCHAR2(25) DEFAULT 'INICIO' NOT NULL,
  CONSTRAINT pk_prescricao PRIMARY KEY (id_prescricao)
    USING INDEX TABLESPACE ts_hiv_idx,
  CONSTRAINT fk_prescricao_consulta FOREIGN KEY (id_consulta)
    REFERENCES consulta (id_consulta),
  CONSTRAINT fk_prescricao_regime FOREIGN KEY (id_regime)
    REFERENCES regime_tarv (id_regime),
  CONSTRAINT ck_prescricao_datas CHECK
    (data_fim IS NULL OR data_fim >= data_inicio),
  CONSTRAINT ck_prescricao_motivo CHECK (motivo IN
    ('INICIO', 'FALENCIA_TERAPEUTICA', 'TOXICIDADE', 'INTOLERANCIA',
     'RUPTURA_STOCK', 'OUTRO'))
) TABLESPACE ts_hiv_dados;

CREATE TABLE dispensa (
  id_dispensa               NUMBER(10) DEFAULT ON NULL seq_dispensa.NEXTVAL,
  id_prescricao             NUMBER(10) NOT NULL,
  id_profissional           NUMBER(6)  NOT NULL,
  data_dispensa             DATE       NOT NULL,
  quantidade_dias           NUMBER(3)  NOT NULL,
  data_proximo_levantamento DATE       NOT NULL,
  CONSTRAINT pk_dispensa PRIMARY KEY (id_dispensa)
    USING INDEX TABLESPACE ts_hiv_idx,
  CONSTRAINT fk_dispensa_prescricao FOREIGN KEY (id_prescricao)
    REFERENCES prescricao (id_prescricao),
  CONSTRAINT fk_dispensa_profissional FOREIGN KEY (id_profissional)
    REFERENCES profissional_saude (id_profissional),
  CONSTRAINT ck_dispensa_dias CHECK (quantidade_dias > 0),
  CONSTRAINT ck_dispensa_proximo CHECK
    (data_proximo_levantamento > data_dispensa)
) TABLESPACE ts_hiv_dados;

CREATE TABLE busca_activa (
  id_busca           NUMBER(10)   DEFAULT ON NULL seq_busca.NEXTVAL,
  id_paciente        NUMBER(10)   NOT NULL,
  data_falta         DATE         NOT NULL,
  data_contacto      DATE         NOT NULL,
  meio_contacto      VARCHAR2(20) NOT NULL,
  agente_responsavel VARCHAR2(100),
  resultado          VARCHAR2(20) NOT NULL,
  CONSTRAINT pk_busca PRIMARY KEY (id_busca)
    USING INDEX TABLESPACE ts_hiv_idx,
  CONSTRAINT fk_busca_paciente FOREIGN KEY (id_paciente)
    REFERENCES paciente (id_paciente),
  CONSTRAINT ck_busca_datas CHECK (data_contacto >= data_falta),
  CONSTRAINT ck_busca_meio CHECK
    (meio_contacto IN ('TELEFONE', 'VISITA_DOMICILIAR', 'SMS')),
  CONSTRAINT ck_busca_resultado CHECK (resultado IN
    ('REGRESSOU', 'TRANSFERIDO', 'OBITO', 'NAO_LOCALIZADO', 'RECUSOU'))
) TABLESPACE ts_hiv_dados;

COMMENT ON TABLE paciente IS 'Utente registado no servico de HIV (RN01-RN04)';
COMMENT ON TABLE profissional_saude IS 'Profissionais de saude (RN06)';
COMMENT ON TABLE teste_hiv IS 'Testes de HIV realizados (RN05)';
COMMENT ON TABLE consulta IS 'Consultas clinicas (RN07, RN08)';
COMMENT ON TABLE tipo_exame IS 'Catalogo de tipos de exame (RN09)';
COMMENT ON TABLE exame_laboratorial IS 'Exames e resultados (RN09, RN10)';
COMMENT ON TABLE regime_tarv IS 'Regimes de tratamento antirretroviral (RN11)';
COMMENT ON TABLE medicamento IS 'Medicamentos antirretrovirais (RN11)';
COMMENT ON TABLE composicao_regime IS 'Medicamentos de cada regime (RN11)';
COMMENT ON TABLE prescricao IS 'Prescricao de regimes (RN12, RN13)';
COMMENT ON TABLE dispensa IS 'Levantamentos na farmacia (RN14, RN15)';
COMMENT ON TABLE busca_activa IS 'Busca activa de faltosos (RN16, RN17)';
