@isTest
private class AC_DynamicObjectLookUpControllerTest{
    
    @isTest static void testobjectLookup() {
        Test.startTest();
            String result = AC_DynamicObjectLookUpController.getDynamicOjectList('ac','');
            System.assertNotEquals(NULL,result);
        	String resultselect = AC_DynamicObjectLookUpController.getDynamicOjectList('ac','Account');
            System.assertNotEquals(NULL,resultselect);
            try{
              String resultExc = AC_DynamicObjectLookUpController.getDynamicOjectList('ac','ABC');
              System.assertNotEquals(NULL,resultExc);
            }catch(Exception ex) {
              System.assertNotEquals(NULL,ex);
            }
        	
           
        Test.stopTest();
    }
    
}