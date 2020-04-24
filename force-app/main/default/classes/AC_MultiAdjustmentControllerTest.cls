@isTest
public class AC_MultiAdjustmentControllerTest {
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
        agileComp__commissionBaseInput__c comp = new agileComp__commissionBaseInput__c(
            agileComp__Split_Percent__c = 100.0000,
            agileComp__Orig_Doc_Ext_Cost__c = 237393422.00,
            agileComp__Orig_Doc_Ext_Sales__c = 21312321,
            agileComp__Orig_Doc_Freight__c =1250,
            agileComp__Document_Date__c  =system.today(),
            agileComp__Commission_Sales_Rep__c = salesRep.id
        );
        insert comp;
        agileComp__commissionEmployeeAttainedValue__c eav = new agileComp__commissionEmployeeAttainedValue__c(
            agileComp__Commission_Attainment_Schedule__c = schedule.Id,
            agileComp__Commission_Sales_Rep__c = salesRep.Id,
            agileComp__Commission_Team__c = team.Id,
            agileComp__Year_Original_Revenue__c = 123143322,
            agileComp__Year_Original_Total_Coast__c =1234,
            agileComp__Year_Freight_Cost__c = 123222,
            agileComp__Original_Revenue__c=1234567,
            agileComp__Original_Total_Cost__c=12345,
            agileComp__Original_Freight_Cost__c=1234,
            agileComp__Commission_Period__c = commisionPeriod.Id
        );
        insert eav;
        agileComp__commissionAdjustmentDetail__c adjust = new agileComp__commissionAdjustmentDetail__c();
        adjust.agileComp__Type__c = 'Gross Profit';
        adjust.agileComp__Adjustment_Type__c = 'Gift Certificate.';
        adjust.agileComp__Adjustment_Amount__c = 100;
        adjust.agileComp__Adjustment_Description__c ='qwer';
        adjust.agileComp__Commission_Employee_Attained_Value_Recor__c=eav.id;
        insert adjust;
       List<agileComp__commissionAdjustmentDetail__c> lst =  AC_MultiAdjustmentController.fetchAdjustment(commisionPeriod.Id);
        List<agileComp__commissionAdjustmentDetail__c> newlst = new  List<agileComp__commissionAdjustmentDetail__c>();
          agileComp__commissionAdjustmentDetail__c newAdjust = new agileComp__commissionAdjustmentDetail__c();
        newAdjust.agileComp__Type__c = 'Gross Profit';
        newAdjust.agileComp__Adjustment_Type__c = 'Gift Certificate.';
        newAdjust.agileComp__Adjustment_Amount__c = 100;
        newAdjust.agileComp__Adjustment_Description__c ='qwer';
        newAdjust.agileComp__Commission_Employee_Attained_Value_Recor__c=eav.id;
        newlst.add(newAdjust);
        AC_MultiAdjustmentController.getEmployees();
        AC_MultiAdjustmentController.saveAdjustments(newlst);
        AC_PDFAccessController.getEmployeeAttainId(commisionPeriod.Id);
    }
}