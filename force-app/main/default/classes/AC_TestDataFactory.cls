public class AC_TestDataFactory { 
    public static List<agileComp__AC_Templates_Config__c> createAgilTemplateRec() {
        List<agileComp__AC_Templates_Config__c> dataList = new List<agileComp__AC_Templates_Config__c>();
        agileComp__AC_Templates_Config__c dataObj = new agileComp__AC_Templates_Config__c();
        dataObj.agileComp__AC_Name__c = 'Acc 1';
        dataObj.agileComp__AC_Object__c = 'Account';
        dataObj.agileComp__AC_BatchClassName__c	= 'TemplateBatch';
        dataObj.agileComp__AC_TemplateDataJson__c  = '[{"selectedFieldOptions":[{"customLabel":"Id","selectedField":"Id","dataType":"text","func":"","apexDataType":"ID","isFieldRelated":false,"selectedFieldObj":{},"mapping":"agileComp__Account__c","relatedObjectName":null},{"customLabel":"AnnualRevenue","selectedField":"AnnualRevenue","dataType":"number","func":"sum","apexDataType":"CURRENCY","isFieldRelated":false,"selectedFieldObj":{},"mathFunc":"Absolute","mapping":"agileComp__Orig_Doc_Ext_Cost__c","relatedObjectName":null}],"selectedFilters":[{"operations":[{"label":"Equals","value":"EqualTo"},{"label":"Does not equal","value":"NotEqualTo"},{"label":"Greater than","value":"GreaterThan"},{"label":"Greater than or equal","value":"GreaterThanOrEqualTo"},{"label":"Less than","value":"LessThan"},{"label":"Less than or equal","value":"LessThanOrEqualTo"}],"label":"","fieldType":"text","filterValue":"1","operation":"GreaterThan","selectedField":"AnnualRevenue","isFieldRelated":false,"dataType":"number","apexDataType":"CURRENCY","customLabel":"AnnualRevenue","relatedObjectName":null}],"description":"1","documentField":{"isFieldRelated":false,"selectedField":"Id","relatedObjectName":null},"accountField":{"isFieldRelated":false,"selectedField":"Id"},"isOpen":false,"filterOptions":[],"selectedFilterCombo":"AND","filterCombo":"","isCustom":false,"hasError":false}]';
        dataList.add(dataObj);
        return dataList;
    }
    public static List<agileComp__commissionSplit__c> createAccCommSplit(String accId) {
        List<agileComp__commissionSplit__c> commSplits = new List<agileComp__commissionSplit__c>();
        agileComp__commissionSplit__c split = new agileComp__commissionSplit__c();
        split.agileComp__accountSplit__c = accId;
        split.agileComp__Split_Percent__c = 75;
        commSplits.add(split);
        split = new agileComp__commissionSplit__c();
        split.agileComp__accountSplit__c = accId;
        split.agileComp__Split_Percent__c = 25;
        commSplits.add(split);
        return commSplits;
    }

    public static List<Contact> createContactRec() {
        List<Contact> ContactDataList = new List<Contact>();
        Contact conData = new Contact();
        conData.lastName = 'Contact1';
        ContactDataList.add(conData);
        return ContactDataList;
    }
    public static List<Account> createAccountRec() {
        List<Account> accountDataList = new List<Account>();
        Account accData = new Account();
        accData.Name = 'Account1';
        accData.Site = 'accData';
        accData.AnnualRevenue = 10;
        accountDataList.add(accData);
        accData = new Account();
        accData.Name = 'Account 2';
        accData.Site = 'accDataSite';
        accData.AnnualRevenue = 10;

        accountDataList.add(accData);
        return accountDataList;
    }
    
}