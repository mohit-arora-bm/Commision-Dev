public with sharing class AC_ConfigureController {
    
    @AuraEnabled
    public static Boolean checkConfig(){ 
        try {
            List<String> apexClasses = new List<String>();
            // String message = 'You can uninstall this package there is no dependency';
            for(agileComp__AC_Templates_Config__c temp : [SELECT Id,agileComp__AC_BatchClassName__c 
                                                            FROM agileComp__AC_Templates_Config__c 
                                                            WHERE agileComp__AC_BatchClassName__c != null]) {
                
                apexClasses.add(temp.agileComp__AC_BatchClassName__c);
                String testClassName = temp.agileComp__AC_BatchClassName__c;
                if (testClassName.length() > 34) {
                    testClassName = testClassName.substring(0,34);
                }
                testClassName += '_Test';
                apexClasses.add(testClassName);
            }
            Integer count = [SELECT Count() FROM ApexClass WHERE Name IN : apexClasses]; 
            if (count > 0) {
                // message = 'There is some dependency please deconfigure first';
                return true; 
            }
            return false;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + Label.AC_Error_Separator + ex.getStackTraceString());
        }
        
    }

    @AuraEnabled
    public static String deleteClass() {
        try {
            List<String> apexClasses = new List<String>();
            List<String> testApexClasses = new List<String>();
            for(agileComp__AC_Templates_Config__c temp : [SELECT Id,agileComp__AC_BatchClassName__c 
                                                            FROM agileComp__AC_Templates_Config__c 
                                                            WHERE agileComp__AC_BatchClassName__c != null]) {
                
                apexClasses.add(temp.agileComp__AC_BatchClassName__c);
                String testClassName = temp.agileComp__AC_BatchClassName__c;
                if (testClassName.length() > 34) {
                    testClassName = testClassName.substring(0,34);
                }
                testClassName += '_Test';
                testApexClasses.add(testClassName);
                apexClasses.add(testClassName);
            }
            
            String packXML = '<?xml version="1.0" encoding="UTF-8"?>' + 
                '<Package xmlns="http://soap.sforce.com/2006/04/metadata">' + 
                '<version>45.0</version>' + 
                '</Package>';

            String dispackXML = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' + 
                '<Package xmlns="http://soap.sforce.com/2006/04/metadata">' + 
                '<types>';
                // dispackXML += '<members>myClass</members>';
                for (ApexClass ac : [SELECT Name FROM ApexClass WHERE Name IN : apexClasses]) {
                    dispackXML += '<members>'+ac.Name+'</members>';
                }
                dispackXML +='<name>ApexClass</name>'+
                '</types>'+
                '<version>45.0</version>' + 
                '</Package>';
                System.debug(packXML);
                System.debug(dispackXML);
            Blob packXMLFile = Blob.valueOf(packXML);
            Blob dispackXMLFile = Blob.valueOf(dispackXML);
            Zippex sampleZip = new Zippex();
            sampleZip.addFile('package.xml', packXMLFile, null);
            sampleZip.addFile('destructiveChanges.xml', dispackXMLFile, null);
            Blob zipData = sampleZip.getZipArchive();
            // Deploy zip file posted back from the page action function				
            MetadataService.MetadataPort service = createService();
            MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions(); 
            //deployOptions.purgeOnDelete = true;
            deployOptions.allowMissingFiles = false;
            deployOptions.autoUpdatePackage = false;
            deployOptions.checkOnly = false;
            deployOptions.ignoreWarnings = false;
            deployOptions.performRetrieve = false;
            deployOptions.purgeOnDelete = false;
            deployOptions.rollbackOnError = true;
            deployOptions.singlePackage = true;
            deployOptions.testLevel = 'RunSpecifiedTests';
            deployOptions.runTests= testApexClasses;

            MetadataService.AsyncResult AsyncResult = service.deploy(EncodingUtil.base64Encode(ZipData), DeployOptions);
            return AsyncResult.Id;
            
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + Label.AC_Error_Separator + ex.getStackTraceString());
        }
        
    }

    @AuraEnabled
    public static Boolean checkStatus( String AsyncResultId ) {
        try {
            MetadataService.MetadataPort service = createService();
            MetadataService.DeployResult deployResult = service.checkDeployStatus(AsyncResultId, true);
            if(deployResult.done) {
                if(!(deployResult.details!=null && deployResult.details.componentFailures!=null)) {
                    return true; 
                }
            }
            return false;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + Label.AC_Error_Separator + ex.getStackTraceString());
        }
        

    }

    public static MetadataService.MetadataPort createService() { 
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        if (Test.isRunningTest()) {
            service.SessionHeader.sessionId = null;
        }
        else {
            service.SessionHeader.sessionId = Page.AC_SessionId.getContent().toString();
        }
        System.debug(service);
		return service;		
    }
}