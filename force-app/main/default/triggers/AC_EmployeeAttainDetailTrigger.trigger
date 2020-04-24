trigger AC_EmployeeAttainDetailTrigger on agileComp__commissionEmployeeAttainedDetail__c (before update) {
    for (agileComp__commissionEmployeeAttainedDetail__c detail : Trigger.new) {
        if(detail.agileComp__Override_Percent__c != Trigger.oldMap.get(detail.Id).agileComp__Override_Percent__c) {
            if (detail.agileComp__Override_Percent__c != null && detail.agileComp__Override_Percent__c > 0) {
                detail.agileComp__Comm_Attained__c = (detail.agileComp__GP_Adjust__c + detail.agileComp__GP_Earned__c) * detail.agileComp__Override_Percent__c * 0.01;
            }
            else {
                detail.agileComp__Comm_Attained__c = (detail.agileComp__GP_Adjust__c + detail.agileComp__GP_Earned__c) * detail.agileComp__Original_Percent__c * 0.01;
            }
        }
    }
}