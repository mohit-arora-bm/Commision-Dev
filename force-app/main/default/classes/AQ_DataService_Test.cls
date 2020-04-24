@isTest
public class AQ_DataService_Test {
    static testMethod void logExceptionTest() {
        Test.startTest();
        AQ_DataService.logException('','');
        Test.stopTest();
    }
}