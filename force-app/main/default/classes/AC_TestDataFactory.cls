public class AC_TestDataFactory {
    public static List<agileComp__AC_Templates_Config__c> createAgileQuoteTemplateRec() {
        List<agileComp__AC_Templates_Config__c> dataList = new List<agileComp__AC_Templates_Config__c>();
        agileComp__AC_Templates_Config__c dataObj = new agileComp__AC_Templates_Config__c();
        dataObj.agileComp__AC_Name__c = 'Acc 1';
        dataObj.agileComp__AC_Object__c = 'Account';
        // dataObj.agileComp__AC_Filter_Data_Mapping__c = '[{"operations":[{"label":"Equals","value":"EqualTo"},{"label":"Does not equal","value":"NotEqualTo"},{"label":"Contains","value":"Contains"},{"label":"Not Contains","value":"NotContains"}],"value":"","label":"Account Number","fieldType":"text","filterValue":"1331","operation":"EqualTo"},{"operations":[{"label":"Equals","value":"EqualTo"},{"label":"Does not equal","value":"NotEqualTo"},{"label":"Contains","value":"Contains"},{"label":"Not Contains","value":"NotContains"}],"value":"","label":"Company Name","fieldType":"text","filterValue":"qwe","operation":"NotContains"}]';
        dataList.add(dataObj);
        dataObj = new agileComp__AC_Templates_Config__c();
        dataObj.agileComp__AC_Name__c = 'Acc 2';
        // dataObj.agileComp__AC_Filter_Data_Mapping__c = '[{"operations":[{"label":"Equals","value":"EqualTo"},{"label":"Does not equal","value":"NotEqualTo"},{"label":"Contains","value":"Contains"},{"label":"Not Contains","value":"NotContains"}],"value":"","label":"Account Number","fieldType":"text","filterValue":"1331","operation":"EqualTo"},{"operations":[{"label":"Equals","value":"EqualTo"},{"label":"Does not equal","value":"NotEqualTo"},{"label":"Contains","value":"Contains"},{"label":"Not Contains","value":"NotContains"}],"value":"","label":"Company Name","fieldType":"text","filterValue":"qwe","operation":"NotContains"}]';
        dataObj.agileComp__AC_Object__c = 'Account';
        dataObj.agileComp__AC_TemplateDataJson__c  = '[{"customLabel":"Account Number","selectedField":"AccountNumber","dataType":"text","func":"","apexDataType":"STRING","isFieldRelated":false,"selectedFieldObj":{}},{"customLabel":"Account Rating","selectedField":"Rating","dataType":"text","func":"","apexDataType":"PICKLIST","isFieldRelated":false,"selectedFieldObj":{}},{"customLabel":"Company Name","selectedField":"{\"relatedField\":\"CreatedBy.CompanyName\",\"fieldMeta\":{\"relationshipName\":\"CompanyName\",\"relatedObjectName\":\"\",\"isUpdateable\":true,\"isRelated\":false,\"fieldLabel\":\"Company Name\",\"fieldAPIName\":\"CompanyName\",\"dataType\":\"string\"},\"fieldApiName\":\"CreatedById-\",\"eventAdditionalParam\":{\"type\":\"Field\",\"index\":null}}","dataType":"text","func":"","apexDataType":"STRING","isFieldRelated":true,"selectedFieldObj":{}}]';
        dataList.add(dataObj);
        return dataList;
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
        accountDataList.add(accData);
        accData = new Account();
        accData.Name = 'Account 2';
        accData.Site = 'accDataSite';
        accountDataList.add(accData);
        return accountDataList;
    }
    public static List<Opportunity> createOppRec() {
        List<Opportunity> OpportunityDataList = new List<Opportunity>();
        Opportunity OpportunityData = new Opportunity();
        OpportunityData.Name = 'Opportunity';
        OpportunityData.StageName = 'Prospecting';
        OpportunityData.CloseDate = System.today();
        OpportunityDataList.add(OpportunityData);
        return OpportunityDataList;
    }
    // public static List<Quote> createQuoteRec() {
    //     List<Quote> quoteDataList = new List<Quote>();
    //     Quote quoteData = new Quote();
    //     quoteData.Name = 'Quote';
    //     quoteData.agilqt__sentToFulfillment__c = TRUE;
    //     quoteData.ExpirationDate = Date.today().addMonths(2);
    //     quoteDataList.add(quoteData);
    //     return quoteDataList;
    // }
    // public static List<agilqt__quoteLineGroup__c> createquoteLineGroupRec() {
    //     List<agilqt__quoteLineGroup__c> quoteLineGroupDataList = new List<agilqt__quoteLineGroup__c>();
    //     agilqt__quoteLineGroup__c quoteLineGroupData = new agilqt__quoteLineGroup__c();
    //     quoteLineGroupData.Name = 'Quote Line Group';
    //     quoteLineGroupDataList.add(quoteLineGroupData);
    //     return quoteLineGroupDataList;
    // }
    public static List<QuoteLineItem> createquoteLineItemRec() {
        List<QuoteLineItem> QuoteLineItemDataList = new List<QuoteLineItem>();
        QuoteLineItem QuoteLineItemData = new QuoteLineItem();
        QuoteLineItemData.UnitPrice = 10.00;
        QuoteLineItemData.Quantity = 1;
        QuoteLineItemDataList.add(QuoteLineItemData);
        return QuoteLineItemDataList;
    }
    public static List<Product2> createProductRec() {
        List<Product2> productDataList = new List<Product2>();
        Product2 productData = new Product2();
        productData.Name = 'Product';
        productDataList.add(productData);
        return productDataList;
    }
    public static List<Pricebook2> createPricebook2Rec() {
        List<Pricebook2> Pricebook2List = new List<Pricebook2>();
        Pricebook2 Pricebook2Data = new Pricebook2();
        Pricebook2Data.Name = 'Price Book';
        Pricebook2Data.IsActive = true;
        Pricebook2List.add(Pricebook2Data);
        return Pricebook2List;
    }
    public static List<PricebookEntry> createPricebookEntryRec() {
        List<PricebookEntry> PricebookEntryDataList = new List<PricebookEntry>();
        PricebookEntry PricebookEntryData = new PricebookEntry();
        PricebookEntryData.UnitPrice = 10.00;
        PricebookEntryData.IsActive = true;
        PricebookEntryDataList.add(PricebookEntryData);
        return PricebookEntryDataList;
    }
}