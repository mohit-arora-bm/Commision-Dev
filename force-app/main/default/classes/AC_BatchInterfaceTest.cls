/**
 * 
 * 
 * 
*/

@isTest
public class AC_BatchInterfaceTest {

    public static testMethod void setup(){
        Account acc = new Account(name = 'Test');
        insert acc;
        
        String q = 'Select id from Account';
        List<String> str = new List<String>();
        //List<AggregateResult> aggregates = [SELECT count(Id) records FROM Account ];
        
        test.startTest();
            AC_BatchInterface batchInterface = new AC_BatchInterface();
            DataBase.executeBatch(batchInterface, 200);
        	batchInterface.setVariables(str, q, q, 1, q, q);
        test.stopTest();
    }
}