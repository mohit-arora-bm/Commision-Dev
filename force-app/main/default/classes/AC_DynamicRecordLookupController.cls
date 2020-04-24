public with sharing class AC_DynamicRecordLookupController {
    @AuraEnabled
    public static List < sObject > fetchRecords(String searchKeyWord, String ObjectName) {
        try {
            String searchKey = searchKeyWord + '%';
        
            List < sObject > returnList = new List < sObject > ();
        
            // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
            String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
            List < sObject > lstOfRecords = Database.query(sQuery);
            
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }
            return returnList;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + Label.AC_Error_Separator + ex.getStackTraceString());
        }
        
    }
}