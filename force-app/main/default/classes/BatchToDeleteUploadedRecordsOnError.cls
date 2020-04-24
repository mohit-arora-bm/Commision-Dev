global with sharing class BatchToDeleteUploadedRecordsOnError implements Database.Batchable<sObject>, Database.Stateful {

    global List<String> uploadedRecordIds = new List<String>();

    global BatchToDeleteUploadedRecordsOnError( List<String> uploadedRecordIds ) {
        this.uploadedRecordIds = uploadedRecordIds;
    }

    global List<sObject> start(Database.BatchableContext BC){
        String objectName = Id.valueOf( uploadedRecordIds[0] ).getSObjectType().getDescribe().getName();
        String query = 'SELECT Id FROM '+objectName+' WHERE Id IN : uploadedRecordIds';
      return Database.query( query );
   }

   global void execute(Database.BatchableContext BC, List<sObject> sObjects){
       if(! sObjects.isEmpty() ) {
           delete sObjects;
           System.debug('DELETED');
       }
   }

   global void finish( Database.BatchableContext BC ) {
      System.debug('Deleted');
   }
}