public class TriggerCount {
    static integer runTimes = 0;
    
    public static integer getRunTimes(){
    	return runTimes;
    }
    
    public static void setRunTimes(){
    	runTimes++;
    }
}