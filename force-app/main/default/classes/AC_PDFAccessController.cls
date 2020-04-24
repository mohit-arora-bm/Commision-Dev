public with sharing class AC_PDFAccessController {
    @AuraEnabled 
    public static string getEmployeeAttainId(String periodId){
        try {
            List<agileComp__commissionEmployeeAttainedValue__c> eavs = [SELECT Id FROM agileComp__commissionEmployeeAttainedValue__c 
                                                                    WHERE agileComp__Commission_Period__c = : periodId
                                                                    AND agileComp__Commission_Sales_Rep__r.agileComp__Sales_Rep__c = :UserInfo.getUserId()];
            
            if (eavs.isEmpty()) {
                throw new AuraHandledException('There is no Commission Employee Attained Value for selected period');
            }
            return eavs[0].Id;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + Label.AC_Error_Separator + ex.getStackTraceString());
        }
        
    }
}