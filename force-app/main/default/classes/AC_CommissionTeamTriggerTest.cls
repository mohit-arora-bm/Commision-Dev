@isTest
public class AC_CommissionTeamTriggerTest {
	@isTest
    private static void testController() {
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
        agileComp__CommissionPeriod__c commisionPeriod = new agileComp__CommissionPeriod__c(agileComp__isActive__c = true,agileComp__dateStart__c=system.today().adddays(-5), agileComp__dateEnd__c = System.today().adddays(5)); 
        commisionPeriod.agileComp__Commission_Year_End__c = System.today().addDays(123);
        commisionPeriod.agileComp__Commission_Year_Start__c = System.today().addDays(-37);
        insert commisionPeriod;
        agileComp__Commission_Team__c team = new agileComp__Commission_Team__c(
            agileComp__Active__c = false,
            agileComp__Commission_Attainment_Schedule__c = schedule.Id,
            Name = 'Test Team',
            agileComp__Team__c = false,
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
          agileComp__Commision_User_Override__c uOver = new agileComp__Commision_User_Override__c(
            agileComp__Commission_Attainment_Schedule_Override__c = schedule.Id,
            agileComp__Commission_Sales_Rep__c = salesRep.Id,
            agileComp__Active__c = true,
            agileComp__Begin_Date__c = System.today().addDays(6),
            agileComp__End_Date__c = System.today().addDays(10)
        );
        insert uOver;
        team.agileComp__Active__c = true;
        team.agileComp__Team__c = true;
        update team;
    }
}