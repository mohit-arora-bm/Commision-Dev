@isTest
public with sharing class AC_CommissionAttainScheduleTriggerTest {
    
    @isTest
    static void testTrigger() {
        agileComp__Commission_Attainment_Schedule__c schedule = new agileComp__Commission_Attainment_Schedule__c(
            agileComp__Active__c = true,
            agileComp__Calculation_Type__c = 'Tier Attained',
            Name = 'Test Schedule'
        );
        insert schedule;  
		agileComp__Commission_Attainment_Schedule_Item__c schdlItem = new agileComp__Commission_Attainment_Schedule_Item__c(
            agileComp__Commission_Attainment_Schedule__c = schedule.id,
            agileComp__Percent__c =10,
            agileComp__Amount_From__c = 10,
            agileComp__Amount_To__c=99999999
        );
        insert schdlItem;
        agileComp__Commission_Team__c team = new agileComp__Commission_Team__c(
            agileComp__Active__c = true,
            agileComp__Commission_Attainment_Schedule__c = schedule.Id,
            Name = 'Test Team',
            agileComp__Team__c = true,
            agileComp__Team_Payment_Method__c = 'Individual Contribution'
        );
        insert team;

        agileComp__Commission_Sales_Rep__c salesRep = new agileComp__Commission_Sales_Rep__c(
            agileComp__isActive__c = true,
            agileComp__Sales_Rep__c = UserInfo.getUserId(),
            agileComp__Commission_Team__c = team.Id,
            Name = 'Test User'
            ); 
        insert salesRep;
        
        agileComp__CommissionPeriod__c commisionPeriod = new agileComp__CommissionPeriod__c(agileComp__isActive__c = true, agileComp__dateEnd__c = System.today().addDays(3),agileComp__dateStart__c = System.today().addDays(2)); 
        commisionPeriod.agileComp__Commission_Year_End__c = System.today().addDays(123);
        commisionPeriod.agileComp__Commission_Year_Start__c = System.today().addDays(-37);
        insert commisionPeriod;
        
        agileComp__Commision_User_Override__c uOver = new agileComp__Commision_User_Override__c(
            agileComp__Commission_Attainment_Schedule_Override__c = schedule.Id,
            agileComp__Commission_Sales_Rep__c = salesRep.Id,
            agileComp__Begin_Date__c = System.today(),
            agileComp__End_Date__c = System.today().addDays(4)
        );
     
        Database.SaveResult srList = Database.insert(uOver, false);
        // System.assertEquals(true, srList.isSuccess());

        Test.startTest();
        
        schedule.agileComp__Calculation_Type__c = 'Step';
        try {
            update schedule;
        } catch (Exception e) {
            
        }
        
        Test.stopTest();
    }
    
}