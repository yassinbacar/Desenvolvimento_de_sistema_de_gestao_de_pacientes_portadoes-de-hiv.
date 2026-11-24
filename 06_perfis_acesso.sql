CREATE OR REPLACE VIEW vw_paciente_basico AS
SELECT id_paciente, nid, nome_completo, sexo, data_nascimento, estado_paciente
  FROM paciente;

GRANT SELECT, INSERT, UPDATE ON paciente           TO rl_medico;
GRANT SELECT, INSERT, UPDATE ON teste_hiv          TO rl_medico;
GRANT SELECT, INSERT, UPDATE ON consulta           TO rl_medico;
GRANT SELECT, INSERT, UPDATE ON prescricao         TO rl_medico;
GRANT SELECT ON exame_laboratorial                 TO rl_medico;
GRANT SELECT ON tipo_exame                         TO rl_medico;
GRANT SELECT ON regime_tarv                        TO rl_medico;
GRANT SELECT ON medicamento                        TO rl_medico;
GRANT SELECT ON composicao_regime                  TO rl_medico;
GRANT SELECT ON dispensa                           TO rl_medico;
GRANT SELECT ON busca_activa                       TO rl_medico;
GRANT SELECT ON vw_faltosos                        TO rl_medico;
GRANT SELECT ON vw_ultima_carga_viral              TO rl_medico;
GRANT EXECUTE ON prc_registar_paciente             TO rl_medico;
GRANT EXECUTE ON prc_registar_teste                TO rl_medico;
GRANT EXECUTE ON prc_prescrever_regime             TO rl_medico;

GRANT SELECT ON vw_paciente_basico                 TO rl_laboratorio;
GRANT SELECT ON tipo_exame                         TO rl_laboratorio;
GRANT SELECT, INSERT, UPDATE ON exame_laboratorial TO rl_laboratorio;

GRANT SELECT ON vw_paciente_basico                 TO rl_farmacia;
GRANT SELECT ON prescricao                         TO rl_farmacia;
GRANT SELECT ON regime_tarv                        TO rl_farmacia;
GRANT SELECT ON medicamento                        TO rl_farmacia;
GRANT SELECT ON composicao_regime                  TO rl_farmacia;
GRANT SELECT ON dispensa                           TO rl_farmacia;
GRANT SELECT ON vw_faltosos                        TO rl_farmacia;
GRANT EXECUTE ON prc_registar_dispensa             TO rl_farmacia;

GRANT SELECT, INSERT, UPDATE ON profissional_saude TO rl_administrador;
GRANT SELECT, INSERT, UPDATE ON tipo_exame         TO rl_administrador;
GRANT SELECT, INSERT, UPDATE ON regime_tarv        TO rl_administrador;
GRANT SELECT, INSERT, UPDATE ON medicamento        TO rl_administrador;
GRANT SELECT, INSERT, UPDATE ON composicao_regime  TO rl_administrador;
GRANT SELECT ON paciente                           TO rl_administrador;
GRANT SELECT ON busca_activa                       TO rl_administrador;
GRANT SELECT ON vw_faltosos                        TO rl_administrador;
GRANT EXECUTE ON prc_registar_busca                TO rl_administrador;
GRANT EXECUTE ON prc_actualizar_abandonos          TO rl_administrador;
