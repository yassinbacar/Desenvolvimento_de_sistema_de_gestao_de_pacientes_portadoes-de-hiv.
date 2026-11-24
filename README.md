# Base de Dados de Seguimento de Pacientes com HIV - Machava (Oracle FREEPDB1)

Projecto de Administracao de Bases de Dados. Modelo relacional em Oracle Database
Free (PDB `FREEPDB1`) para registo de pacientes, testes de HIV, consultas, exames
laboratoriais, regimes TARV, prescricoes, dispensas e busca activa de faltosos.

> **Todos os dados sao ficticios.** Nao ha dados reais de pacientes neste repositorio.

## Membros do grupo
| Nome | N.o de estudante |
|------|------------------|
| _preencher_ | _preencher_ |

## Requisitos
- Oracle Database Free 23ai (ou Oracle 12c+ — usa `DEFAULT ON NULL seq.NEXTVAL`)
- SQL*Plus ou SQLcl
- Utilizador `SYSTEM` (ou outro DBA) com acesso a `FREEPDB1`

## Instalacao (um comando)
```bash
cd sql
sqlplus system@//localhost:1521/FREEPDB1 @install.sql
```
O instalador pede a palavra-passe do novo utilizador `HIV_MACHAVA` (nao esta no
codigo), cria tablespaces, utilizador e papeis, liga-se como `HIV_MACHAVA` e executa
todos os ficheiros por ordem. O registo fica em `docs/evidencias/install.log`.
Evite o caracter `&` na palavra-passe.

Para recomecar do zero: `@99_drop_all.sql` como `SYSTEM`.

## Estrutura
| Ficheiro | Executa como | Conteudo |
|---|---|---|
| `01_admin_setup.sql` | SYSTEM | tablespaces, utilizador, papeis (RN18) |
| `02_sequencias_tabelas.sql` | HIV_MACHAVA | 11 sequencias, 12 tabelas, restricoes, comentarios |
| `03_indices.sql` | HIV_MACHAVA | indices em FK e pesquisas frequentes |
| `04_triggers.sql` | HIV_MACHAVA | regras RN02, RN12, RN15, RN17, RN19, RN20 |
| `05_plsql.sql` | HIV_MACHAVA | funcao, vistas e procedimentos |
| `06_perfis_acesso.sql` | HIV_MACHAVA | privilegios minimos por papel |
| `07_dados_teste.sql` | HIV_MACHAVA | dados ficticios |
| `08_testes_integridade.sql` | HIV_MACHAVA | 12 testes (I01-I12) de regras de negocio |
| `09_contagens.sql` | HIV_MACHAVA | contagem por tabela (backup/recovery) |
| `10_evidencias.sql` | HIV_MACHAVA | consultas para as capturas de ecra |
| `99_drop_all.sql` | SYSTEM | remove tudo |

## Resultados esperados
- Tabelas 12 (P=12, R=15, U=5); sequencias 11; triggers 12; procedimentos 6; funcao 1; vistas 3 (todos `VALID`)
- Contagens: PACIENTE 6, PROFISSIONAL_SAUDE 5, TESTE_HIV 6, CONSULTA 7, TIPO_EXAME 3,
  EXAME_LABORATORIAL 7, REGIME_TARV 2, MEDICAMENTO 5, COMPOSICAO_REGIME 6,
  PRESCRICAO 6, DISPENSA 7, BUSCA_ACTIVA 1
- Testes I01-I09 imprimem `OK -> <mensagem de erro esperada>`; I10 indica 1 paciente
  passado a ABANDONO (NID-0004)

## Publicar no GitHub
```bash
git init
git add .
git commit -m "Projecto HIV Machava - Oracle FREEPDB1"
git branch -M main
git remote add origin https://github.com/<utilizador>/hiv-machava-oracle.git
git push -u origin main
```
Partilhe o link `https://github.com/<utilizador>/hiv-machava-oracle`.
