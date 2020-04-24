@isTest
public with sharing class AC_DeleteCommInputBatchTest {
    @isTest
    static void testDeleteBatch() {
        Account acc = new Account(name = 'Test');
        insert acc;
        Test.startTest();
        System.assertEquals(1, [SELECT COUNT(Id) size FROM Account][0].get('size'));
        String query = 'SELECT Id FROM Account';
        AC_DeleteCommInputBatch deleteBatch = new AC_DeleteCommInputBatch(query);
        System.assertNotEquals(deleteBatch, null);
	    database.executebatch(deleteBatch,200);
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT(Id) size FROM Account][0].get('size'));
    }
}