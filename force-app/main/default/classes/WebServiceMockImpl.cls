/**
 * Dummy Metadata API web service mock class (see MetadataCreateJobTest.cls for a better example)
 **/
public class WebServiceMockImpl implements WebServiceMock  
{
    public void doInvoke(
        Object stub, Object request, Map<String, Object> response,
        String endpoint, String soapAction, String requestName,
        String responseNS, String responseName, String responseType) 
    {
        
        /*MetadataService.AsyncResult result = new MetadataService.AsyncResult();
        result.done = true;
        result.id = 'testid';
        result.message = 'testmessage';
        result.state = 'test state';
        result.statusCode = '200 ok';*/
        
        if(request instanceof MetadataService.retrieve_element)
        {
            response.put('response_x', new MetadataService.retrieveResponse_element());
            System.debug('hello retrieveResponse');
        }
        else if(request instanceof MetadataService.checkDeployStatus_element)
        {
            response.put('response_x', new MetadataService.checkDeployStatusResponse_element());
            System.debug('hello checkDeployStatusResponse_element');
        }
        else if(request instanceof MetadataService.listMetadata_element){
            response.put('response_x', new MetadataService.listMetadataResponse_element());
            System.debug('hello listMetadataResponse_element');
        }
        else if(request instanceof MetadataService.describeMetadata_element)
        {
            response.put('response_x', new MetadataService.describeMetadataResponse_element());
            System.debug('hello describeMetadataResponse_element');
        }
        else if(request instanceof MetadataService.deploy_element)
        {
            response.put('response_x', new MetadataService.deployResponse_element());
            System.debug('hello MetadataService.deployResponse_element');
        }
        else if(request instanceof MetadataService.updateMetadata_element)
        {
            response.put('response_x', new MetadataService.updateMetadataResponse_element());
            System.debug('hello updateMetadataResponse_element.updateMetadataResponse_element');
        }
        else if(request instanceof MetadataService.renameMetadata_element)
        {
            response.put('response_x', new MetadataService.renameMetadataResponse_element());
            System.debug('hello updateMetadataResponse_element.renameMetadataResponse_element');
        }
        else if(request instanceof  MetadataService.cancelDeploy_element){
            response.put('response_x', new MetadataService.cancelDeployResponse_element());
            System.debug('hello updateMetadataResponse_element.cancelDeployResponse_element');
        }
        else if(request instanceof  MetadataService.deleteMetadata_element){
            response.put('response_x', new MetadataService.deleteMetadataResponse_element());
            System.debug('hello updateMetadataResponse_element.deleteMetadataResponse_element');
        }
        else if(request instanceof  MetadataService.upsertMetadata_element){
            response.put('response_x', new MetadataService.upsertMetadataResponse_element());
            System.debug('hello updateMetadataResponse_element.upsertMetadataResponse_element');
        }
        else if(request instanceof  MetadataService.createMetadata_element){
            response.put('response_x', new MetadataService.createMetadataResponse_element());
            System.debug('hello updateMetadataResponse_element.createMetadataResponse_element');
        }
        else if(request instanceof  MetadataService.deployRecentValidation_element){
            response.put('response_x', new MetadataService.deployRecentValidationResponse_element());
            System.debug('hello updateMetadataResponse_element.deployRecentValidationResponse_element');
        }
        else if(request instanceof MetadataService.describeValueType_element){
            response.put('response_x', new MetadataService.describeValueTypeResponse_element());
            System.debug('hello updateMetadataResponse_element.describeValueTypeResponse_element');
        }
        else if(request instanceof MetadataService.checkRetrieveStatus_element)
            response.put('response_x', new MetadataService.checkRetrieveStatusResponse_element());{
            System.debug('hello updateMetadataResponse_element.checkRetrieveStatusResponse_element');
        }
        
    }
    
}