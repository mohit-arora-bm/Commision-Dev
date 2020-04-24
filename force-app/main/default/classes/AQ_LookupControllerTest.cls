@isTest
public class AQ_LookupControllerTest {
    
	@TestSetup
    public static void setupData() {
        List<Account> accountDataList = new List<Account>();
        Account accData = new Account();
        accData.Name = 'Account1';
        accData.Site = 'accData';
        accountDataList.add(accData);
        accData = new Account();
        accData.Name = 'Account 2';
        accData.Site = 'accDataSite';
        accountDataList.add(accData);
        insert accountDataList;
    }
    
    @isTest
    public static void testReturnRecords() {
        String jsonString = AQ_LookupController.returnRecords('Account', 'Name', NULL, 'a');
        System.assert( jsonString != NULL );
        
        String jsonString1 = AQ_LookupController.returnRecords('Account', 'Name', 'Site', 'a');
        System.assert( jsonString1 != NULL );
        
        String jsonString2 = AQ_LookupController.returnRecords('User', 'Name', 'Email', 'a');
        System.assert( jsonString2 != NULL );
        
        String jsonString3 = AQ_LookupController.returnRecords('User', 'Name', NULL, 'a');
        System.assert( jsonString3 != NULL );
    }
}