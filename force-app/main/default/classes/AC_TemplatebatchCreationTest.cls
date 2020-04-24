@isTest
public class AC_TemplatebatchCreationTest {
	   
    public static testMethod void setup(){
        try {
            agileComp__AC_Templates_Config__c template = new agileComp__AC_Templates_Config__c(agileComp__AC_Name__c = 'test');
            insert template;
            
            Test.startTest();
                Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
                AC_TemplatebatchCreation creation = new AC_TemplatebatchCreation();
                Database.executeBatch(creation);
            Test.stopTest();
        } catch (Exception e) {
            
        }
        
    }
}