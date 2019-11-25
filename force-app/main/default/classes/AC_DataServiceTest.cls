@isTest
public class AC_DataServiceTest {
    static testMethod void logExceptionTest() {
        Test.startTest();
        AC_DataService.logException('','');
        Test.stopTest();
    }
}