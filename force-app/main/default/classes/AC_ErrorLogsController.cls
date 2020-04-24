public with sharing class AC_ErrorLogsController {
    @AuraEnabled
    public static List<AsyncApexJob> getErrors( String templateId, String filterDate ){
        try {
            
            AC_SecurityUtils.checkRead( agileComp__AC_Templates_Config__c.SObjectType,new List<String> {
                'agileComp__AC_BatchClassName__c'
            });	
            if (String.isNotEmpty(templateId)) {
                List<agileComp__AC_Templates_Config__c> configs = [SELECT Id,agileComp__AC_BatchClassName__c
                                                                    FROM agileComp__AC_Templates_Config__c 
                                                                    WHERE Id = : templateId];

                if (!configs.isEmpty() && !String.isEmpty(configs[0].agileComp__AC_BatchClassName__c)) {
                    String batchName = configs[0].agileComp__AC_BatchClassName__c;
                    String query = 'SELECT Id,Status, ExtendedStatus,CreatedDate from AsyncApexJob WHERE ApexClass.Name = : batchName ';
                    if (String.isNotEmpty(filterDate)) {

                        Datetime startDate = date.valueOf(filterDate);
                        Datetime endDate = startDate.addDays(1);
                        query += ' AND (CreatedDate > :startDate AND CreatedDate < : endDate) ';
                    }
                    query += ' order by CreatedDate DESC limit 20';
                    List<AsyncApexJob> batchJobs = Database.query(query);
                    return batchJobs;
                }
            }
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage() + Label.AC_Error_Separator + ex.getStackTraceString());
        }
        return null;
    }
}