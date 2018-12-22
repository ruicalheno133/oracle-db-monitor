/* 
 * Script de criação dos tablespaces,
 * datafiles e users.
 */

CREATE TABLESPACE manager_table
DATAFILE  '\u01\app\oracle\oradata\orcl12\orcl\manager_tables_01.dbf'
SIZE 100M;

CREATE TEMPORARY TABLESPACE manager_temp
TEMPFILE '\u01\app\oracle\oradata\orcl12\orcl\manager_temp.dbf'
SIZE 100M
AUTOEXTEND ON;

CREATE USER manager
IDENTIFIED BY pass
DEFAULT TABLESPACE manager_table
TEMPORARY TABLESPACE manager_temp;

GRANT CONNECT TO manager;

GRANT ALL PRIVILEGES TO manager;

ALTER USER manager quota unlimited on manager_table;