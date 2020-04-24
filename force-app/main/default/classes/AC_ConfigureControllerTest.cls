@isTest
private with sharing class AC_ConfigureControllerTest {
    @isTest
    static void checkConfigTest() {
        List<agileComp__AC_Templates_Config__c> temps = AC_TestDataFactory.createAgilTemplateRec();
        insert temps;
        Test.startTest();
        AC_ConfigureController.checkConfig();
        Test.stopTest();
    }

    @isTest
    static void deleteClassTest() {
        List<agileComp__AC_Templates_Config__c> temps = AC_TestDataFactory.createAgilTemplateRec();
        insert temps;
        Test.startTest();
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        try {
            AC_ConfigureController.deleteClass();
        } catch (Exception ex) {
            
        }
        Test.stopTest();
    }

    @isTest
    static void checkStatusTest() {
        Test.startTest();
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        try {
            AC_ConfigureController.checkStatus(null);
        } catch (Exception ex) {
            
        }
        Test.stopTest();
    }
}