@isTest
public class AC_ScheduleBatchCreationTest {

    public static testMethod void setup(){
        Test.startTest();
            AC_ScheduleBatchCreation up = new AC_ScheduleBatchCreation();
        	AC_TemplatebatchCreation instance = new AC_TemplatebatchCreation();
            //system.Schedulable(instance, 1);
            DateTime d = System.now();
         	String CRON_EXP = '0 0 0 3 9 ? 2022';
        
            System.schedule('testBatch', CRON_EXP, new AC_ScheduleBatchCreation()); 
        Test.stopTest();
    }
}