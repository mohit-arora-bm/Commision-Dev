@isTest
public class AC_EmployeeAdjustmentItemsTest {

    public static testMethod void setup(){
        
        // List<agileComp__commissionEmployeeAttainedDetail__c> empDetail = new List<agileComp__commissionEmployeeAttainedDetail__c>();
        // List<agileComp__commissionAdjustmentDetail__c> adjDraftValues = new List<agileComp__commissionAdjustmentDetail__c>();
        
        agileComp__CommissionPeriod__c commisionPeriod = new agileComp__CommissionPeriod__c(agileComp__isActive__c = true, agileComp__dateEnd__c = System.today()); 
        commisionPeriod.agileComp__Commission_Year_End__c = System.today().addDays(123);
        commisionPeriod.agileComp__Commission_Year_Start__c = System.today().addDays(-37);
        
        insert commisionPeriod;

        agileComp__Commission_Attainment_Schedule__c schedule = new agileComp__Commission_Attainment_Schedule__c(
            agileComp__Active__c = true,
            agileComp__Calculation_Type__c = 'Tier Attained',
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
            Name = 'Test Team',
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
        
        
        agileComp__commissionEmployeeAttainedValue__c empAttainVal = new agileComp__commissionEmployeeAttainedValue__c(
            agileComp__Best_of__c = false, 
            agileComp__Calculation_Type__c = 'Tier Attained', 
            agileComp__Commission_Period__c = commisionPeriod.id, 
            agileComp__Commission_Sales_Rep__c = salesRep.id,
            agileComp__Commission_Attainment_Schedule__c = schedule.Id,
            agileComp__Year_Original_Revenue__c = 123143322,
            agileComp__Year_Original_Total_Coast__c =1234,
            agileComp__Year_Freight_Cost__c = 123222,
            agileComp__Commission_Team__c = team.Id,
            agileComp__Team_Payout_Method__c = 'Individual Contribution'
        ); 
        insert empAttainVal;

        agileComp__commissionEmployeeAttainedDetail__c ead = new agileComp__commissionEmployeeAttainedDetail__c(
            agileComp__Comm_Attained__c = 10, 
            agileComp__GP_Adjust__c = 12, 
            agileComp__From__c = 10, 
            agileComp__To__c = 12, 
            agileComp__Commission_Employee_Attained_Value__c = empAttainVal.id,
            agileComp__GP_Earned__c = 10,
            agileComp__Commission_Attainment_Schedule_Item__c = scdItem.Id,
            agileComp__Original_Percent__c = 10
        );
        insert ead;

        agileComp__commissionAdjustmentDetail__c adj = new agileComp__commissionAdjustmentDetail__c(
            agileComp__Commission_Employee_Attained_Value_Recor__c = empAttainVal.id, 
            agileComp__Adjustment_Description__c = 'test', 
            agileComp__Adjustment_Amount__c = 10, 
            agileComp__Adjustment_Type__c = 'Misc GP Adjustment',
            agileComp__Type__c = 'Gross Profit'
            
         );   

        insert adj;
        test.startTest();
            ead.agileComp__Override_Percent__c = 8;
            adj.agileComp__Adjustment_Amount__c = 100;
            adj.Id = null;
        	AC_EmployeeAdjustmentItems.getData();
        	AC_EmployeeAdjustmentItems.getEmployeeAttains(commisionPeriod.Id, salesRep.Id);
        	AC_EmployeeAdjustmentItems.saveRecords(new List<agileComp__commissionEmployeeAttainedDetail__c>{ead}, new List<agileComp__commissionAdjustmentDetail__c>{adj}, new List<String>{adj.Id}, team.Id, commisionPeriod.Id);
            adj.agileComp__Adjustment_Amount__c = -100;
            adj.Id = null;
            upsert adj;
            adj.agileComp__Adjustment_Amount__c = 100;
            upsert adj;
        test.stopTest();
    }
}