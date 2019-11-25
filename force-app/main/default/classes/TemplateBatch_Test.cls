@isTest
public with sharing class TemplateBatch_Test {
    
    @isTest
    static void testBatch() {
        TemplateBatch tb = new TemplateBatch();
        tb.setVariables(new List<String>(), 'Account', 'SELECT Id FROM Account', 1, '779456123123', UserInfo.getUserId());
        database.executebatch(tb,200    );
    }
}
