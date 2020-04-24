@isTest
public with sharing class AC_CommissionTeamTrigger_Test {
    @isTest
    static void testTrigger() {  
        try {
            agileComp__CommissionPeriod__c commisionPeriod = new agileComp__CommissionPeriod__c(agileComp__isActive__c = true, agileComp__dateEnd__c = System.today()); 
            insert commisionPeriod;
            agileComp__Commission_Attainment_Schedule__c schedule = new agileComp__Commission_Attainment_Schedule__c(
                agileComp__Active__c = true,
                agileComp__Calculation_Type__c = 'Step',
                Name = 'Test Schedule'
            );
            insert schedule;    
    
            agileComp__Commission_Attainment_Schedule_Item__c scdItem = new agileComp__Commission_Attainment_Schedule_Item__c(
                agileComp__Amount_From__c = 0.1,
                agileComp__Amount_To__c = 10000,
                agileComp__Commission_Attainment_Schedule__c = schedule.Id,
                Name = '1',
                agileComp__Percent__c = 10
            );
            insert scdItem;
    
            agileComp__Commission_Team__c team = new agileComp__Commission_Team__c(
                agileComp__Active__c = true,
                agileComp__Commission_Attainment_Schedule__c = schedule.Id,
                agileComp__Team__c = TRUE,
                Name = 'Test Team',
                agileComp__Pay_All_Team_Members__c = true,
                agileComp__Team_Payment_Method__c = 'Total Team Contribution'
            );
            insert team;
            agileComp__Commission_Sales_Rep__c salesRep = new agileComp__Commission_Sales_Rep__c(
                agileComp__isActive__c = true,
                agileComp__Sales_Rep__c = UserInfo.getUserId(),
                agileComp__Commission_Team__c = team.Id,
                Name = 'Test User'
                ); 
            insert salesRep;
            agileComp__Commision_User_Override__c uOver = new agileComp__Commision_User_Override__c(
                agileComp__Commission_Attainment_Schedule_Override__c = schedule.Id,
                agileComp__Commission_Sales_Rep__c = salesRep.Id,
                agileComp__Begin_Date__c = System.today(),
                agileComp__End_Date__c = System.today().addDays(4)
            );
            insert uOver;
            Test.startTest();
            try {
                team.agileComp__Team__c = true;
                team.agileComp__Team_Payment_Method__c = 'Individual Contribution';
                update team;
            } catch (Exception e) {
                system.debug('Error = '+e.getMessage());
            }                
            Test.stopTest();
    
    } catch (Exception es) {
        System.debug(es);
        System.debug(es.getStackTraceString());
    }
        
    }
}