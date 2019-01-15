import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Connect {
    private static final String SERVICE_NAME = "orcl";
    private static final String USER = "sys as sysdba";
    private static final String PASSWORD = "oracle";

    public static Connection connect(boolean isDBA) throws SQLException {
        if (isDBA)
            return DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521/"+ SERVICE_NAME,
                    USER,
                    PASSWORD);
        else
            return DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521/orcl",
                    "manager", "pass");
    }
}
