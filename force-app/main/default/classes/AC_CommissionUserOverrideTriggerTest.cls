@isTest
private with sharing class AC_CommissionUserOverrideTriggerTest  {
    
    @isTest 
    private static void testTriggerInsert() {
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
        
        List<agileComp__Commision_User_Override__c> uOvers = new List<agileComp__Commision_User_Override__c>();
        agileComp__Commision_User_Override__c uOver = new agileComp__Commision_User_Override__c(
            agileComp__Commission_Attainment_Schedule_Override__c = schedule.Id,
            agileComp__Commission_Sales_Rep__c = salesRep.Id,
            agileComp__Active__c = true,
            agileComp__Begin_Date__c = System.today(),
            agileComp__End_Date__c = System.today().addDays(4)
        );
        uOvers.add(uOver);
        agileComp__Commision_User_Override__c uOver2 = new agileComp__Commision_User_Override__c(
            agileComp__Commission_Attainment_Schedule_Override__c = schedule.Id,
            agileComp__Commission_Sales_Rep__c = salesRep.Id,
            agileComp__Active__c = true,
            agileComp__Begin_Date__c = System.today(),
            agileComp__End_Date__c = System.today().addDays(4)
        );
        uOvers.add(uOver2);
        Test.startTest();
        try {
            insert uOvers;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains('There should be only one active Commision User Override with selected Commission Sales Rep'));
        }
        
        Test.stopTest();

    }
    @isTest 
    private static void testTriggerUpdate() {
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
        List<agileComp__Commision_User_Override__c> uOvers = new List<agileComp__Commision_User_Override__c>();
        agileComp__Commision_User_Override__c uOver = new agileComp__Commision_User_Override__c(
            agileComp__Commission_Attainment_Schedule_Override__c = schedule.Id,
            agileComp__Commission_Sales_Rep__c = salesRep.Id,
            agileComp__Active__c = true,
            agileComp__Begin_Date__c = System.today(),
            agileComp__End_Date__c = System.today().addDays(4)
        );
        uOvers.add(uOver);
        agileComp__Commision_User_Override__c uOver2 = new agileComp__Commision_User_Override__c(
            agileComp__Commission_Attainment_Schedule_Override__c = schedule.Id,
            agileComp__Commission_Sales_Rep__c = salesRep.Id,
            agileComp__Active__c = false,
            agileComp__Begin_Date__c = System.today(),
            agileComp__End_Date__c = System.today().addDays(4)
        );
        uOvers.add(uOver2);
        insert uOvers;
        Test.startTest();
        uOver2.agileComp__Active__c = true;
        try {
            update uOver2;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains('There should be only one active Commision User Override with selected Commission Sales Rep'));
        }
        
        Test.stopTest();

    }
}