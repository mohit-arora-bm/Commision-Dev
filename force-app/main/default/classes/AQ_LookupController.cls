public with sharing class AQ_LookupController {

    @AuraEnabled 
    public static String returnRecords( String objectName, String fieldApiName,
                                        String otherFields, String searchText ) {
        
        
        searchText = '\'%' + String.escapeSingleQuotes( searchText.trim() ) + '%\'';
        String query = '';
        if(otherFields != null && otherFields != '') {
            if(objectName == 'User') {
                query = 'SELECT Id, ' + otherFields + ',' + fieldApiName +
                        ' FROM ' + objectName +
                        ' WHERE ' + fieldApiName + ' LIKE ' + searchText +
                        ' AND isActive = true LIMIT 500';
            }
            else {
                query = 'SELECT Id, ' + otherFields + ',' + fieldApiName +
                            ' FROM ' + objectName +
                            ' WHERE ' + fieldApiName + ' LIKE ' + searchText +
                            ' LIMIT 500';
            }                
        }
        else {
            if(objectName == 'User') {
                query = 'SELECT Id, ' + fieldApiName +
                            ' FROM ' + objectName +
                            ' WHERE ' + fieldApiName + ' LIKE ' + searchText +
                            ' AND isActive = true LIMIT 500';
            }
            else {
                query = 'SELECT Id, ' + fieldApiName +
                                ' FROM ' + objectName +
                                ' WHERE ' + fieldApiName + ' LIKE ' + searchText +
                                ' LIMIT 500'; 
            } 
        }

        List<String> fieldList =  new List<String>();
        fieldList.add('Id');
        fieldList.add(fieldApiName);
         AQ_SecurityUtils.checkRead( Schema.getGlobalDescribe().get(objectName).getDescribe().getSobjectType(), fieldList);  
        List<sObject> sobjList = Database.query( query );
        List<ResultWrapper> listToReturn = new List<ResultWrapper>();
        ResultWrapper resultInstance;
        ResultWrapper innerResultInstance;
        for( sObject sobj : sobjList ) {
            resultInstance = new ResultWrapper();
            resultInstance.showText = String.valueOf( sobj.get( fieldApiName ) );
            resultInstance.val = String.valueOf( sobj.get( 'Id' ) );
            resultInstance.otherFieldsWrapper = new List<ResultWrapper>();
            if(otherFields != null && otherFields != '') {
                for( String otherField : otherFields.split( ',' ) ) {
                    innerResultInstance = new ResultWrapper();
                    innerResultInstance.showText = String.valueOf( sobj.get( otherField ) );
                    innerResultInstance.val = otherField;
                    resultInstance.otherFieldsWrapper.add( innerResultInstance );
                }
             }   
            listToReturn.add( resultInstance );
        }
        return JSON.serialize( listToReturn );
    }
    
    public class ResultWrapper {
        public String showText { get; set; }
        public String val { get; set; }
        public List<ResultWrapper> otherFieldsWrapper { get; set; }
    }
   
}