global with sharing class AC_TemplatebatchDeletion {

    @future(callout=true)
    global static void deleteClass(List<String> apexClasses) {
        String packXML = '<?xml version="1.0" encoding="UTF-8"?>' + 
            '<Package xmlns="http://soap.sforce.com/2006/04/metadata">' + 
            '<version>45.0</version>' + 
            '</Package>';

        String dispackXML = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' + 
            '<Package xmlns="http://soap.sforce.com/2006/04/metadata">' + 
            '<types>';
            for (String ac : apexClasses) {
                dispackXML += '<members>'+ac+'</members>';
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
        MetadataService.MetadataPort service = AC_TemplatebatchCreation.createService();
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
        deployOptions.testLevel = 'RunLocalTests';
        MetadataService.AsyncResult AsyncResult = service.deploy(EncodingUtil.base64Encode(ZipData), DeployOptions);
    }
}