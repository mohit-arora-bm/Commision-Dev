public with sharing class AC_TemplateConfigController {
   
    public static Map<String,List<AC_OptionWrapper>> dataTypeOptionMap = new Map<String,List<AC_OptionWrapper>>();

    @AuraEnabled
    public static Map<String,List<AC_OptionWrapper>> getDataTypeOptionMap(){
        return dataTypeOptionMap;
    }

    @AuraEnabled
    public static TableConfigWP getTemplateConfigData(String templateId) {
        try { 
            TableConfigWP tableConfig = new TableConfigWP();
            tableConfig.isScheduled = false;
            if(String.isNotBlank(templateId)) {
                
                AC_SecurityUtils.checkRead( agileComp__AC_Templates_Config__c.SObjectType,new List<String> {
                    'Name',
                    'agileComp__AC_Name__c',
                    'agileComp__AC_Object__c',
                    'agileComp__AC_TemplateDataJson__c',
                    'agileComp__AC_SuccessDateMap__c'
                });

                List<agileComp__AC_Templates_Config__c> templateConfigList = [SELECT Id, Name, 
                                                                                agileComp__AC_Name__c, 
                                                                                agileComp__AC_Object__c, 
                                                                                agileComp__AC_TemplateDataJson__c,
                                                                                agileComp__AC_SuccessDateMap__c
                                                                            FROM agileComp__AC_Templates_Config__c 
                                                                            WHERE Id =: templateId];

                tableConfig.templateConfigObject = templateConfigList != null && !templateConfigList.isEmpty() && templateConfigList[0] != null ? templateConfigList[0] : new agileComp__AC_Templates_Config__c();
                if(tableConfig.templateConfigObject != null && String.isNotBlank(tableConfig.templateConfigObject.agileComp__AC_Object__c)) {
                    tableConfig.fieldsList = fetchDescribedFields( tableConfig.templateConfigObject.agileComp__AC_Object__c);
                }
                List<CronTrigger> jobs = [SELECT Id , CronJobDetail.Id  FROM CronTrigger WHERE CronJobDetail.Name = : templateConfigList[0].agileComp__AC_Name__c];
                if (!jobs.isEmpty()) {
                    tableConfig.isScheduled = true;
                }
                if (!String.isEmpty(templateConfigList[0].agileComp__AC_SuccessDateMap__c)) {
                    Map<Integer,Datetime> oldDateMap = (Map<Integer,Datetime>)JSON.deserialize(templateConfigList[0].agileComp__AC_SuccessDateMap__c, Map<Integer,Datetime>.class);
                    List<Datetime> oldDates = oldDateMap.values();
                    oldDates.sort();
                    tableConfig.lastSuccessDate = oldDates[0];
                }
            } else {
                tableConfig.templateConfigObject = new agileComp__AC_Templates_Config__c();
            }
            tableConfig.dataTypeOptionMap = dataTypeOptionMap;
            Map<String,Schema.SObjectField> sObjectFieldMap = Schema.getGlobalDescribe().get('agileComp__commissionBaseInput__c').getDescribe().fields.getMap(); 
            tableConfig.mappingFields = fetchDescribedFields(sObjectFieldMap);       
            System.debug(tableConfig);
            return tableConfig;
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage() + Label.AC_Error_Separator + ex.getStackTraceString());
        }
    }
    
    public static List<DescribeFieldWrapper> fetchDescribedFields(Map<String,Schema.SObjectField> sObjectFieldMap){
        List<DescribeFieldWrapper> fieldWrapper = new List<DescribeFieldWrapper>();
        for(String sobjectField : sObjectFieldMap.keyset()){    
            Schema.DescribeFieldResult fieldDescribed = sObjectFieldMap.get(sobjectField).getDescribe();
           
            if (fieldDescribed.isUpdateable()) {
                fieldWrapper.add(new DescribeFieldWrapper(fieldDescribed.getLabel(),fieldDescribed.getName(),String.valueof(fieldDescribed.getType())));
            }
        }
        fieldWrapper.sort();
        return fieldWrapper;
    }

    @AuraEnabled
    public static String returnFieldDataType(String selectedFieldJSON, String objectAPIName) {
        try {
            FieldMetaWrapper fieldResponseToReturn = new FieldMetaWrapper();
            DescribeFieldResult fieldResult;
            SelectedFieldWrapper selectedField = (SelectedFieldWrapper) JSON.deserialize(selectedFieldJSON, SelectedFieldWrapper.class);
            
            
            Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
            Schema.SObjectType targetType = globalDescribeMap.get(objectAPIName);
            Map<String, Schema.SObjectField> sobjectFieldMap = targetType.getDescribe().fields.getMap();

            if(!selectedField.isFieldRelated) {
                fieldResult = sobjectFieldMap.get(selectedField.selectedOption).getDescribe();
                fieldResponseToReturn.dataType = String.valueOf(fieldResult.getType());
                fieldResponseToReturn.isSortable = fieldResult.isSortable();
                if(String.valueOf(fieldResult.getType()).toLowerCase() == 'reference' ){
                fieldResponseToReturn.relatedObjectName = String.valueOf(fieldResult.getReferenceTo()[0].getDescribe().getName());
                 }
                fieldResponseToReturn.fieldLabel = fieldResult.getLabel();
                //return String.valueOf(sobjectFieldMap.get(selectedField.selectedOption).getDescribe().getType());
                return JSON.serialize(fieldResponseToReturn);
            } else {
                
                SObjectField sobjField = getField(targetType, selectedField.selectedOptionObj.relatedField);
                
                if(sobjField != NULL ) 
                    fieldResult = sobjField.getDescribe();
                fieldResponseToReturn.dataType = String.valueOf(fieldResult.getType());
                fieldResponseToReturn.isSortable = fieldResult.isSortable();
                if(String.valueOf(fieldResult.getType()).toLowerCase() == 'reference' ){
                    fieldResponseToReturn.relatedObjectName = String.valueOf(fieldResult.getReferenceTo()[0].getDescribe().getName());
                }
                fieldResponseToReturn.fieldLabel = fieldResult.getLabel();
                return JSON.serialize(fieldResponseToReturn);
                //return String.valueOf(sobjField.getDescribe().getType());
            }
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage() + Label.AC_Error_Separator + ex.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String saveTemplateData(String templateId, String templateName, String objectName, String dataJson, String className){
        
        agileComp__AC_Templates_Config__c tempConfig = new agileComp__AC_Templates_Config__c();
        try {
            if(String.isNotBlank(templateId)) {
                tempConfig.id = templateId;
            }
            List<AC_SchedulerTemplateController.DataListWrapper> dataList = (List<AC_SchedulerTemplateController.DataListWrapper>)JSON.deserialize(dataJson,List<AC_SchedulerTemplateController.DataListWrapper>.class);
            List<String> JSONStrs = new List<String>();   
                            
            Integer index = 1;
            for (AC_SchedulerTemplateController.DataListWrapper obj : dataList) {
                String str = JSON.serialize(obj);
                // Implement any logic to be scheduled
                String query = AC_SchedulerTemplateController.queryGenerator(str, objectName, index, templateId);
                database.query(query + ' LIMIT 1');
                index++;
            }
            tempConfig.agileComp__AC_Name__c = templateName;
            tempConfig.Name = templateName;
            if (String.isEmpty(templateId)) {
                tempConfig.agileComp__AC_BatchClassName__c = className;
            }
            
            tempConfig.agileComp__AC_Object__c = objectName;
            tempConfig.agileComp__AC_TemplateDataJson__c = dataJson;

            AC_SecurityUtils.checkUpdate( agileComp__AC_Templates_Config__c.SObjectType,new List<String> {
                'agileComp__AC_Name__c',
                'agileComp__AC_Object__c',
                'agileComp__AC_TemplateDataJson__c',
                'agileComp__AC_BatchClassName__c'
                });
            AC_SecurityUtils.checkInsert( agileComp__AC_Templates_Config__c.SObjectType,new List<String> {
                'agileComp__AC_Name__c',
                'agileComp__AC_Object__c',
                'agileComp__AC_TemplateDataJson__c',
                'agileComp__AC_BatchClassName__c'
                });

            upsert tempConfig;
            // SaveResult saveR = new SaveResult();
            // saveR.sessionId = 'getSessionIdFromVFPage()';
            // saveR.templateId = tempConfig.id;
            return tempConfig.id;
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage() + Label.AC_Error_Separator + ex.getStackTraceString());
        }
    }

    public static String getSessionIdFromVFPage() {
        if(!Test.isRunningTest()){
            String SESSION_ID_START = 'SESSION_ID_START';
            String SESSION_ID_END = 'SESSION_ID_END';
            String pageContent = Page.SessionIdPage.getContent().toString();
            Integer startIndex = pageContent.indexOf(SESSION_ID_START) + SESSION_ID_START.length();
            Integer endIndex = pageContent.indexOf(SESSION_ID_END);
            return pageContent.substring(startIndex, endIndex);
        }
        else{
            return UserInfo.getSessionId();
        }
    }

    @AuraEnabled
    public static List<DescribeFieldWrapper> fetchDescribedFields(String sObjectName){
        Map<String,Schema.SObjectField> sObjectFieldMap = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
        List<DescribeFieldWrapper> fieldWrapper = new List<DescribeFieldWrapper>();
        for(String sobjectField : sObjectFieldMap.keyset()){
            Schema.DescribeFieldResult fieldDescribed = sObjectFieldMap.get(sobjectField).getDescribe();
            // if (fieldDescribed.isGroupable() || String.valueof(fieldDescribed.getType()) == 'CURRENCY' || String.valueof(fieldDescribed.getType()) == 'DOUBLE' || String.valueof(fieldDescribed.getType()) == 'INTEGER') {
                DescribeFieldWrapper fieldObj = new DescribeFieldWrapper(fieldDescribed.getLabel(),fieldDescribed.getName(),String.valueof(fieldDescribed.getType()),fieldDescribed.isHtmlFormatted(),false,false,fieldDescribed.isSortable());
                if(String.valueOf(fieldDescribed.getType()).toLowerCase() == 'reference' ){
                    List<Schema.sObjectType> sobjectTypeList = fieldDescribed.getReferenceTo();
                    String relationshipName = fieldDescribed.getRelationshipName();
                    if(!sobjectTypeList.isEmpty() && String.isNotBlank(relationshipName) && sobjectTypeList[0].getDescribe().getName() != null){
                        fieldObj.relatedObjectName = String.valueOf(sobjectTypeList[0].getDescribe().getName());
                        fieldWrapper.add(new DescribeFieldWrapper(fieldDescribed.getLabel(),fieldDescribed.getName(),String.valueof(fieldDescribed.getType()),fieldDescribed.isHtmlFormatted(),
                                false,false,fieldDescribed.isSortable(),String.valueOf(sobjectTypeList[0].getDescribe().getName()),relationshipName));
                    }    
                }
                fieldWrapper.add(fieldObj);
            }
        // }
        fieldWrapper.sort();
        return fieldWrapper;
    }
    @AuraEnabled
    public static void testNow( String recordId ){
        // try{
        agileComp__AC_Templates_Config__c template = [SELECT Id, Name,
                                                            agileComp__AC_Name__c, 
                                                            agileComp__AC_Object__c, 
                                                            agileComp__AC_TemplateDataJson__c,
                                                            agileComp__AC_BatchClassName__c 
                                                            FROM agileComp__AC_Templates_Config__c
                                                            WHERE Id = : recordId];

        List<AC_SchedulerTemplateController.DataListWrapper> dataList = (List<AC_SchedulerTemplateController.DataListWrapper>)JSON.deserialize(template.agileComp__AC_TemplateDataJson__c,List<AC_SchedulerTemplateController.DataListWrapper>.class);
        List<String> JSONStrs = new List<String>();   
        for (AC_SchedulerTemplateController.DataListWrapper obj : dataList) {
            String str = JSON.serialize(obj);
            JSONStrs.add(str);
        }
        String query = AC_SchedulerTemplateController.queryGenerator(JSONStrs[0], template.agileComp__AC_Object__c, 1, recordId);
        System.debug('query Schedule'+query);
        System.debug(template.agileComp__AC_BatchClassName__c);
        String errorMessage = 'This template has no batch to run. Please try by creating new one.';
        if (String.isEmpty(template.agileComp__AC_BatchClassName__c)) {
            throw new AuraHandledException(errorMessage + Label.AC_Error_Separator + errorMessage);
        }
        // We now call the batch class to be scheduled
        // TemplateBatch b = new TemplateBatch(JSONStrs, template.agileComp__AC_Object__c, query, 1, recordId);

        Type customType = Type.forName(template.agileComp__AC_BatchClassName__c);
        System.debug(customType);
        if (customType == null) {
            throw new AuraHandledException(errorMessage + Label.AC_Error_Separator + errorMessage);
        }
        AC_BatchInterface instance = (AC_BatchInterface)customType.newInstance();
        instance.setVariables(JSONStrs, template.agileComp__AC_Object__c, query, 1, recordId,UserInfo.getUserId());
        
        database.executebatch(instance,200);
        // } catch(Exception ex) {
        //     throw new AuraHandledException(ex.getMessage() + Label.AC_Error_Separator + ex.getStackTraceString());
        // }
    }
    public static SObjectField getField(SObjectType sObjectType, String fieldPath) {
                
        Map<SObjectType, Map<String, SObjectField>> fields = new Map<SObjectType, Map<String, SObjectField>>();
        if (sObjectType == null || fieldPath == null) return null;
        if (!fields.containsKey(sObjectType)) {
            fields.put(sObjectType, sObjectType.getDescribe().fields.getMap());
        }
        if (!fieldPath.contains('.')) {
            SObjectField ret = fields.get(sObjectType).get(fieldPath);
            return ret;
        }

        RelationshipWrapper relation = new RelationshipWrapper(fieldPath.substringBefore('.'));
        SObjectField field = fields.get(sObjectType).get(relation.getFieldPath());
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
        if (field == null || !fieldDescribe.isAccessible()) return null;

        SObjectType parentType = field.getDescribe().getReferenceTo()[0];
        return getField(parentType, fieldPath.substringAfter('.'));
    }

    public class RelationshipWrapper {
        public String name;
        public RelationshipWrapper(String name) {
            this.name = name; 
        }
        public String getFieldPath() {
            if(name == null) {
                return null;
            }
            return name.endsWith('__r') ? name.replace('__r', '__c') : name + 'Id';
        }
    }

    // public class SaveResult {
    //     @AuraEnabled public String templateId;
    //     @AuraEnabled public String sessionId;
    // }

    public class DescribeFieldWrapper implements Comparable {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String displayType;
        @AuraEnabled public Boolean isHTMLFormatted;
        @AuraEnabled public Boolean disabled;
        @AuraEnabled public Boolean isSelected;
        @AuraEnabled public Boolean isSortable;
        @AuraEnabled public Boolean isRelated = false;
        @AuraEnabled public String relatedObjectName ;
        @AuraEnabled public String relationshipName ; 
        

        public describeFieldWrapper(string label, String value, String displayType, Boolean isHTMLFormatted, Boolean disabled, Boolean isSelected, Boolean isSortable) {
            this.label= label;
            this.value = value;
            this.displayType = displayType;
            this.isHTMLFormatted = isHTMLFormatted;
            this.disabled = disabled;
            this.isSelected = isSelected;
            this.isSortable = isSortable;
        }
        public describeFieldWrapper(string label, String value, String displayType) {
            this.label= label;
            this.value = value;
            this.displayType = displayType;
        }
        public describeFieldWrapper(string label, String value, String displayType, Boolean isHTMLFormatted, Boolean disabled, 
                Boolean isSelected, Boolean isSortable,String relatedObjectName,String relationshipName) {
            this.label= label;
            this.value = value+'-';
            this.displayType = displayType;
            this.isHTMLFormatted = isHTMLFormatted;
            this.disabled = disabled;
            this.isSelected = isSelected;
            this.isSortable = isSortable;
            this.isRelated          =   true;
            this.relatedObjectName  =   relatedObjectName;
            this.relationshipName   =   relationshipName; 
        }

        public Integer compareTo(Object compareToObj) {
	        DescribeFieldWrapper compareToPro = (DescribeFieldWrapper)compareToObj;
	        if(compareToPro.label.isNumeric()) {
	        	
	        	if (Integer.valueof(this.label) == Integer.valueof(compareToPro.label)) return 0;
	        	if (Integer.valueof(this.label) > Integer.valueof(compareToPro.label)) return 1;
	        	return -1;
	        }
	        if (this.label == compareToPro.label) return 0;
	        if (this.label > compareToPro.label) return 1;
	        return -1;
	    }
    }

    public class FieldMetaWrapper {
        public String relationshipName;
        public String relatedObjectName;
        public Boolean isUpdateable;
        public Boolean isRelated;
        public String fieldLabel;
        public String fieldAPIName;
        public String dataType;
        public Boolean isSortable;
    }

    public class SelectedFieldWrapper {
        public Boolean isFieldRelated;
        public String selectedOption;
        public SelectedOptionWrapper selectedOptionObj;
        public Integer index;
    }

    public class SelectedOptionWrapper {
        public String relatedField;
        public FieldMetaWrapper fieldMeta;
    }

    public class TableConfigWP {
        @AuraEnabled public List<DescribeFieldWrapper> fieldsList; 
        @AuraEnabled public List<DescribeFieldWrapper> mappingFields; 
        @AuraEnabled public agileComp__AC_Templates_Config__c templateConfigObject;
        @AuraEnabled public Boolean isScheduled;
        @AuraEnabled public Map<String,List<AC_OptionWrapper>> dataTypeOptionMap;
        @AuraEnabled public Datetime lastSuccessDate;
    }

    public class AC_OptionWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public AC_OptionWrapper(String label,String value){
            this.label = label;
            this.value = value;
        }
    }
    static{
    	List<AC_OptionWrapper> pickListTypeList = new List<AC_OptionWrapper>{
		    new AC_OptionWrapper('Includes','Includes'),
		    new AC_OptionWrapper('Excludes','Excludes'),
            new AC_OptionWrapper('Equals','EqualTo'),
		    new AC_OptionWrapper('Does not equal','NotEqualTo')
		};

        List<AC_OptionWrapper> idTypeList = new List<AC_OptionWrapper>{
		    new AC_OptionWrapper('Equals','EqualTo'),
		    new AC_OptionWrapper('Does not equal','NotEqualTo')
		};

		List<AC_OptionWrapper> stringTypeList = new List<AC_OptionWrapper>{
		    new AC_OptionWrapper('Equals','EqualTo'),
		    new AC_OptionWrapper('Does not equal','NotEqualTo'),
		    new AC_OptionWrapper('Contains','Contains'),
            new AC_OptionWrapper('Not Contains','NotContains')
		};
		List<AC_OptionWrapper> notStringTypeList = new List<AC_OptionWrapper>{
		    new AC_OptionWrapper('Equals','EqualTo'),
		    new AC_OptionWrapper('Does not equal','NotEqualTo'),
		    new AC_OptionWrapper('Greater than','GreaterThan'),  
		    new AC_OptionWrapper('Greater than or equal','GreaterThanOrEqualTo'), 
		    new AC_OptionWrapper('Less than','LessThan'),
		    new AC_OptionWrapper('Less than or equal','LessThanOrEqualTo')
		};
        dataTypeOptionMap.put('currency',notStringTypeList);
        dataTypeOptionMap.put('date', notStringTypeList);
        dataTypeOptionMap.put('datetime',notStringTypeList);
        dataTypeOptionMap.put('double',notStringTypeList);
        dataTypeOptionMap.put('integer',notStringTypeList);
        dataTypeOptionMap.put('long',notStringTypeList);
        dataTypeOptionMap.put('percent',notStringTypeList);
        dataTypeOptionMap.put('time',notStringTypeList); 
        
        dataTypeOptionMap.put('id',idTypeList);  
        dataTypeOptionMap.put('reference',idTypeList);  
        dataTypeOptionMap.put('boolean',idTypeList);
        
        dataTypeOptionMap.put('email',stringTypeList);  
        dataTypeOptionMap.put('multipicklist',idTypeList); 
        dataTypeOptionMap.put('picklist',idTypeList); 
        dataTypeOptionMap.put('phone',stringTypeList);
        dataTypeOptionMap.put('string',stringTypeList);
        dataTypeOptionMap.put('url',stringTypeList);
        
        dataTypeOptionMap.put('address',null);
        dataTypeOptionMap.put('anytype',null);
        dataTypeOptionMap.put('base64',null);
        
        dataTypeOptionMap.put('combobox',null);
        dataTypeOptionMap.put('datacategorygroupreference',null);
        dataTypeOptionMap.put('encryptedstring',null);
        dataTypeOptionMap.put('textarea',stringTypeList);
    } 
}