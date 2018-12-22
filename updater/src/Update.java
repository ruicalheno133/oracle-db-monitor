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
                                   + "((t3.value/(t3.value+t2.value))*100) AS USED_PERCENT"
                                   + "FROM V$OSSTAT t1, V$OSSTAT t2, V$OSSTAT t3, V$OSSTAT t4"
                                   + "WHERE t1.STAT_NAME = 'NUM_CPUS' "
                                   + "AND t2.STAT_NAME = 'IDLE_TIME'"
                                   + "AND t3.STAT_NAME='BUSY_TIME'"
                                   + "AND t4.STAT_NAME='IOWAIT_TIME'";

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
            //populateCPU(conDBA, conMan);

            LOGGER.info("\tClosed DBA and Manager connections.");

            conDBA.close();
            conMan.close();
        } catch (SQLException e) {
            LOGGER.severe("Unable to establish connections.");
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

            ResultSet resultSet = statementDBA.executeQuery(selectCPU);

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

            ResultSet resultSet = statementDBA.executeQuery(selectStatus);

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
