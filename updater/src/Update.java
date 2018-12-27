import java.io.IOException;
import java.sql.*;
import java.util.TimerTask;
import java.util.logging.Handler;
import java.util.logging.Logger;
import java.util.logging.FileHandler;

/**
 * Realiza o update da Base de Dados 'Manager'
 * de 5 em 5 segundos.
 *
 * @author Grupo 5
 * @version 1.0
 */
public class Update extends TimerTask {
    private  final Logger LOGGER = Logger.getLogger( Update.class.getName() );
    private final char PLICAS = '\'';
    private final String PLICASV = "\',";

    private int log_number;

    private final String selectStatus = "SELECT ((sysdate - i.startup_time ) * 24 * 60) AS \"UPTIME\", "
            + "i.database_type, "
            + "d.name AS \"DATABASE_NAME\", "
            + "i.instance_name, "
            + "c.name AS \"CONTAINERS_NAME\", "
            + "d.platform_name, "
            + "i.thread#, "
            + "i.archiver "
            + "FROM V$instance i, V$database d, V$containers c";

    private final String selectCPU = "SELECT t1.VALUE AS NUM_CPUS,"
            + "t2.value AS IDLE_TIME,"
            + "t3.value AS BUSY_TIME,"
            + "t4.value AS IOWAIT_TIME,"
            + "((t3.value/(t3.value+t2.value))*100) AS USED_PERCENT "
            + "FROM V$OSSTAT t1, V$OSSTAT t2, V$OSSTAT t3, V$OSSTAT t4 "
            + "WHERE t1.STAT_NAME = 'NUM_CPUS' "
            + "AND t2.STAT_NAME = 'IDLE_TIME' "
            + "AND t3.STAT_NAME='BUSY_TIME' "
            + "AND t4.STAT_NAME='IOWAIT_TIME'";

    private final String selectMemory = "SELECT total.TOTAL_SIZE, "
            + "free.FREE_SIZE, "
            + "total.TOTAL_SIZE - free.FREE_SIZE USED, "
            + "((total.TOTAL_SIZE - free.FREE_SIZE) / total.TOTAL_SIZE) * 100 USED_PERCENT "
            + "FROM (select sum(value)/1024/1024 TOTAL_SIZE from v$sga) total, "
            + "(select sum(bytes)/1024/1024 FREE_SIZE from v$sgastat "
            + "where name like '%free memory%') free";

    private final String selectUsers = "SELECT user_id, " +
            "username, " +
            "account_status, " +
            "expiry_date, " +
            "default_tablespace, " +
            "temporary_tablespace, " +
            "profile, " +
            "created, " +
            "last_login " +
            "FROM dba_users " +
            "ORDER BY user_id";

    private final String selectTablespaces = "SELECT tv.TS#, " +
            "ts.tablespace_name, " +
            "tsm.tablespace_size, " +
            "tsm.tablespace_size - used_space AS \"FREE_SPACE\", " +
            "tsm.used_percent, " +
            "ts.max_size, " +
            "ts.status, " +
            "ts.contents, " +
            "ts.segment_space_management " +
            "FROM DBA_TABLESPACES ts " +
            "JOIN V$TABLESPACE tv ON tv.name = ts.tablespace_name " +
            "LEFT JOIN DBA_TABLESPACE_USAGE_METRICS tsm ON ts.tablespace_name = tsm.tablespace_name";

    private final String selectUserTablespaces = "SELECT u.user_id, " +
            "t.ts#, " +
            "q.bytes, " +
            "q.max_bytes " +
            "FROM DBA_TS_QUOTAS q," +
            "DBA_USERS u, " +
            "v$tablespace t " +
            "WHERE q.username = u.username " +
            "AND q.tablespace_name = t.name";

    private final String selectDatafiles = "SELECT vdf.file#, " +
            "vdf.TS#, " +
            "df.file_name, " +
            "df.status, " +
            "df.bytes / 1024 AS \"SIZE\", " +
            "df.maxbytes / 1024, " +
            "df.autoextensible " +
            "FROM DBA_DATA_FILES df, v$datafile vdf " +
            "WHERE df.file_name = vdf.\"NAME\"";

    private final String selectRoles = "SELECT role_id, " +
            "role, " +
            "authentication_type " +
            "FROM dba_roles";

    private final String selectUserRoles = "SELECT u.user_id, " +
            "r.ROLE_ID " +
            "FROM DBA_ROLE_PRIVS ur, " +
            "DBA_USERS u, " +
            "DBA_ROLES r " +
            "WHERE ur.grantee = u.username " +
            "AND ur.granted_role = r.role";

    /**
     * Cria uma instancia da class update.
     *
     */
    public Update() {
        try {
            Handler filehandler = new FileHandler("log.xml");
            LOGGER.addHandler(filehandler);
        } catch (IOException e) {
            LOGGER.severe("Unable to configure logger.");
        }
    }

    /**
     * Executa o update.
     *
     */
    @Override
    public void run() {
        LOGGER.info("STARTED RUN #" + log_number);
        populate();
        LOGGER.info("ENDEND RUN #" + log_number);

        log_number++;
    }

    /**
     * Estabelece a conexão às Bases de Dados 'Manager' e 'DBA'.
     * Recolhe os dados das tabelas presentes em 'DBA' e
     * coloca-os nas tabelas presentes em 'Manager'.
     *
     */
    public void populate(){
        try {
            final Connection conDBA = Connect.connect(true);
            final Connection conMan = Connect.connect(false);

            LOGGER.info("\tEstablished DBA and Manager connections.");

            populateStatus(conDBA, conMan);
            populateCPU(conDBA, conMan);
            populateMemory(conDBA, conMan);
            populateUsers(conDBA, conMan);
            populateTablespaces(conDBA, conMan);
            joinUserTablespaces(conDBA, conMan);
            populateRoles(conDBA, conMan);
            joinUserRoles(conDBA, conMan);
            populateDatafiles(conDBA, conMan);

            LOGGER.info("\tClosed DBA and Manager connections.");

            conDBA.close();
            conMan.close();
        } catch (SQLException e) {
            LOGGER.severe("Unable to establish connections.");
        }
    }

    /**
     * Realiza o povoamento da tabela DATAFILES.
     *
     * @param conDBA Conexão à Base de Dados DBA.
     * @param conMan Conexão à Base de Dados Manager.
     *
     */
    private void populateDatafiles(Connection conDBA, Connection conMan) {
        try {
            final Statement statementDBA = conDBA.createStatement();
            final Statement statementMan = conMan.createStatement();

            LOGGER.info("\tGathering data for DATAFILE TABLE.");
            ResultSet resultSet = statementDBA.executeQuery(selectDatafiles);
            StringBuilder values = new StringBuilder();
            LOGGER.info("Data Gathered");

            LOGGER.info("Inserting data into DATAFILE TABLE.");

            while (resultSet.next()) {
                values.setLength(0);
                values.append("(null,")
                        .append(resultSet.getString(1) + ",")
                        .append(resultSet.getString(2) + ",")
                        .append(PLICAS + resultSet.getString(3) + PLICASV)
                        .append(PLICAS + resultSet.getString(4) + PLICASV)
                        .append(resultSet.getString(5) + ',')
                        .append(resultSet.getString(6) + ",")
                        .append(PLICAS + resultSet.getString(7) + PLICASV)
                        .append("null)");

                statementMan.executeUpdate("INSERT INTO DATAFILE VALUES " + values.toString());
            }

            LOGGER.info("Data Inserted");

            statementDBA.close();
            statementMan.close();
        } catch (SQLException e) {
            e.printStackTrace();
            LOGGER.severe("Unable to populate DATAFILE table.");
        }
    }

    /**
     * Une as tabelas USERS e ROLES.
     * Realiza o povoamento da tabela USER_ROLE.
     *
     * @param conDBA Conexão à Base de Dados DBA.
     * @param conMan Conexão à Base de Dados Manager.
     *
     */
    private void joinUserRoles(Connection conDBA, Connection conMan) {
        try {
            final Statement statementDBA = conDBA.createStatement();
            final Statement statementMan = conMan.createStatement();

            LOGGER.info("\tGathering data for USER_ROLE TABLE.");
            ResultSet resultSet = statementDBA.executeQuery(selectUserRoles);
            StringBuilder values = new StringBuilder();
            LOGGER.info("Data Gathered");

            LOGGER.info("Inserting data into USER_ROLE TABLE.");

            while (resultSet.next()) {
                values.setLength(0);
                values.append("(null,")
                        .append(resultSet.getString(1) + ",")
                        .append(resultSet.getString(2) + ',')
                        .append("null)");
                statementMan.executeUpdate("INSERT INTO USER_ROLE VALUES " + values.toString());
            }

            LOGGER.info("Data Inserted");

            statementDBA.close();
            statementMan.close();
        } catch (SQLException e) {
            e.printStackTrace();
            LOGGER.severe("Unable to populate USER_ROLE table.");
        }
    }
    
    /**
     * Realiza o povoamento da tabela ROLES.
     *
     * @param conDBA Conexão à Base de Dados DBA.
     * @param conMan Conexão à Base de Dados Manager.
     *
     */
    private void populateRoles(Connection conDBA, Connection conMan) {
        try {
            final Statement statementDBA = conDBA.createStatement();
            final Statement statementMan = conMan.createStatement();

            LOGGER.info("\tGathering data for ROLE TABLE.");
            ResultSet resultSet = statementDBA.executeQuery(selectRoles);
            StringBuilder values = new StringBuilder();
            LOGGER.info("Data Gathered");

            LOGGER.info("Inserting data into ROLE TABLE.");

            while (resultSet.next()) {
                values.setLength(0);
                values.append("(null,")
                        .append(resultSet.getString(1) + ",")
                        .append(PLICAS + resultSet.getString(2) + PLICASV)
                        .append(PLICAS + resultSet.getString(3) + PLICASV)
                        .append("null)");

                statementMan.executeUpdate("INSERT INTO ROLE VALUES " + values.toString());
            }

            LOGGER.info("Data Inserted");

            statementDBA.close();
            statementMan.close();
        } catch (SQLException e) {
            e.printStackTrace();
            LOGGER.severe("Unable to populate ROLE table.");
        }
    }

    /**
     * Une as tabelas Users e Tablespaces.
     * Realiza o povoamento da tabela USER_TABLESPACE.
     *
     * @param conDBA Conexão à Base de Dados DBA.
     * @param conMan Conexão à Base de Dados Manager.
     *
     */
    private void joinUserTablespaces(Connection conDBA, Connection conMan) {
        try {
            final Statement statementDBA = conDBA.createStatement();
            final Statement statementMan = conMan.createStatement();

            LOGGER.info("\tGathering data for USER_TABLESPACE TABLE.");
            ResultSet resultSet = statementDBA.executeQuery(selectUserTablespaces);
            StringBuilder values = new StringBuilder();
            LOGGER.info("Data Gathered");

            LOGGER.info("Inserting data into USER_TABLESPACE TABLE.");

            while (resultSet.next()) {
                values.setLength(0);
                values.append("(null,")
                        .append(resultSet.getString(1) + ",")
                        .append(resultSet.getString(2) + ',')
                        .append(resultSet.getString(3) + ',')
                        .append(resultSet.getString(4) + ',')
                        .append("null)");
                statementMan.executeUpdate("INSERT INTO USER_TABLESPACE VALUES " + values.toString());
            }

            LOGGER.info("Data Inserted");

            statementDBA.close();
            statementMan.close();
        } catch (SQLException e) {
            e.printStackTrace();
            LOGGER.severe("Unable to populate USER_TABLESPACE table.");
        }
    }

    /**
     * Realiza o povoamento da tabela TABLESPACES.
     *
     * @param conDBA Conexão à Base de Dados DBA.
     * @param conMan Conexão à Base de Dados Manager.
     *
     */
    private void populateTablespaces(Connection conDBA, Connection conMan) {
        try {
            final Statement statementDBA = conDBA.createStatement();
            final Statement statementMan = conMan.createStatement();

            LOGGER.info("\tGathering data for TABLESPACE TABLE.");
            ResultSet resultSet = statementDBA.executeQuery(selectTablespaces);
            StringBuilder values = new StringBuilder();
            LOGGER.info("Data Gathered");

            LOGGER.info("Inserting data into TABLESPACE TABLE.");

            while (resultSet.next()) {
                values.setLength(0);
                values.append("(null,")
                        .append(resultSet.getString(1) + ",")
                        .append(PLICAS + resultSet.getString(2) + PLICASV)
                        .append(resultSet.getString(3) + ',')
                        .append(resultSet.getString(4) + ",")
                        .append(resultSet.getString(5) + ",")
                        .append(resultSet.getString(6) + ",")
                        .append(PLICAS + resultSet.getString(7) + PLICASV)
                        .append(PLICAS + resultSet.getString(8) + PLICASV)
                        .append(PLICAS + resultSet.getString(9) + PLICASV)
                        .append("null)");

                statementMan.executeUpdate("INSERT INTO \"TABLESPACE\" VALUES " + values.toString());
            }



            LOGGER.info("Data Inserted");


            statementDBA.close();
            statementMan.close();
        } catch (SQLException e) {
            e.printStackTrace();
            LOGGER.severe("Unable to populate TABLESPACE table.");
        }
    }

    /**
     * Realiza o povoamento da tabela USERS.
     *
     * @param conDBA Conexão à Base de Dados DBA.
     * @param conMan Conexão à Base de Dados Manager.
     *
     */
    private void populateUsers(Connection conDBA, Connection conMan) {
        try {
            final Statement statementDBA = conDBA.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,ResultSet.CONCUR_READ_ONLY);
            final Statement statementMan = conMan.createStatement();

            LOGGER.info("\tGathering data for USER TABLE.");
            ResultSet resultSet = statementDBA.executeQuery(selectUsers);
            StringBuilder values = new StringBuilder();
            LOGGER.info("Data Gathered");

            LOGGER.info("Inserting data into USER TABLE.");
            while (resultSet.next()) {
                values.setLength(0);
                values.append("(null,")
                        .append(resultSet.getString(1) + ",")
                        .append(PLICAS + resultSet.getString(2) + PLICASV)
                        .append(PLICAS + resultSet.getString(3) + PLICASV);
                        if (resultSet.getString(4) != null) values.append("TO_DATE(" + PLICAS + resultSet.getString(4) + PLICASV + "'YYYY-MM-DD HH24:MI:SS'),");
                        else values.append("null,");
                        values.append(PLICAS + resultSet.getString(5) + PLICASV)
                        .append(PLICAS + resultSet.getString(6) + PLICASV)
                        .append(PLICAS + resultSet.getString(7) + PLICASV);
                if (resultSet.getString(8) != null) values.append("TO_DATE(" + PLICAS + resultSet.getString(8) + PLICASV + "'YYYY-MM-DD HH24:MI:SS'),");
                else values.append("null,");
                if (resultSet.getString(9) != null) values.append("TO_TIMESTAMP_TZ(" + PLICAS + resultSet.getString(9) + PLICASV + "'YYYY-MM-DD HH24:MI:SS.FF TZR'),");
                else values.append("null,");
                        values.append("null)");
                statementMan.executeUpdate("INSERT INTO \"USER\" VALUES " + values.toString());
            }

            LOGGER.info("Data Inserted");

            statementDBA.close();
            statementMan.close();
        } catch (SQLException e) {
            LOGGER.severe("Unable to populate USER table.");
        }
    }

    /**
     * Realiza o povoamento da tabela STATUS.
     *
     * @param conDBA Conexão à Base de Dados DBA.
     * @param conMan Conexão à Base de Dados Manager.
     *
     */
    private void populateStatus(Connection conDBA, Connection conMan){
        try {
            final Statement statementDBA = conDBA.createStatement();
            final Statement statementMan = conMan.createStatement();

            LOGGER.info("\tGathering data for STATUS TABLE.");
            ResultSet resultSet = statementDBA.executeQuery(selectStatus);
            StringBuilder values = new StringBuilder();
            LOGGER.info("Data Gathered");

            LOGGER.info("Inserting data into STATUS TABLE.");

            while (resultSet.next()) {
                values.append("(null,")
                        .append(resultSet.getString(1) + ",")
                        .append(PLICAS + resultSet.getString(2) + PLICASV)
                        .append(PLICAS + resultSet.getString(3) + PLICASV)
                        .append(PLICAS + resultSet.getString(4) + PLICASV)
                        .append(PLICAS + resultSet.getString(5) + PLICASV)
                        .append(PLICAS + resultSet.getString(6) + PLICASV)
                        .append(resultSet.getString(7) + ",")
                        .append(PLICAS + resultSet.getString(8) + PLICASV)
                        .append("CURRENT_TIMESTAMP)");
            }

            LOGGER.info("Data Inserted");

            statementMan.executeUpdate("INSERT INTO STATUS VALUES " + values.toString());

            statementDBA.close();
            statementMan.close();
        } catch (SQLException e) {
            LOGGER.severe("Unable to populate STATUS table.");
        }
    }
    
    /**
     * Realiza o povoamento da tabela CPU.
     *
     * @param conDBA Conexão à Base de Dados DBA.
     * @param conMan Conexão à Base de Dados Manager.
     *
     */
    private void populateCPU(Connection conDBA, Connection conMan) {
        try {
            final Statement statementDBA = conDBA.createStatement();
            final Statement statementMan = conMan.createStatement();

            LOGGER.info("\tGathering data for CPU TABLE.");
            ResultSet resultSet = statementDBA.executeQuery(selectCPU);
            StringBuilder values = new StringBuilder();
            LOGGER.info("Data Gathered");

            LOGGER.info("Inserting data into CPU TABLE.");

            while (resultSet.next()) {
                values.append("(null,")
                        .append(resultSet.getString(1) + ",")
                        .append(resultSet.getString(2) + ",")
                        .append(resultSet.getString(3) + ",")
                        .append(resultSet.getString(4) + ",")
                        .append(resultSet.getString(5) + ",")
                        .append("null)");
            }

            LOGGER.info("Data Inserted");

            statementMan.executeUpdate("INSERT INTO CPU VALUES " + values.toString());

            statementDBA.close();
            statementMan.close();
        } catch (SQLException e) {
            LOGGER.severe("Unable to populate CPU table.");
        }
    }

    /**
     * Realiza o povoamento da tabela MEMORY.
     *
     * @param conDBA Conexão à Base de Dados DBA.
     * @param conMan Conexão à Base de Dados Manager.
     *
     */
    private void populateMemory(Connection conDBA, Connection conMan) {
        try {
            final Statement statementDBA = conDBA.createStatement();
            final Statement statementMan = conMan.createStatement();

            LOGGER.info("\tGathering data for MEMORY TABLE.");
            ResultSet resultSet = statementDBA.executeQuery(selectMemory);
            StringBuilder values = new StringBuilder();
            LOGGER.info("Data Gathered");

            LOGGER.info("Inserting data into MEMORY TABLE.");

            while (resultSet.next()) {
                values.append("(null,")
                        .append(resultSet.getString(1) + ",")
                        .append(resultSet.getString(2) + ",")
                        .append(resultSet.getString(3) + ",")
                        .append(resultSet.getString(4) + ",")
                        .append("null)");
            }

            LOGGER.info("Data Inserted");

            statementMan.executeUpdate("INSERT INTO MEMORY VALUES " + values.toString());

            statementDBA.close();
            statementMan.close();
        } catch (SQLException e) {
            LOGGER.severe("Unable to populate MEMORY table.");
        }
    }

    /**
     * Realiza o povoamento da tabela SQLCOMMANDS.
     *
     * @param conDBA Conexão à Base de Dados DBA.
     * @param conMan Conexão à Base de Dados Manager.
     *
     */
    private void populateSQL(Connection conDBA, Connection conMan) {
        try {
            final Statement statementDBA = conDBA.createStatement();
            final Statement statementMan = conMan.createStatement();

            ResultSet resultSet = statementDBA.executeQuery(selectStatus);

            statementDBA.close();
            statementMan.close();
        } catch (SQLException e) {
            LOGGER.severe("Unable to populate SQLCOMMANDS table.");
        }
    }

}
