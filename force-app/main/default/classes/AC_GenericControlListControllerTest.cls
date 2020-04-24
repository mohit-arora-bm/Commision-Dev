@isTest
public with sharing class AC_GenericControlListControllerTest {
    @isTest
    static void testController() {
        agileComp__AC_Templates_Config__c template = new agileComp__AC_Templates_Config__c();
        template.agileComp__AC_BatchClassName__c = 'TemplateBatch';
        template.agileComp__AC_Name__c = 'Acc';
        template.Name = 'Acc';
        String json = '{"selectedFieldOptions":[{"customLabel":"Id","selectedField":"Id","dataType":"text","func":"","apexDataType":"ID","isFieldRelated":false,"selectedFieldObj":{},"mapping":"agileComp__Account__c","relatedObjectName":null}],"selectedFilters":[{"operations":[{"label":"Equals","value":"EqualTo"},{"label":"Does not equal","value":"NotEqualTo"},{"label":"Contains","value":"Contains"},{"label":"Not Contains","value":"NotContains"}],"label":"","fieldType":"text","filterValue":"Test","operation":"Contains","selectedField":"Name","isFieldRelated":false,"dataType":"text","apexDataType":"STRING","customLabel":"Name","relatedObjectName":null}],"description":"1","documentField":{"isFieldRelated":false,"selectedField":"Id","relatedObjectName":null},"accountField":{"isFieldRelated":false,"selectedField":""},"isOpen":false,"filterOptions":[],"selectedFilterCombo":"AND","filterCombo":"","isCustom":false,"hasError":false}';
        template.agileComp__AC_Object__c = 'Account';
        template.agileComp__AC_TemplateDataJson__c = '['+ json +']';
        insert template;
        Test.startTest();
        String fieldsListJSON = '[{"fieldAPIName" : "agileComp__AC_Name__c"}]';
        String objectAPIName = 'agileComp__AC_Templates_Config__c';
        System.assertEquals(1,AC_GenericControlListController.fetchRecords(objectAPIName, fieldsListJSON).size());
        AC_SchedulerTemplateController.scheduleTemplate(template.Id, '', String.valueOf(System.now().addDays(1)), String.valueOf(Date.today()), UserInfo.getUserId());
        AC_GenericControlListController.unScheduleJob(template.Id);
        AC_GenericControlListController.getComponentDisability(objectAPIName);
        AC_GenericControlListController.deleteRowApex(template.Id);
        List<agileComp__AC_Templates_Config__c> tmps = [SELECT Id FROM agileComp__AC_Templates_Config__c];
        // System.assert(tmps.isEmpty());
        Test.stopTest();
    }

    // @isTest
    // static void testTemplateTrigger() {
    //     agileComp__AC_Templates_Config__c template = new agileComp__AC_Templates_Config__c();
    //     template.agileComp__AC_BatchClassName__c = 'TemplateBatch';
    //     template.agileComp__AC_Name__c = 'Acc';
    //     template.Name = 'Acc';
    //     String json = '{"selectedFieldOptions":[{"customLabel":"Id","selectedField":"Id","dataType":"text","func":"","apexDataType":"ID","isFieldRelated":false,"selectedFieldObj":{},"mapping":"agileComp__Account__c","relatedObjectName":null}],"selectedFilters":[{"operations":[{"label":"Equals","value":"EqualTo"},{"label":"Does not equal","value":"NotEqualTo"},{"label":"Contains","value":"Contains"},{"label":"Not Contains","value":"NotContains"}],"label":"","fieldType":"text","filterValue":"Test","operation":"Contains","selectedField":"Name","isFieldRelated":false,"dataType":"text","apexDataType":"STRING","customLabel":"Name","relatedObjectName":null}],"description":"1","documentField":{"isFieldRelated":false,"selectedField":"Id","relatedObjectName":null},"accountField":{"isFieldRelated":false,"selectedField":""},"isOpen":false,"filterOptions":[],"selectedFilterCombo":"AND","filterCombo":"","isCustom":false,"hasError":false}';
    //     template.agileComp__AC_Object__c = 'Account';
    //     template.agileComp__AC_TemplateDataJson__c = '['+ json +']';
    //     insert template;
    //     Test.startTest();
    //     try {
    //         delete template;
    //     } catch (Exception ex) {
            
    //     }
    //     Test.stopTest();
    // }
}