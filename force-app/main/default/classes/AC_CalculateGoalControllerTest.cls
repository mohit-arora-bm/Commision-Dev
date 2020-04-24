@isTest
private with sharing class AC_CalculateGoalControllerTest {

    @isTest
    private static void testGoal() {
        agileComp__Goal_Period__c gp = new agileComp__Goal_Period__c();
        gp.agileComp__From__c = Date.today();
        gp.agileComp__To__c = Date.today().addDays(10);
        insert gp;
        agileComp__Commission_Sales_Rep__c salesRep = new agileComp__Commission_Sales_Rep__c(
            agileComp__isActive__c = true,
            agileComp__Sales_Rep__c = UserInfo.getUserId(),
            Name = 'Test User'
        ); 
        insert salesRep;
        agileComp__Goal_Detail__c goalDetail = new agileComp__Goal_Detail__c(
            agileComp__Commission_Sales_Rep__c = salesRep.Id,
            agileComp__Goal_Period__c = gp.Id
        );
        insert goalDetail;
        agileComp__commissionBaseInput__c commInput = new agileComp__commissionBaseInput__c(
            agileComp__Commission_Sales_Rep__c = salesRep.Id,
            agileComp__Document_Date__c = Date.today().addDays(1),
            agileComp__Orig_Doc_Ext_Cost__c = 10,
            agileComp__Orig_Doc_Ext_Sales__c = 20,
            agileComp__Orig_Doc_Freight__c	 = 5,
            agileComp__Split_Percent__c = 25
        );
        insert commInput;
        Test.startTest();
        AC_CalculateGoalController.calculateGoal(gp.Id);
        Test.stopTest();

        agileComp__Goal_Detail__c upgoal = [SELECT Id,agileComp__Split_Ext_GP__c,agileComp__Split_Ext_Sales__c FROM agileComp__Goal_Detail__c];
        System.assertEquals(1.25, upgoal.agileComp__Split_Ext_GP__c);
        System.assertEquals(5.00, upgoal.agileComp__Split_Ext_Sales__c);
    }
}