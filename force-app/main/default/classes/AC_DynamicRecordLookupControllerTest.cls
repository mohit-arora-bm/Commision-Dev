@isTest
public with sharing class AC_DynamicRecordLookupControllerTest {
    @isTest
    static void testController() {
        Account acc = new Account(name = 'Test');
        insert acc;
        Test.startTest();
        System.assertEquals(1, [SELECT COUNT(Id) size FROM Account][0].get('size'));
        System.assert(!AC_DynamicRecordLookupController.fetchRecords('Tes','Account').isEmpty());
        Test.stopTest();
    }
}