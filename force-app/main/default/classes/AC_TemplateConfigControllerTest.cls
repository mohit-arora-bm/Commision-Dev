@isTest
public class AC_TemplateConfigControllerTest {

    public static testMethod void setup(){
        List<agileComp__AC_Templates_Config__c> templateConfig = new List<agileComp__AC_Templates_Config__c>();
        Map<Integer,Datetime> mapTemplate = new Map<Integer,Datetime>();
        Map<String,List<AC_TemplateConfigController.AC_OptionWrapper>> dataTypeOptionMap = AC_TemplateConfigController.getDataTypeOptionMap();
        for(Integer i = 0; i < 5; i++){
            agileComp__AC_Templates_Config__c temp = new agileComp__AC_Templates_Config__c();
            DateTime myDateTime = DateTime.newInstance(2021, 2, 11, 8, 6, 16);
            mapTemplate.put(i, myDateTime);
            temp.agileComp__AC_Name__c = 'agileComp__AC_Name__c' + i;
            temp.agileComp__AC_Object__c = 'agileComp__AC_Object__c' + i;
            temp.agileComp__AC_TemplateDataJson__c = '{"selectedFieldOptions":[{"customLabel":"Id","selectedField":"Id","dataType":"text","func":"","apexDataType":"ID","isFieldRelated":false,"selectedFieldObj":{},"mapping":"agileComp__Account__c","relatedObjectName":null}],"selectedFilters":[{"operations":[{"label":"Equals","value":"EqualTo"},{"label":"Does not equal","value":"NotEqualTo"}],"label":"","fieldType":"text","filterValue":null,"operation":"NotEqualTo","selectedField":"Id","isFieldRelated":false,"dataType":"text","apexDataType":"ID","customLabel":"Id","relatedObjectName":null}],"description":"1","documentField":{"isFieldRelated":false,"selectedField":"Id","relatedObjectName":null},"accountField":{"isFieldRelated":false,"selectedField":""},"isOpen":false,"filterOptions":[],"selectedFilterCombo":"AND","filterCombo":"","isCustom":false,"hasError":false}';
            temp.agileComp__AC_SuccessDateMap__c = JSON.serialize(mapTemplate);
            temp.agileComp__AC_BatchClassName__c = 'AC_BatchInterface' ;
            templateConfig.add(temp);
        }
        insert templateConfig;
		
        CronJobDetail cronjobdetail = new CronJobDetail();
        CronTrigger cronTriger = new CronTrigger();
        
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType ObjSchema = schemaMap.get('agileComp__AC_Templates_Config__c');
        Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();
        Schema.sObjectType sobj = agileComp__AC_Templates_Config__c.sObjectType;
        
        test.startTest();
        try {
            try{
            AC_TemplateConfigController.getTemplateConfigData(templateConfig[0].id);
            }catch(Exception e){
                
            }
            AC_TemplateConfigController.fetchDescribedFields(fieldMap);
        	AC_TemplateConfigController.fetchDescribedFields('agileComp__AC_Templates_Config__c');
        	AC_TemplateConfigController.getField(sobj, '');
            
        	
            String jsonFieldsData = '{"selectedOptionObj":{"relatedField":null,"fieldMeta":{"relationshipName":null,"relatedObjectName":null,"isUpdateable":false,"isRelated":true,"fieldLabel":"AnnualRevenue","fieldAPIName":"AnnualRevenue","dataType":null,"isSortable":null}},"isFieldRelated":false,"selectedOption":"AnnualRevenue","index":"0"}';
            AC_TemplateConfigController.returnFieldDataType(jsonFieldsData, 'Account');
           // String jsonFieldsData1 = '{"selectedOptionObj":{"relatedField":null,"fieldMeta":{"relationshipName":null,"relatedObjectName":null,"isUpdateable":true,"isRelated":true,"fieldLabel":"AnnualRevenue","fieldAPIName":"AnnualRevenue","dataType":null,"isSortable":null}},"isFieldRelated":true,"selectedOptionObj":{"relatedField":"Parent.AnnualRevenue","fieldMeta":{"relationshipName":"AnnualRevenue","relatedObjectName":"","isUpdateable":true,"isRelated":false,"fieldLabel":"Annual Revenue","fieldAPIName":"AnnualRevenue","dataType":"currency"},"fieldApiName":"ParentId-","eventAdditionalParam":{"type":"Field","index":null}},"selectedOption":"AnnualRevenue","index":"0"}';
           // AC_TemplateConfigController.returnFieldDataType(jsonFieldsData1, 'Account');
        	
            jsonFieldsData = '{"isFieldRelated":true,"selectedOption":"{\"relatedField\":\"Parent.AnnualRevenue\",\"fieldMeta\":{\"relationshipName\":\"AnnualRevenue\",\"relatedObjectName\":\"\",\"isUpdateable\":true,\"isRelated\":false,\"fieldLabel\":\"Annual Revenue\",\"fieldAPIName\":\"AnnualRevenue\",\"dataType\":\"currency\"},\"fieldApiName\":\"ParentId-\",\"eventAdditionalParam\":{\"type\":\"Field\",\"index\":null}}","selectedOptionObj":{"relatedField":"Parent.AnnualRevenue","fieldMeta":{"relationshipName":"AnnualRevenue","relatedObjectName":"","isUpdateable":true,"isRelated":false,"fieldLabel":"Annual Revenue","fieldAPIName":"AnnualRevenue","dataType":"currency"},"fieldApiName":"ParentId-","eventAdditionalParam":{"type":"Field","index":null}},"index":2,"type":"selection"}';
        	//AC_TemplateConfigController.returnFieldDataType(jsonFieldsData, 'Account');

            jsonFieldsData = '[{"selectedFieldOptions":[{"customLabel":"","selectedField":"Id","dataType":"text","func":"","apexDataType":"ID","isFieldRelated":false,"selectedFieldObj":{},"mapping":"agileComp__Account__c","relatedObjectName":null},{"customLabel":"","selectedField":"agileComp__AC_Name__c","dataType":"text","func":"","apexDataType":"CURRENCY","isFieldRelated":false,"selectedFieldObj":{},"mathFunc":"Absolute","mapping":"agileComp__Orig_Doc_Ext_Cost__c","relatedObjectName":null}],"selectedFilters":[{"operations":[{"label":"Equals","value":"EqualTo"},{"label":"Does not equal","value":"NotEqualTo"},{"label":"Greater than","value":"GreaterThan"},{"label":"Greater than or equal","value":"GreaterThanOrEqualTo"},{"label":"Less than","value":"LessThan"},{"label":"Less than or equal","value":"LessThanOrEqualTo"}],"label":"","fieldType":"text","filterValue":"","operation":"GreaterThan","selectedField":"","isFieldRelated":false,"dataType":"number","apexDataType":"CURRENCY","customLabel":"","relatedObjectName":null}],"description":"","documentField":{"isFieldRelated":false,"selectedField":"Id","relatedObjectName":null},"accountField":{"isFieldRelated":false,"selectedField":"Id"},"isOpen":false,"filterOptions":[],"selectedFilterCombo":"AND","filterCombo":"","isCustom":false,"hasError":false}]';
            AC_TemplateConfigController.saveTemplateData(templateConfig[0].id, 'testTemplateName', 'agileComp__AC_Templates_Config__c', jsonFieldsData) ;
            
            AC_TemplateConfigController.getSessionId();
            AC_TemplateConfigController.testNow(templateConfig[0].id);
        	AC_TemplateConfigController.getTemplateConfigData(templateConfig[0].id);
        } catch (Exception e) {
            
        }
        	
        test.stopTest();
    }
}