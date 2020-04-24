public with sharing class AC_MultiAdjustmentController {
    @AuraEnabled
    public static List<agileComp__commissionAdjustmentDetail__c> fetchAdjustment(String periodId){
        return [SELECT Id,agileComp__Commission_Employee_Attained_Value_Recor__r.Name,
                    agileComp__Type__c,  
                    agileComp__Adjustment_Type__c,
                    agileComp__Adjustment_Amount__c,
                    agileComp__Adjustment_Description__c
                FROM agileComp__commissionAdjustmentDetail__c
                WHERE agileComp__System_Generated__c = false];
    }

    @AuraEnabled
    public static List<agileComp__commissionEmployeeAttainedValue__c> getEmployees(){
        List<agileComp__CommissionPeriod__c> periods = [SELECT Id FROM agileComp__CommissionPeriod__c WHERE agileComp__isActive__c = true];
        if (periods.isEmpty()) {
            throw new AuraHandledException('There is no active period in system');
        }
        List<agileComp__commissionEmployeeAttainedValue__c> eavs = [SELECT Id,agileComp__Commission_Sales_Rep__c,
                                                                        agileComp__Commission_Sales_Rep__r.Name,
                                                                        agileComp__Commission_Period__c,
                                                                        agileComp__Commission_Period__r.Name
                                                                    FROM agileComp__commissionEmployeeAttainedValue__c
                                                                    WHERE agileComp__Commission_Period__c = : periods[0].Id];
        if (eavs.isEmpty()) {
            throw new AuraHandledException('There is no Commission Employee Atainment records in system');
        }
        return eavs;
    }

    @AuraEnabled
    public static void saveAdjustments(List<agileComp__commissionAdjustmentDetail__c> adjs){
        insert adjs;
    }
}