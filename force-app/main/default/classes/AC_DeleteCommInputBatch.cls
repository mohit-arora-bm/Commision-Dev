public with sharing class AC_DeleteCommInputBatch implements Database.Batchable<sObject>  {
    public final String Query;

   public AC_DeleteCommInputBatch(String q){
             Query=q; 
   }

   public Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }

   public void execute(Database.BatchableContext BC, List<sObject> scope){
      List<String> salesRepsId = new List<String>();
      for (sObject obj  : scope) {
         salesRepsId.add(String.valueOf(obj.get('agileComp__Commission_Sales_Rep__c')));
      }
      if (!salesRepsId.isEmpty()) {
         delete [SELECT Id FROM agileComp__Commission_Sales_Rep__c WHERE Id IN : salesRepsId];
      }
      delete scope;
   }

   public void finish(Database.BatchableContext BC){

   }
}