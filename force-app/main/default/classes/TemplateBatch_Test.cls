@isTest
public with sharing class TemplateBatch_Test {
    
    @isTest
    static void testBatch() {
        Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc; 
        agileComp__AC_Templates_Config__c template = new agileComp__AC_Templates_Config__c();
        template.agileComp__AC_BatchClassName__c = 'TemplateBatch';
        template.agileComp__AC_Name__c = 'Acc';
        template.Name = 'Acc';
        String json = '{"selectedFieldOptions":[{"customLabel":"Id","selectedField":"Id","dataType":"text","func":"","apexDataType":"ID","isFieldRelated":false,"selectedFieldObj":{},"mapping":"agileComp__Account__c","relatedObjectName":null}],"selectedFilters":[{"operations":[{"label":"Equals","value":"EqualTo"},{"label":"Does not equal","value":"NotEqualTo"},{"label":"Contains","value":"Contains"},{"label":"Not Contains","value":"NotContains"}],"label":"","fieldType":"text","filterValue":"Test","operation":"Contains","selectedField":"Name","isFieldRelated":false,"dataType":"text","apexDataType":"STRING","customLabel":"Name","relatedObjectName":null}],"description":"1","documentField":{"isFieldRelated":false,"selectedField":"Id","relatedObjectName":null},"accountField":{"isFieldRelated":false,"selectedField":""},"isOpen":false,"filterOptions":[],"selectedFilterCombo":"AND","filterCombo":"","isCustom":false,"hasError":false}';
        template.agileComp__AC_Object__c = 'Account';
        template.agileComp__AC_TemplateDataJson__c = '['+ json +']';
        insert template;
        Test.startTest();
        TemplateBatch tb = new TemplateBatch();
        
        tb.setVariables(new List<String>{json}, 'Account', 'SELECT Id FROM Account Group by Id', 1, template.Id, UserInfo.getUserId());
        database.executebatch(tb,200);
        Test.stopTest();
    }
}