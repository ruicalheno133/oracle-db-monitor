/* 
 * 
 * Script de criação da BD Manager
 * 
 */
 
set escape on;

/* TABLES */

CREATE TABLE STATUS (
      STATUS_KEY NUMBER NOT NULL,
      UPTIME NUMBER NOT NULL,
      DATABASE_TYPE VARCHAR2(15) NOT NULL,
      DATABASE_NAME VARCHAR2(9) NOT NULL,
      INSTANCE_NAME VARCHAR2(16) NOT NULL,
      CONTAINERS_NAME VARCHAR2(30) NOT NULL,
      PLATFORM_NAME VARCHAR2(101) NOT NULL,
      THREAD# NUMBER NOT NULL,
      ARCHIVER VARCHAR2(7) NOT NULL,
      TSTAMP TIMESTAMP NOT NULL,
      UPDATE_ID NUMBER NOT NULL,
      CONSTRAINT pk_status_key PRIMARY KEY (STATUS_KEY),
      CONSTRAINT database_type_value CHECK (DATABASE_TYPE IN ('RAC', 'RACONENODE', 'SINGLE', 'UNKNOWN')),
      CONSTRAINT archiver_value CHECK (ARCHIVER IN ('STOPPED', 'STARTED', 'FAILED'))
);

CREATE TABLE "TABLESPACE" (
      TABLESPACE_KEY NUMBER NOT NULL,
      TABLESPACE_ID NUMBER NOT NULL,
      TABLESPACE_NAME VARCHAR2(30) NOT NULL,
      TABLESPACE_SIZE NUMBER,
      FREE_SPACE NUMBER,
      USED_PERCENT NUMBER,
      MAX_SIZE NUMBER NOT NULL,
      STATUS VARCHAR2(9) NOT NULL,
      CONTENTS VARCHAR2(9) NOT NULL,
      SEGMENT_SPACE_MANAGEMENT VARCHAR2(6) NOT NULL,
      TSTAMP TIMESTAMP NOT NULL,
      UPDATE_ID NUMBER NOT NULL,
      CONSTRAINT pk_tablespace_key PRIMARY KEY (TABLESPACE_KEY),
      CONSTRAINT status_value CHECK (STATUS IN ('ONLINE', 'OFFLINE', 'READ ONLY')),
      CONSTRAINT contents_value CHECK (CONTENTS IN ('UNDO', 'PERMANENT', 'TEMPORARY')),
      CONSTRAINT seg_space_mang_value CHECK (SEGMENT_SPACE_MANAGEMENT IN ('MANUAL', 'AUTO'))
);

CREATE TABLE DATAFILE (
  DATAFILE_KEY NUMBER NOT NULL,
  DATAFILE_ID NUMBER NOT NULL,
  TABLESPACE_KEY NUMBER NOT NULL,
  DATAFILE_NAME VARCHAR2(513) NOT NULL,
  STATUS VARCHAR2(9) NOT NULL,
  "SIZE" NUMBER NOT NULL,
  MAX_SIZE NUMBER NOT NULL,
  AUTO_EXTENSIBLE VARCHAR2(3) NOT NULL,
  TSTAMP TIMESTAMP NOT NULL,
  UPDATE_ID NUMBER NOT NULL,
  CONSTRAINT pk_datafile_key PRIMARY KEY (DATAFILE_KEY),
  CONSTRAINT fk_datafile_tablespace FOREIGN KEY (TABLESPACE_KEY) REFERENCES "TABLESPACE" (TABLESPACE_KEY),
  CONSTRAINT datafile_status_value CHECK (STATUS IN ('AVAILABLE', 'INVALID')),
  CONSTRAINT datafile_auto_ext_value CHECK (AUTO_EXTENSIBLE IN ('YES', 'NO'))
);

CREATE TABLE "USER"(
      USER_KEY NUMBER NOT NULL,
      USER_ID NUMBER NOT NULL,
      USERNAME VARCHAR2(128) NOT NULL,
      ACCOUNT_STATUS VARCHAR2(32) NOT NULL,
      EXPIRY_DATE DATE,
      DEFAULT_TABLESPACE VARCHAR2(30) NOT NULL,
      TEMPORARY_TABLESPACE VARCHAR2(30) NOT NULL,
      PROFILE VARCHAR2(128) NOT NULL,
      CREATED DATE,
      LAST_LOGIN TIMESTAMP(9) WITH TIME ZONE,
      TSTAMP TIMESTAMP NOT NULL,
      UPDATE_ID NUMBER NOT NULL,
      CONSTRAINT pk_user_key PRIMARY KEY (USER_KEY),
      CONSTRAINT acc_status_value CHECK (ACCOUNT_STATUS IN ('OPEN', 'EXPIRED', 'EXPIRED(GRACE)', 'LOCKED(TIMED)', 'LOCKED', 'EXPIRED \& LOCKED(TIMED)', 'EXPIRED(GRACE) \& LOCKED(TIMED)', 'EXPIRED \& LOCKED', 'EXPIRED(GRACE) \& LOCKED'))
);

CREATE TABLE "SESSION"(
    SESSION_KEY NUMBER NOT NULL,
    USER_KEY NUMBER NOT NULL,
    SESSION_ID NUMBER NOT NULL,
    STATUS VARCHAR2(8) NOT NULL,
    TSTAMP TIMESTAMP NOT NULL,
    UPDATE_ID NUMBER NOT NULL,
    CONSTRAINT pk_session_key PRIMARY KEY (SESSION_KEY),
    CONSTRAINT fk_us_user FOREIGN KEY (USER_KEY) REFERENCES "USER" (USER_KEY),
    CONSTRAINT status_session_value CHECK (STATUS IN ('ACTIVE','INACTIVE','KILLED','CACHED','SNIPED'))
);

CREATE TABLE USER_TABLESPACE(
      USER_TABLESPACE_KEY NUMBER NOT NULL,
      USER_KEY NUMBER NOT NULL,
      TABLESPACE_KEY NUMBER NOT NULL,
      USED_QUOTA NUMBER NOT NULL,
      QUOTA NUMBER NOT NULL,
      TSTAMP TIMESTAMP NOT NULL,
      UPDATE_ID NUMBER NOT NULL,
      CONSTRAINT pk_user_tablespace_key PRIMARY KEY (USER_TABLESPACE_KEY),
      CONSTRAINT fk_ut_user FOREIGN KEY (USER_KEY) REFERENCES "USER" (USER_KEY),
      CONSTRAINT fk_ut_tablespace FOREIGN KEY (TABLESPACE_KEY) REFERENCES "TABLESPACE" (TABLESPACE_KEY)
);

CREATE TABLE ROLE(
      ROLE_KEY NUMBER NOT NULL,
      ROLE_ID NUMBER NOT NULL,
      ROLE VARCHAR2(128) NOT NULL,
      AUTHENTICATION_TYPE VARCHAR2(11) NOT NULL,
      TSTAMP TIMESTAMP NOT NULL,
      UPDATE_ID NUMBER NOT NULL,
      CONSTRAINT pk_role_key PRIMARY KEY (ROLE_KEY),
      CONSTRAINT aut_type_value CHECK (AUTHENTICATION_TYPE IN ('NONE', 'EXTERNAL', 'GLOBAL', 'APPLICATION', 'PASSWORD'))
);

CREATE TABLE USER_ROLE(
      USER_ROLE_KEY NUMBER NOT NULL,
      USER_KEY NUMBER NOT NULL,
      ROLE_KEY NUMBER NOT NULL,
      TSTAMP TIMESTAMP NOT NULL,
      UPDATE_ID NUMBER NOT NULL,
      CONSTRAINT pk_user_role_key PRIMARY KEY (USER_ROLE_KEY),
      CONSTRAINT fk_ur_user FOREIGN KEY (USER_KEY) REFERENCES "USER" (USER_KEY),
      CONSTRAINT fk_ur_role FOREIGN KEY (ROLE_KEY) REFERENCES ROLE (ROLE_KEY)
);

CREATE TABLE SQL_COMMANDS(
      SQL_COMMANDS_KEY NUMBER NOT NULL,
      SQL_ID VARCHAR2(13) NOT NULL,
      SQL_FULLTEXT CLOB NOT NULL,
      SCHEMA_NAME VARCHAR2(30) NOT NULL,
      TSTAMP TIMESTAMP NOT NULL,
      UPDATE_ID NUMBER NOT NULL,
      CONSTRAINT pk_sql_commands_key PRIMARY KEY (SQL_COMMANDS_KEY)
);

CREATE TABLE CPU(
      CPU_KEY NUMBER NOT NULL,
      NUM_CPUS NUMBER NOT NULL,
      IDLE_TIME NUMBER NOT NULL,
      BUSY_TIME NUMBER NOT NULL,
      IOWAIT_TIME NUMBER NOT NULL,
      USED_PERCENT NUMBER NOT NULL,
      TSTAMP TIMESTAMP NOT NULL,
      UPDATE_ID NUMBER NOT NULL,
      CONSTRAINT pk_cpu_key PRIMARY KEY (CPU_KEY)
);

CREATE TABLE MEMORY(
     MEM_KEY NUMBER NOT NULL,
     TOTAL_SIZE NUMBER NOT NULL,
     FREE_SPACE NUMBER NOT NULL,
     USED_SPACE NUMBER NOT NULL,
     USED_PERCENT NUMBER NOT NULL,
     TSTAMP TIMESTAMP NOT NULL,
     UPDATE_ID NUMBER NOT NULL,
     CONSTRAINT pk_mem_key PRIMARY KEY (MEM_KEY)
);


/* SEQUENCES */

CREATE SEQUENCE status_seq
      START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE tablespace_seq
      START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE datafile_seq
      START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE user_seq
      START WITH 1 INCREMENT BY 1;
      
CREATE SEQUENCE session_seq
      START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE user_tablespace_seq
      START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE role_seq
      START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE user_role_seq
      START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE sql_commands_seq
      START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE cpu_seq
      START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE memory_seq
      START WITH 1 INCREMENT BY 1;

/* TRIGGERS */

CREATE OR REPLACE TRIGGER inc_status
BEFORE INSERT ON STATUS
FOR EACH ROW
BEGIN 
  IF :NEW.STATUS_KEY IS NULL 
  THEN  
    :NEW.STATUS_KEY := status_seq.NEXTVAL;
    :NEW.TSTAMP := sysdate;
  END IF; 
END;
/

CREATE OR REPLACE TRIGGER inc_tablespace
BEFORE INSERT ON "TABLESPACE"
FOR EACH ROW
BEGIN 
  IF :NEW.TABLESPACE_KEY IS NULL 
  THEN  
    :NEW.TABLESPACE_KEY := tablespace_seq.NEXTVAL;
    :NEW.TSTAMP := sysdate;
  END IF; 
END;
/

CREATE OR REPLACE TRIGGER inc_datafile
BEFORE INSERT ON DATAFILE
FOR EACH ROW
BEGIN 
  IF :NEW.DATAFILE_KEY IS NULL 
  THEN  
    :NEW.DATAFILE_KEY := datafile_seq.NEXTVAL;
    :NEW.TSTAMP := sysdate;
  END IF; 
END;
/

CREATE OR REPLACE TRIGGER inc_user
BEFORE INSERT ON "USER"
FOR EACH ROW
BEGIN 
  IF :NEW.USER_KEY IS NULL 
  THEN  
    :NEW.USER_KEY := user_seq.NEXTVAL;
    :NEW.TSTAMP := sysdate;
  END IF; 
END;
/

CREATE OR REPLACE TRIGGER inc_session
BEFORE INSERT ON "SESSION"
FOR EACH ROW
BEGIN
  IF :NEW.SESSION_KEY IS NULL
  THEN 
     :NEW.SESSION_KEY := session_seq.NEXTVAL;
     :NEW.TSTAMP := sysdate;
  END IF;
END;
/

CREATE OR REPLACE TRIGGER inc_user_tablespace
BEFORE INSERT ON USER_TABLESPACE
FOR EACH ROW
BEGIN 
  IF :NEW.USER_TABLESPACE_KEY IS NULL 
  THEN  
    :NEW.USER_TABLESPACE_KEY := user_tablespace_seq.NEXTVAL;
    :NEW.TSTAMP := sysdate;
  END IF; 
END;
/

CREATE OR REPLACE TRIGGER inc_role
BEFORE INSERT ON ROLE
FOR EACH ROW
BEGIN 
  IF :NEW.ROLE_KEY IS NULL 
  THEN  
    :NEW.ROLE_KEY := role_seq.NEXTVAL;
    :NEW.TSTAMP := sysdate;
  END IF; 
END;
/

CREATE OR REPLACE TRIGGER inc_user_role
BEFORE INSERT ON USER_ROLE
FOR EACH ROW
BEGIN 
  IF :NEW.USER_ROLE_KEY IS NULL 
  THEN  
    :NEW.USER_ROLE_KEY := user_role_seq.NEXTVAL;
    :NEW.TSTAMP := sysdate;
  END IF; 
END;
/

CREATE OR REPLACE TRIGGER inc_sql_commands
BEFORE INSERT ON SQL_COMMANDS
FOR EACH ROW
BEGIN 
  IF :NEW.SQL_COMMANDS_KEY IS NULL 
  THEN  
    :NEW.SQL_COMMANDS_KEY := sql_commands_seq.NEXTVAL;
    :NEW.TSTAMP := sysdate;
  END IF; 
END;
/

CREATE OR REPLACE TRIGGER inc_cpu
BEFORE INSERT ON CPU
FOR EACH ROW
BEGIN 
  IF :NEW.CPU_KEY IS NULL 
  THEN  
    :NEW.CPU_KEY := cpu_seq.NEXTVAL;
    :NEW.TSTAMP := sysdate;
  END IF; 
END;
/

CREATE OR REPLACE TRIGGER inc_memory
BEFORE INSERT ON MEMORY
FOR EACH ROW
BEGIN 
  IF :NEW.MEM_KEY IS NULL 
  THEN  
    :NEW.MEM_KEY := memory_seq.NEXTVAL;
    :NEW.TSTAMP := sysdate;
  END IF; 
END;
/

/* VIEWS */

CREATE OR REPLACE VIEW CUR_ROLE 
AS SELECT * FROM ROLE t WHERE t.UPDATE_ID = (SELECT MAX(UPDATE_ID) FROM ROLE);

CREATE OR REPLACE VIEW CUR_MEMORY
AS SELECT * FROM DATAFILE t WHERE t.UPDATE_ID = (SELECT MAX(UPDATE_ID) FROM DATAFILE);

CREATE OR REPLACE VIEW CUR_TABLESPACE  
AS SELECT * FROM "TABLESPACE" t WHERE t.UPDATE_ID = (SELECT MAX(UPDATE_ID) FROM "TABLESPACE");

CREATE OR REPLACE VIEW CUR_SIZE
AS SELECT SUM(TABLESPACE_SIZE) AS MAX_SIZE, SUM(FREE_SPACE) AS FREE_SPACE FROM CUR_TABLESPACE;


CREATE OR REPLACE  VIEW CUR_USER_ROLE 
AS SELECT * FROM USER_ROLE t WHERE t.UPDATE_ID = (SELECT MAX(UPDATE_ID) FROM USER_ROLE);

CREATE OR REPLACE VIEW CUR_USER_TABLESPACE 
AS SELECT * FROM USER_TABLESPACE t WHERE t.UPDATE_ID = (SELECT MAX(UPDATE_ID) FROM USER_TABLESPACE);

CREATE OR REPLACE VIEW CUR_USER  
AS SELECT * FROM "USER" t WHERE t.UPDATE_ID = (SELECT MAX(UPDATE_ID) FROM "USER");

CREATE OR REPLACE VIEW CUR_SESSION
AS SELECT * FROM "SESSION" us WHERE us.UPDATE_ID BETWEEN (SELECT MAX(UPDATE_ID) - 3 FROM "SESSION") AND (SELECT MAX(UPDATE_ID) FROM "SESSION");

CREATE OR REPLACE VIEW CUR_OPEN_SESSIONS
AS SELECT COUNT(DISTINCT(USER_KEY)) AS SESSIONS, TSTAMP FROM CUR_SESSION GROUP BY TSTAMP FETCH FIRST 10 ROWS ONLY;

CREATE OR REPLACE VIEW CUR_DATAFILE
AS SELECT d.*, t.tablespace_name FROM DATAFILE d 
INNER JOIN CUR_TABLESPACE t ON t.tablespace_key = d.tablespace_key
WHERE d.UPDATE_ID = (SELECT MAX(UPDATE_ID) FROM DATAFILE);

CREATE OR REPLACE VIEW CUR_MEMORY
AS SELECT * FROM MEMORY ORDER BY MEM_KEY DESC FETCH FIRST 1 ROWS ONLY;

CREATE OR REPLACE VIEW CUR_CPU
AS SELECT * FROM CPU ORDER BY CPU_KEY DESC FETCH FIRST 1 ROWS ONLY;

CREATE OR REPLACE VIEW CUR_STATUS
AS SELECT * FROM STATUS ORDER BY STATUS_KEY DESC FETCH FIRST 1 ROWS ONLY;

CREATE OR REPLACE VIEW CUR_SQL_COMMANDS
AS SELECT * FROM SQL_COMMANDS ORDER BY SQL_COMMANDS_KEY DESC;

CREATE OR REPLACE VIEW  CUR_JOIN_TABLESPACE_DATAFILE
AS SELECT d.datafile_id, t.tablespace_id, d.datafile_name, d."SIZE", d.max_size
FROM cur_datafile d, cur_tablespace t 
WHERE d.tablespace_key = t.tablespace_key;

CREATE OR REPLACE VIEW  CUR_JOIN_USER_ROLE
AS SELECT u.user_id, r.role_id, r.role, u.username
FROM cur_user u, cur_role r, cur_user_role cur
WHERE cur.user_key = u.user_key AND cur.role_key = r.role_key;

CREATE OR REPLACE VIEW  CUR_JOIN_USER_TABLESPACE
AS SELECT cut.used_quota, cut.quota, u.user_id, u.username, t.tablespace_id, t.tablespace_name
FROM cur_user u, cur_tablespace t, cur_user_tablespace cut
WHERE cut.user_key = u.user_key AND cut.tablespace_key = t.tablespace_key;

/* Triggers - Join */

CREATE OR REPLACE TRIGGER join_user_session
BEFORE INSERT ON "SESSION"
FOR EACH ROW
DECLARE
    uk NUMBER;
BEGIN
    SELECT cu.USER_KEY INTO uk FROM CUR_USER cu WHERE cu.USER_ID = :NEW.USER_KEY;
    :NEW.USER_KEY := uk;
END;
/

CREATE OR REPLACE TRIGGER join_user_tablespace   
BEFORE INSERT ON USER_TABLESPACE
FOR EACH ROW
DECLARE 
    uk NUMBER;
    tk NUMBER;
BEGIN 
  SELECT cu.USER_KEY INTO uk FROM CUR_USER cu WHERE cu.USER_ID = :NEW.USER_KEY;
  SELECT ct.TABLESPACE_KEY INTO tk FROM CUR_TABLESPACE ct WHERE ct.TABLESPACE_ID = :NEW.TABLESPACE_KEY;
  :NEW.USER_KEY := uk;
  :NEW.TABLESPACE_KEY := tk;
END;
/

CREATE OR REPLACE TRIGGER join_user_role   
BEFORE INSERT ON USER_ROLE
FOR EACH ROW
DECLARE 
    uk NUMBER;
    rk NUMBER;
BEGIN 
  SELECT cu.USER_KEY INTO uk FROM CUR_USER cu WHERE cu.USER_ID = :NEW.USER_KEY;
  SELECT ct.ROLE_KEY INTO rk FROM CUR_ROLE ct WHERE ct.ROLE_ID = :NEW.ROLE_KEY;
  :NEW.USER_KEY := uk;
  :NEW.ROLE_KEY := rk;
END;
/

CREATE OR REPLACE TRIGGER join_user_role   
BEFORE INSERT ON USER_ROLE
FOR EACH ROW
DECLARE 
    uk NUMBER;
    rk NUMBER;
BEGIN 
  SELECT cu.USER_KEY INTO uk FROM CUR_USER cu WHERE cu.USER_ID = :NEW.USER_KEY;
  SELECT ct.ROLE_KEY INTO rk FROM CUR_ROLE ct WHERE ct.ROLE_ID = :NEW.ROLE_KEY;
  :NEW.USER_KEY := uk;
  :NEW.ROLE_KEY := rk;
END; 
/

CREATE OR REPLACE TRIGGER join_datafile_tablespace
BEFORE INSERT ON DATAFILE
FOR EACH ROW
DECLARE 
    tk NUMBER;
BEGIN 
  SELECT t.TABLESPACE_KEY INTO tk FROM CUR_TABLESPACE t WHERE t.TABLESPACE_ID = :NEW.TABLESPACE_KEY;
  :NEW.TABLESPACE_KEY := tk;
END; 
/

/* ENABLE REST SERVICES */

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'MANAGER',
                       p_object => 'CUR_ROLE',
                       p_object_type => 'VIEW',
                       p_object_alias => 'cur_role',
                       p_auto_rest_auth => FALSE);
    commit;
END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'MANAGER',
                       p_object => 'CUR_MEMORY',
                       p_object_type => 'VIEW',
                       p_object_alias => 'cur_memory',
                       p_auto_rest_auth => FALSE);
    commit;
END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'MANAGER',
                       p_object => 'CUR_CPU',
                       p_object_type => 'VIEW',
                       p_object_alias => 'cur_cpu',
                       p_auto_rest_auth => FALSE);
    commit;
END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'MANAGER',
                       p_object => 'CUR_DATAFILE',
                       p_object_type => 'VIEW',
                       p_object_alias => 'cur_datafile',
                       p_auto_rest_auth => FALSE);
    commit;
END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'MANAGER',
                       p_object => 'CUR_STATUS',
                       p_object_type => 'VIEW',
                       p_object_alias => 'cur_status',
                       p_auto_rest_auth => FALSE);
    commit;
END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'MANAGER',
                       p_object => 'CUR_TABLESPACE',
                       p_object_type => 'VIEW',
                       p_object_alias => 'cur_tablespace',
                       p_auto_rest_auth => FALSE);
    commit;
END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'MANAGER',
                       p_object => 'CUR_USER',
                       p_object_type => 'VIEW',
                       p_object_alias => 'cur_user',
                       p_auto_rest_auth => FALSE);
    commit;
END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'MANAGER',
                       p_object => 'CUR_USER_ROLE',
                       p_object_type => 'VIEW',
                       p_object_alias => 'cur_user_role',
                       p_auto_rest_auth => FALSE);
    commit;
END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'MANAGER',
                       p_object => 'CUR_USER_TABLESPACE',
                       p_object_type => 'VIEW',
                       p_object_alias => 'cur_user_tablespace',
                       p_auto_rest_auth => FALSE);
    commit;
END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'MANAGER',
                       p_object => 'CUR_JOIN_USER_TABLESPACE',
                       p_object_type => 'VIEW',
                       p_object_alias => 'cur_join_user_tablespace',
                       p_auto_rest_auth => FALSE);

    commit;

END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'MANAGER',
                       p_object => 'CUR_JOIN_USER_ROLE',
                       p_object_type => 'VIEW',
                       p_object_alias => 'cur_join_user_role',
                       p_auto_rest_auth => FALSE);

    commit;

END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'MANAGER',
                       p_object => 'CUR_JOIN_TABLESPACE_DATAFILE',
                       p_object_type => 'VIEW',
                       p_object_alias => 'cur_join_tablespace_datafile',
                       p_auto_rest_auth => FALSE);
    commit;
END;
/


DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'MANAGER',
                       p_object => 'CUR_SIZE',
                       p_object_type => 'VIEW',
                       p_object_alias => 'cur_size',
                       p_auto_rest_auth => FALSE);
    commit;
END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'MANAGER',
                       p_object => 'CUR_SESSION',
                       p_object_type => 'VIEW',
                       p_object_alias => 'cur_session',
                       p_auto_rest_auth => FALSE);
    commit;
END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'MANAGER',
                       p_object => 'CUR_OPEN_SESSIONS',
                       p_object_type => 'VIEW',
                       p_object_alias => 'cur_open_sessions',
                       p_auto_rest_auth => FALSE);
    commit;
END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'MANAGER',
                       p_object => 'CUR_SQL_COMMANDS',
                       p_object_type => 'VIEW',
                       p_object_alias => 'cur_sql_commands',
                       p_auto_rest_auth => FALSE);
    commit;
END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    ORDS.ENABLE_SCHEMA(p_enabled => TRUE,
                       p_schema => 'MANAGER',
                       p_url_mapping_type => 'BASE_PATH',
                       p_url_mapping_pattern => 'manager',
                       p_auto_rest_auth => FALSE);

    commit;

END;
/
