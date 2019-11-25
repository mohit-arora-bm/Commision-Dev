public class AC_DynamicObjectLookUpController {
	
    @AuraEnabled
    public static String getDynamicOjectList(String searchText,String selectedObject) {
        try{
            List<ObjectWrapper> wrapperList = new List<ObjectWrapper>();
            if(String.isNotBlank(selectedObject)){
                List<Schema.DescribeSObjectResult> describeResult = Schema.describeSObjects(new List<String>{selectedObject});
                ObjectWrapper wrapperObj = new ObjectWrapper( describeResult[0].getLabel(), describeResult[0].getName() );
                wrapperList.add(wrapperObj);
                return JSON.serialize( wrapperList );
            }
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
            //ProcessInstance.TargetObjectId.getDescribe().getReferenceTo()
            List<Schema.SObjectType> sobjectTypeList = new List<Schema.SObjectType>(gd.values());
            for(Integer i = 0 ; i < sobjectTypeList.size() ; i++) {
                
                if( String.isNotBlank(searchText) && String.valueOf(sobjectTypeList[i]).startsWithIgnoreCase(searchText)){
                    Schema.DescribeSObjectResult describeResult = sobjectTypeList[i].getDescribe();
                    if( describeResult.isAccessible() && !describeResult.isCustomSetting() && describeResult.isQueryable()){
                        ObjectWrapper wrapperObj = new ObjectWrapper( describeResult.getLabel(), describeResult.getName() );
                        wrapperList.add(wrapperObj);
                    }  
                    if(wrapperList.size() == 10){
                        break;
                    }
                }
            }
            System.debug(wrapperList);
            if(!wrapperList.isEmpty()){
                return JSON.serialize( wrapperList );
            }else {
                return NULL;        
            }
        }catch(Exception ex){AuraHandledException exceptionMessage = new AuraHandledException(ex.getMessage()); exceptionMessage.setMessage(ex.getMessage()); throw exceptionMessage; }
    }

    public class ObjectWrapper {
    	public String label;
    	public String value;
    	public ObjectWrapper( String label, String value){
    		this.label = label;
    		this.value = value;
    	}
    }
}