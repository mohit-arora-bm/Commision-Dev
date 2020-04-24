@isTest
private class AQ_DynamicObjectLookUpControllerTest{
    
    @isTest static void testobjectLookup() {
        Test.startTest();
            String result = AQ_DynamicObjectLookUpController.getDynamicOjectList('ac','');
            System.assertNotEquals(NULL,result);
        	String resultselect = AQ_DynamicObjectLookUpController.getDynamicOjectList('ac','Account');
            System.assertNotEquals(NULL,resultselect);
            try{
              String resultExc = AQ_DynamicObjectLookUpController.getDynamicOjectList('ac','ABC');
              System.assertNotEquals(NULL,resultExc);
            }catch(Exception ex) {
              System.assertNotEquals(NULL,ex);
            }
        	
           
        Test.stopTest();
    }
    
}