trigger AC_EmployeeAttainmentTrigger on agileComp__commissionEmployeeAttainedValue__c (after update) {
    List<String> eavIds = new List<String>();
    List<String> eavTeamGpIds = new List<String>();
    List<String> eavCommIds = new List<String>();
    
    for (agileComp__commissionEmployeeAttainedValue__c eav : Trigger.new) {
        if (eav.agileComp__GP_Adjustments__c != Trigger.oldMap.get(eav.Id).agileComp__GP_Adjustments__c) {
            
            eavIds.add(eav.Id);
        }
        if (eav.agileComp__Team_GP_Adjustment__c != Trigger.oldMap.get(eav.Id).agileComp__Team_GP_Adjustment__c) {
            eavTeamGpIds.add(eav.Id);
        }
        if (eav.agileComp__Original_Commission_Attained__c != Trigger.oldMap.get(eav.Id).agileComp__Original_Commission_Attained__c && 
            eav.agileComp__Commission_Period_Payout__c != null) {
            eavCommIds.add(eav.Id);
        }
    }
    if (!eavIds.isEmpty()) {
        AC_EmployeeAttainmentTriggerHelper.updateTeamAdjustment(Trigger.newMap,Trigger.oldMap);
    }
    if(eavTeamGpIds.size() > 0){
        AC_EmployeeAttainmentTriggerHelper.updateEAVDetails(AC_EmployeeAttainmentTriggerHelper.eavIdsList,Trigger.newMap,Trigger.oldMap);
    }
    if (!eavCommIds.isEmpty()) {
        AC_EmployeeAttainmentTriggerHelper.updateSystemGeneratedCommission(eavCommIds,Trigger.newMap);
    }
}