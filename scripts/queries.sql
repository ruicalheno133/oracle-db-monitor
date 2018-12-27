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

SELECT tv.TS#, 
	   ts.tablespace_name,
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

/* USER TABLESPACES */

SELECT t.ts#,
	   u.username, 
	   u.user_id, 
	   q.bytes,
	   q.max_bytes
FROM DBA_TS_QUOTAS q, 
	 DBA_USERS u
LEFT JOIN v$tablespace t
WHERE q.username = u.username 
  AND q.tablespace_name = t.name;

/* ROLES */

SELECT role_id,
       role,
       authentication_type
FROM dba_roles;

/* USER_ROLE */

SELECT u.user_id, 
	   r.ROLE_ID 
FROM DBA_ROLE_PRIVS ur, 
	 DBA_USERS u,
	 DBA_ROLES r
WHERE ur.grantee = u.username 
  	 AND ur.granted_role = r.role;

/* CPU */

SELECT t1.VALUE AS NUM_CPUS, t2.value AS IDLE_TIME , t3.value AS BUSY_TIME, t4.value AS IOWAIT_TIME, ((t3.value/(t3.value+t2.value))*100) AS USED_PERCENT
FROM V$OSSTAT t1, V$OSSTAT t2, V$OSSTAT t3, V$OSSTAT t4
WHERE t1.STAT_NAME = 'NUM_CPUS' AND t2.STAT_NAME = 'IDLE_TIME' AND t3.STAT_NAME='BUSY_TIME' AND t4.STAT_NAME='IOWAIT_TIME';

/* MEMORY */

select total.TOTAL_SIZE,
      free.FREE_SIZE,
      total.TOTAL_SIZE - free.FREE_SIZE USED,
      ((total.TOTAL_SIZE - free.FREE_SIZE) / total.TOTAL_SIZE) * 100 USED_PERCENT
FROM (select sum(value)/1024/1024 TOTAL_SIZE from v$sga) total, (select sum(bytes)/1024/1024 FREE_SIZE from v$sgastat where name like '%free memory%') free;

/* EASY DROPS */

drop table cpu; 
drop table memory;
drop table status;
drop table "TABLESPACE" cascade constraints;
drop table "ROLE" cascade constraints;
drop table "USER" cascade constraints;
drop table datafile;
drop table user_role;
drop table user_tablespace;
drop table sql_commands;

drop sequence cpu_seq;
drop sequence datafile_seq;
drop sequence user_seq;
drop sequence role_seq;
drop sequence tablespace_seq;
drop sequence datafile_seq;
drop sequence user_role_seq;
drop sequence sql_commands_seq;
drop sequence user_tablespace_seq;
drop sequence memory_seq;
drop sequence status_seq;
