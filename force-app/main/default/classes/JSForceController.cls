global class JSForceController {
	@RemoteAction
    global static Wrapper getSessionId() {
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        //End point for authentication
        req.setEndpoint('https://login.salesforce.com/services/oauth2/token?grant_type=password&client_id=3MVG9GYWKbMgBvbxqrqEFUDJdAJ3LBWt3AVEOtO7Q5pOjfNShJ56to368HTBYyJYa8pWVYY19Olt24dtiT0tt&client_secret=E503CCB17FE04A7B1E76200E6CB9D2833CC677223A8E83ADD7FF9FD5F653CE73&username=mohit@cloudfirstlabs.com.commdev&password=password@12hfyGieb43GKXnivU7oUrRqVKh');
        
        req.setTimeout(60000);
        
        Http h = new Http();
        HttpResponse res = h.send(req);
        //Salesforce defined JSON Parser
       
        System.debug('results'+res.getBody());
        Wrapper wrapper = (Wrapper)JSON.deserialize(res.getBody(), Wrapper.class);
        return wrapper;
    }
    
    global class Wrapper {
        global String access_token;
        global String instance_url;
    }
}