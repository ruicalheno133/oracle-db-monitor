/*
 *
 * Script com as queries necessárias para 
 * obter os dados presentes na BD sys
 * 
 */

/* STATUS */

SELECT ((sysdate - i.startup_time ) * 24 * 60) AS "UPTIME",
       i.database_type,
       d.name AS "DATABASE_NAME",
       i.instance_name,
       c.name AS "CONTAINERS_NAME",
       d.platform_name,
       i.thread#,
       i.archiver
FROM V$instance i,
     V$database d,
     V$containers c;

/* TABLESPACES */

SELECT ts.tablespace_name,
       tv.TS#, 
       tsm.tablespace_size,
       tsm.tablespace_size - used_space AS "FREE_SPACE",
       tsm.used_percent,
       ts.max_size,
       ts.status,
       ts.contents,
       ts.segment_space_management
FROM DBA_TABLESPACES ts,
     DBA_TABLESPACE_USAGE_METRICS tsm,
     V$TABLESPACE tv
WHERE ts.tablespace_name = tsm.tablespace_name AND tv.name=ts.tablespace_name;

/* DATAFILES */

SELECT
      vdf.file#,
      df.file_name,
      vdf.TS#,
      df.status,
      df.bytes / 1024 AS "SIZE",
      df.maxbytes / 1024,
      df.autoextensible
FROM DBA_DATA_FILES df, v$datafile vdf
WHERE df.file_name = vdf."NAME";

/* SQL COMMANDS */

SELECT sql_id, sql_fulltext
FROM v$sql;

/* USERS */

SELECT user_id,
       username,
       account_status,
       expiry_date,
       default_tablespace,
       temporary_tablespace,
       profile,
       created,
       last_login
FROM dba_users;

/* ROLES */

SELECT role_id,
       role,
       authentication_type
FROM dba_roles;

/* CPU */

SELECT t1.VALUE AS NUM_CPUS, t2.value AS IDLE_TIME , t3.value AS BUSY_TIME, t4.value AS IOWAIT_TIME, ((t3.value/(t3.value+t2.value))*100) AS USED_PERCENT
FROM V$OSSTAT t1, V$OSSTAT t2, V$OSSTAT t3, V$OSSTAT t4
WHERE t1.STAT_NAME = 'NUM_CPUS' AND t2.STAT_NAME = 'IDLE_TIME' AND t3.STAT_NAME='BUSY_TIME' AND t4.STAT_NAME='IOWAIT_TIME';
