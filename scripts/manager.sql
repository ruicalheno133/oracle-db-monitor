/* 
 * 
 * Script de criação da BD Manager
 * 
 */

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
      CONSTRAINT pk_status_key PRIMARY KEY (STATUS_KEY),
      CONSTRAINT database_type_value CHECK (DATABASE_TYPE IN ('RAC', 'RACONENODE', 'SINGLE', 'UNKNOWN')),
      CONSTRAINT archiver_value CHECK (ARCHIVER IN ('STOPPED', 'STARTED', 'FAILED'))
)

CREATE TABLE TABLESPACE (
      TABLESPACE_KEY NUMBER NOT NULL,
      TABLESPACE_ID NUMBER NOT NULL,
      TABLESPACE_NAME VARCHAR2(30) NOT NULL,
      TABLESPACE_SIZE NUMBER NOT NULL,
      FREE_SPACE NUMBER NOT NULL,
      USER_PERCENT NUMBER NOT NULL,
      MAX_SIZE NUMBER NOT NULL,
      STATUS VARCHAR2(9) NOT NULL,
      CONTENTS VARCHAR2(9) NOT NULL,
      TSTAMP TIMESTAMP NOT NULL,
      SEGMENT_SPACE_MANAGEMENT VARCHAR2(6) NOT NULL,
      CONSTRAINT pk_tablespace_key PRIMARY KEY (TABLESPACE_KEY),
      CONSTRAINT status_value CHECK (STATUS IN ('ONLINE', 'OFFLINE', 'READ ONLY')),
      CONSTRAINT contents_value CHECK (CONTENTS IN ('UNDO', 'PERMANENT', 'TEMPORARY'))
      CONSTRAINT seg_space_mang_value CHECK (SEGMENT_SPACE_MANAGEMENT IN ('MANUAL', 'AUTO'))
)

CREATE TABLE USER(
      USER_KEY NUMBER NOT NULL,
      USER_ID NUMBER NOT NULL,
      USERNAME VARCHAR2(128) NOT NULL,
      ACCOUNT_STATUS VARCHAR2(32) NOT NULL,
      EXPIRY_DATE DATE NOT NULL,
      DEFAULT_TABLESPACE VARCHAR2(30) NOT NULL,
      TEMPORARY_TABLESPACE VARCHAR2(30) NOT NULL,
      PROFILE VARCHAR2(128) NOT NULL,
      CREATED DATE NOT NULL,
      LAST_LOGIN TIMESTAMP(9) WITH TIME ZONE NOT NULL,
      TSTAMP TIMESTAMP NOT NULL,
      CONSTRAINT pk_user_key PRIMARY KEY (USER_KEY),
      CONSTRAINT acc_status_value CHECK (ACCOUNT_STATUS IN ('OPEN', 'EXPIRED', 'EXPIRED(GRACE)', 'LOCKED(TIMED)', 'LOCKED', 'EXPIRED & LOCKED(TIMED)', 'EXPIRED(GRACE) & LOCKED(TIMED)', 'EXPIRED & LOCKED', 'EXPIRED(GRACE) & LOCKED'))
)

CREATE TABLE USER_TABLESPACE(
      USER_TABLESPACE_KEY NUMBER NOT NULL,
      USER_KEY NUMBER NOT NULL,
      TABLESPACE_KEY NUMBER NOT NULL,
      TSTAMP TIMESTAMP NOT NULL,
      CONSTRAINT pk_user_tablespace_key PRIMARY KEY (USER_TABLESPACE_KEY)
)

CREATE TABLE ROLE(
      ROLE_KEY NUMBER NOT NULL,
      ROLE_ID NUMBER NOT NULL,
      ROLE VARCHAR2(128) NOT NULL,
      AUTHENTICATION_TYPE VARCHAR2(11) NOT NULL,
      TSTAMP TIMESTAMP NOT NULL,
      CONSTRAINT pk_role_key PRIMARY KEY (ROLE_KEY),
      CONSTRAINT aut_type_value CHECK (AUTHENTICATION_TYPE IN ('NONE', 'EXTERNAL', 'GLOBAL', 'APPLICATION', 'PASSWORD'))
)

CREATE TABLE USER_ROLE(
      USER_ROLE_KEY NUMBER NOT NULL,
      USER_KEY NUMBER NOT NULL,
      ROLE_KEY NUMBER NOT NULL,
      TSTAMP TIMESTAMP NOT NULL,
      CONSTRAINT pk_user_role_key PRIMARY KEY (USER_ROLE_KEY)
)

CREATE TABLE SQL_COMMANDS(
      SQL_COMMANDS_KEY NUMBER NOT NULL,
      SQL_ID VARCHAR2(13) NOT NULL,
      SQL_FULLTEXT CLOB NOT NULL,
      TSTAMP TIMESTAMP NOT NULL,
      CONSTRAINT pk_sql_commands_key PRIMARY KEY (SQL_COMMANDS_KEY)
)

CREATE TABLE CPU(
      CPU_KEY NUMBER NOT NULL,
      NUM_CPUS NUMBER NOT NULL,
      IDLE_TIME NUMBER NOT NULL,
      BUSY_TIME NUMBER NOT NULL,
      USED_PERCENT NUMBER NOT NULL,
      IOWAIT_TIME NUMBER NOT NULL,
      TSTAMP TIMESTAMP NOT NULL,
      CONSTRAINT pk_cpu_key PRIMARY KEY (CPU_KEY)
)

/* SEQUENCES */

CREATE SEQUENCE status_seq
      START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE tablespace_seq
      START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE user_seq
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

CREATE OR REPLACE TRIGGER inc_tablespace
BEFORE INSERT ON TABLESPACE
FOR EACH ROW
BEGIN 
  IF :NEW.TABLESPACE_KEY IS NULL 
  THEN  
    :NEW.TABLESPACE_KEY := tablespace_seq.NEXTVAL;
    :NEW.TSTAMP := sysdate;
  END IF; 
END;

CREATE OR REPLACE TRIGGER inc_user
BEFORE INSERT ON USER
FOR EACH ROW
BEGIN 
  IF :NEW.USER_KEY IS NULL 
  THEN  
    :NEW.USER_KEY := user_seq.NEXTVAL;
    :NEW.TSTAMP := sysdate;
  END IF; 
END;

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