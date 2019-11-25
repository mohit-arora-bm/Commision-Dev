global class AC_SelectLookUpFieldController {
	 @AuraEnabled
	global static String returnObjectFields(String objName,Integer selectedIndex) {
        if(!String.isEmpty(objName)){
            List<fieldWrapper> wrapperList = new List<fieldWrapper>();
            fieldWrapper wrapperObj;
            Map<string,SObjectField> fieldsList = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
            List<SObjectField> objectFields = fieldsList.values();
            for( SObjectField objectField : objectFields ) {
                Schema.DescribeFieldResult fieldDescribe = objectField.getDescribe();
                if( fieldDescribe.isAccessible()  
                    && !fieldDescribe.isExternalID()) {
                    wrapperObj = new fieldWrapper( fieldDescribe );    
                    if(String.valueOf(fieldDescribe.getType()).toLowerCase() == 'reference' && selectedIndex != null && selectedIndex < 3){
                        List<Schema.sObjectType> sobjectTypeList = fieldDescribe.getReferenceTo();
                        String relationshipName = fieldDescribe.getRelationshipName();
                        if(!sobjectTypeList.isEmpty() && String.isNotBlank(relationshipName) && sobjectTypeList[0].getDescribe().getName() != null){
                            wrapperObj.relatedObjectName = String.valueOf(sobjectTypeList[0].getDescribe().getName());
                            wrapperList.add(new fieldWrapper(String.valueOf(fieldDescribe.getLabel()),String.valueOf(fieldDescribe.getName()),true,String.valueOf(sobjectTypeList[0].getDescribe().getName()),relationshipName));               
                        }    
                    }
                    wrapperList.add(wrapperObj);
                }
            }
            if(!wrapperList.isEmpty()){
                wrapperList.sort();
                return JSON.serialize(wrapperList); 
            }
            return null;
        }
        return NULL;
    }


    global class fieldWrapper implements Comparable {
        @AuraEnabled
        public String fieldLabel;
        
        @AuraEnabled
        public String fieldAPIName;

        @AuraEnabled
        public String dataType;

        @AuraEnabled
        public Boolean isUpdateable;

        @AuraEnabled
        public Boolean isRelated = false;

        @AuraEnabled
        public String relatedObjectName;

        @AuraEnabled
        public String relationshipName;



        public fieldWrapper(Schema.DescribeFieldResult fldDescribe) {
            this.fieldLabel = fldDescribe.getLabel();
            this.fieldAPIName = fldDescribe.getName();
            this.isRelated = false;
            this.dataType = String.valueOf(fldDescribe.getType()).toLowerCase();
            this.isUpdateable = fldDescribe.isUpdateable();
            this.relatedObjectName = '';
            this.relationshipName = '';
        }

        public fieldWrapper(String fieldLabel,String fieldAPIName,Boolean isRelated,String relatedObjectName,String relationshipName) {
            this.fieldLabel        =  fieldLabel;
            this.fieldAPIName      =  fieldAPIName+'-';
            this.isRelated          =  true;
            this.relatedObjectName  =  relatedObjectName;
            this.relationshipName   =  relationshipName; 
            this.isUpdateable       = false;
        }

        global Integer compareTo( Object compareTo ) {
            fieldWrapper compareToObjectWrapper = ( fieldWrapper ) compareTo;
            if( fieldLabel > compareToObjectWrapper.fieldLabel ) { return 1; }
            if( fieldLabel == compareToObjectWrapper.fieldLabel ) { return 0; }
            return -1;
        }
    }
}