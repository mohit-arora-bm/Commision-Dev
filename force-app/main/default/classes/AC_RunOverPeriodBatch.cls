public with sharing class AC_RunOverPeriodBatch implements Database.Batchable<sObject>, Database.Stateful {
    String query;
    String periodId;

    public AC_RunOverPeriodBatch(String query,String periodId) {
        this.query = query;
        this.periodId = periodId;
    }
    // The batch job starts
    public Database.QueryLocator start(Database.BatchableContext bc){
        //String query = 'SELECT Id, Name FROM Account';
        System.debug('>>>> start ' + query);
        return Database.getQueryLocator(query);
    } 
    
    // The batch job executes and operates on one batch of records
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        try {
            System.debug('socpe>>'+scope);
            AC_RunOverPeriodController.createCommEmploye((List<agileComp__Commission_Team__c>) scope,periodId);
        } catch (Exception e) {
            AC_DataService.logException(e.getMessage(), e.getStackTraceString());
        }
    }
    
    // The batch job finishes
    public void finish(Database.BatchableContext bc){
       
    }
}