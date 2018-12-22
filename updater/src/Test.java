import java.util.Timer;

/**
 * Created by luismp on 14/12/2018.
 */
public class Test {
    public static void main(String[] args){
        Timer t = new Timer();
        Update u = new Update();
        t.schedule(u,0,5000);
    }

}
