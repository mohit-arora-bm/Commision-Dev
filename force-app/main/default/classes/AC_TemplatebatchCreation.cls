public with sharing class AC_TemplatebatchCreation implements Database.Batchable<sObject>,Database.AllowsCallouts{

    // The batch job starts
    public Database.QueryLocator start(Database.BatchableContext bc){  
        Datetime currentDate = System.now();
        currentDate = currentDate.addMinutes(-6);
        
        String query = 'SELECT Id, agileComp__AC_Name__c FROM agileComp__AC_Templates_Config__c WHERE agileComp__AC_BatchClassName__c = null and CreatedDate >= :currentDate';
        System.debug('>>>> start ' + query);
        return Database.getQueryLocator(query);
    } 
    
    // The batch job executes and operates on one batch of records
    public  void execute(Database.BatchableContext bc, List<sObject> scope){
        for(sObject temp : scope) {
            String className = String.valueOf(temp.get('agileComp__AC_Name__c')).replaceAll('[^a-zA-Z]', '');
			className += System.now().getTime();
            System.debug(className);
            System.debug(temp);
            AC_TemplatebatchCreation.create(className,(agileComp__AC_Templates_Config__c)temp);
        }
    }
    
    // The batch job finishes
    public void finish(Database.BatchableContext bc){
        
    }


    private static void create(String templateName, agileComp__AC_Templates_Config__c template) {
       String batchContent = 'global class ' + templateName + ' extends agileComp.AC_BatchInterface  implements Database.Batchable<AggregateResult> , Database.Stateful {\n '

                +	'String objAPI;\n'
                +	'String query;\n'
                +	'Integer index;\n'
                +	'String templateId;\n'
                +	'List<String> JSONStrs;\n'
                +	'String userId;\n'
                +	'String uniqueString;\n'  
                +	'global '+ templateName + '(){}\n'
                    
                +   'global override void setVariables(List<String> JSONStrs, String objAPI, String query,Integer index, String templateId, String userId ) {\n'
                +   'this.objAPI = objAPI;\n'
                +   'this.query = query;\n'
                +   'this.index = index;\n'
                +   'this.templateId = templateId;\n'
                +   'this.JSONStrs = JSONStrs;\n'
                +   'this.userId = userId;\n'
                +   '\n'
                +   '}\n'
                +   'global override void setUniqueString(String uniqueString){\n'
                +   'this.uniqueString = uniqueString;\n'
                +   '}'
                +	'global override Iterable<AggregateResult> start(Database.BatchableContext bc){\n'
                
                +		'return new agileComp.AggregateResultIterable(query);\n' 
                +	'}\n' 
                    
                +	'global override void execute(Database.BatchableContext bc, List<AggregateResult> scope){\n'
                +       'try { \n'
                +		'Integer currentIndex = index - 1;\n'
                +		'agileComp.AC_SchedulerTemplateController.uniqueId = uniqueString;\n'
                
                +		'agileComp.AC_SchedulerTemplateController.createCommisionInput(JSONStrs[currentIndex], objAPI, (List<AggregateResult>)scope, templateId);\n'
                +       '}\n'
                +       'catch(Exception ex) {'
                +           'agileComp.AC_DataService.logException(ex.getMessage(), ex.getStackTraceString());'
                +       '}'
                +	'}\n'
                    
                +	'global override void finish(Database.BatchableContext bc){\n'
                +       'try { \n'
                +		'agileComp.AC_SchedulerTemplateController.uniqueId = uniqueString;\n'
                +		'agileComp.AC_SchedulerTemplateController.batchFinal(bc, templateId, index, JSONStrs, objAPI, userId);\n'
                +       '}\n'
                +       'catch(Exception ex) {'
                +           'agileComp.AC_DataService.logException(ex.getMessage(), ex.getStackTraceString());' 
                +       '}'
                +	'}\n'
                +'}';
            System.debug(batchContent);
            String testClassName = templateName;
            if (testClassName.length() > 34) {
                testClassName = testClassName.substring(0,34);
            }
            testClassName += '_Test';
        String testClassContent = '@isTest \n'
            +'public with sharing class ' + testClassName + ' {\n'
                
            +    '@isTest\n'
            +    'static void testBatch() {\n'
            +        'Account acc = new Account();\n'
            +        'acc.Name = \'Test Acc\';'
            +        'insert acc;\n '
            +        'agileComp__AC_Templates_Config__c template = new agileComp__AC_Templates_Config__c();\n'
            +        'template.agileComp__AC_BatchClassName__c = \'' + templateName + '\';\n'
            +        'template.agileComp__AC_Name__c = \'Acc\';\n'
            +        'template.Name = \'Acc\';\n'
            +        'String json = \'{\"selectedFieldOptions\":[{\"customLabel\":\"Id\",\"selectedField\":\"Id\",\"dataType\":\"text\",\"func\":\"\",\"apexDataType\":\"ID\",\"isFieldRelated\":false,\"selectedFieldObj\":{},\"mapping\":\"agileComp__Account__c\",\"relatedObjectName\":null}],\"selectedFilters\":[{\"operations\":[{\"label\":\"Equals\",\"value\":\"EqualTo\"},{\"label\":\"Does not equal\",\"value\":\"NotEqualTo\"},{\"label\":\"Contains\",\"value\":\"Contains\"},{\"label\":\"Not Contains\",\"value\":\"NotContains\"}],\"label\":\"\",\"fieldType\":\"text\",\"filterValue\":\"Test\",\"operation\":\"Contains\",\"selectedField\":\"Name\",\"isFieldRelated\":false,\"dataType\":\"text\",\"apexDataType\":\"STRING\",\"customLabel\":\"Name\",\"relatedObjectName\":null}],\"description\":\"1\",\"documentField\":{\"isFieldRelated\":false,\"selectedField\":\"Id\",\"relatedObjectName\":null},\"accountField\":{\"isFieldRelated\":false,\"selectedField\":\"\"},\"isOpen\":false,\"filterOptions\":[],\"selectedFilterCombo\":\"AND\",\"filterCombo\":\"\",\"isCustom\":false,\"hasError\":false}\';'
            +        'template.agileComp__AC_Object__c = \'Account\';\n'
            +        'template.agileComp__AC_TemplateDataJson__c = \'[\'+ json +\']\';\n'
            +        'insert template;\n'
            +        'Test.startTest();\n'
            +        templateName + ' tb = new ' + templateName + '();\n'
                    
            +        'tb.setVariables(new List<String>{json}, \'Account\', \'SELECT Id FROM Account Group by Id\', 1, template.Id, UserInfo.getUserId());\n'
            +        'database.executebatch(tb,200);\n'
            +        'Test.stopTest();\n'
            +    '}\n'
            +'}\n';
        String batchName = 'classes/' + templateName +'.cls';
        String clsXML = '<?xml version="1.0" encoding="UTF-8"?><ApexClass xmlns="http://soap.sforce.com/2006/04/metadata"><apiVersion>47.0</apiVersion><status>Active</status></ApexClass>';

        String packXML = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' + 
            '<Package xmlns="http://soap.sforce.com/2006/04/metadata">' +  
            '<types>' + 
            '<members>' + templateName + '</members>' +
            '<members>' + testClassName + '</members>' +
            '<name>ApexClass</name>' + 
            '</types>' + 
            '<version>45.0</version>' + 
            '</Package>';
        Zippex sampleZip = new Zippex();
        Blob classFile = Blob.valueOf(batchContent);
        Blob classTestFile = Blob.valueOf(testClassContent);
        Blob classXMLFile = Blob.valueOf(clsXML);
        Blob packXMLFile = Blob.valueOf(packXML);
        sampleZip.addFile('classes/'+templateName+'.cls', classFile, null);
        sampleZip.addFile('classes/'+testClassName+'.cls', classTestFile, null);
        sampleZip.addFile('classes/'+templateName+'.cls-meta.xml', classXMLFile, null);
        sampleZip.addFile('classes/'+testClassName+'.cls-meta.xml', classXMLFile, null);
        sampleZip.addFile('package.xml', packXMLFile, null);
        System.debug('samplee zipp : ' + sampleZip);
        Blob zipData = sampleZip.getZipArchive();
        // Deploy zip file posted back from the page action function				
        MetadataService.MetadataPort service = createService();
        MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();
        deployOptions.allowMissingFiles = false;
        deployOptions.autoUpdatePackage = false;
        deployOptions.checkOnly = false;
        deployOptions.ignoreWarnings = false;
        deployOptions.performRetrieve = false;
        deployOptions.purgeOnDelete = false;
        deployOptions.rollbackOnError = true;
        deployOptions.testLevel = 'RunSpecifiedTests';
        deployOptions.singlePackage = true;		
        List<String> runTests = new List<String>();
        runTests.add( testClassName); 
        deployOptions.runTests= runTests;
        MetadataService.AsyncResult AsyncResult = service.deploy(EncodingUtil.base64Encode(ZipData), DeployOptions);

        System.debug('zipdata : ' + ZipData);
        System.debug('service : ' + service);
        System.debug('DeployOptions : ' + DeployOptions);
        System.debug(service.deploy(EncodingUtil.base64Encode(ZipData), DeployOptions));
        System.debug(AsyncResult);
        template.agileComp__AC_BatchClassName__c = templateName;
        update template;		
    }

    public static MetadataService.MetadataPort createService() { 
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = UserInfo.getSessionId();
		return service;		
    }
    
    
}