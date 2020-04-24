@isTest
private with sharing class AC_SchedulerTemplateControllerTest {
    
    @isTest
    private static void testSchedule(){

        Map<Integer,Datetime> successDate = new Map<Integer,Datetime>();
        DateTime myDateTime = DateTime.newInstance(2021, 2, 11, 8, 6, 16);
        successDate.put(1, myDateTime);
        successDate.put(2, myDateTime);
        String jsonConvertData = JSON.serialize(successDate);

        agileComp__Commission_Sales_Rep__c salesRep = new agileComp__Commission_Sales_Rep__c(agileComp__isActive__c = true); //Parent of agileComp__commissionEmployeeAttainedValue__c
        insert salesRep;

        String cronExp = '0 0 0 8 7 ? 2022', scheduleOn = '', expiresOn = '', userId = UserInfo.getUserId();
        String jsondata, objAPI = '';
        List<AggregateResult> baseObjList = new List<AggregateResult>();
        jsondata =  '{"selectedFieldOptions":[{"customLabel":"Id","selectedField":"Id","dataType":"text","func":"","apexDataType":"ID","isFieldRelated":false,"selectedFieldObj":{},"mapping":"agileComp__Account__c","relatedObjectName":null},{"customLabel":"AnnualRevenue","selectedField":"AnnualRevenue","dataType":"number","func":"sum","apexDataType":"CURRENCY","isFieldRelated":false,"selectedFieldObj":{},"mathFunc":"Absolute","mapping":"agileComp__Orig_Doc_Ext_Cost__c","relatedObjectName":null}],"selectedFilters":[{"operations":[{"label":"Equals","value":"EqualTo"},{"label":"Does not equal","value":"NotEqualTo"},{"label":"Greater than","value":"GreaterThan"},{"label":"Greater than or equal","value":"GreaterThanOrEqualTo"},{"label":"Less than","value":"LessThan"},{"label":"Less than or equal","value":"LessThanOrEqualTo"}],"label":"","fieldType":"text","filterValue":"1","operation":"GreaterThan","selectedField":"AnnualRevenue","isFieldRelated":false,"dataType":"number","apexDataType":"CURRENCY","customLabel":"AnnualRevenue","relatedObjectName":null}],"description":"1","documentField":{"isFieldRelated":false,"selectedField":"Id","relatedObjectName":null},"accountField":{"isFieldRelated":false,"selectedField":"Id"},"isOpen":false,"filterOptions":[],"selectedFilterCombo":"AND","filterCombo":"","isCustom":false,"hasError":false}';
        agileComp__AC_Templates_Config__c template = new agileComp__AC_Templates_Config__c();
        template.agileComp__AC_BatchClassName__c = 'TemplateBatch';
        template.agileComp__AC_Name__c = 'testName';
        template.agileComp__AC_SuccessDateMap__c = jsonConvertData;
        template.agileComp__AC_TemplateDataJson__c = '['+jsondata+']';
        template.agileComp__AC_Object__c = 'Account';
        insert template;
        
        List<String> JSONStrs = new List<String>();
        JSONStrs.add(jsondata);
        List<Account> accountDataList = AC_TestDataFactory.createAccountRec();
        insert accountDataList;
        List<agileComp__commissionSplit__c> commSplits = new List<agileComp__commissionSplit__c>();
        for (Account acc : accountDataList) {
            commSplits.addAll(AC_TestDataFactory.createAccCommSplit(acc.Id));
        }
        insert commSplits;
        Test.startTest();
        AC_SchedulerTemplateController.scheduleTemplate(template.id, cronExp, scheduleOn, expiresOn, userId);
        AC_SchedulerTemplateController.createCommisionInput(jsondata, objAPI, baseObjList, template.id);
        Type customType = Type.forName('TemplateBatch');
        AC_BatchInterface instance = (AC_BatchInterface)customType.newInstance();
        instance.setVariables(JSONStrs, objAPI, 'SELECT  Id Id, sum(AnnualRevenue) AnnualRevenue FROM Account WHERE ( AnnualRevenue > 1 ) GROUP By Id',  1, template.Id, UserInfo.getUserId());
        database.executebatch(instance,200);
        baseObjList = [select count(id) from agileComp__AC_Templates_Config__c];
        AC_SchedulerTemplateController.createCommisionInput(jsondata, objAPI, baseObjList, template.id);
            
        Test.stopTest();
        
    }

    @isTest
    private static void testscheduleOn(){ 
        String cronExp = null, scheduleOn = '', expiresOn = '', userId = UserInfo.getUserId();
        scheduleOn = String.valueOf(Datetime.now().addMinutes(50));
        List<agileComp__AC_Templates_Config__c> dataList = AC_TestDataFactory.createAgilTemplateRec();
        insert dataList;
        Test.startTest();
        AC_SchedulerTemplateController.scheduleTemplate(dataList[0].Id, cronExp, scheduleOn, expiresOn, userId);
        Test.stopTest();
    }
}