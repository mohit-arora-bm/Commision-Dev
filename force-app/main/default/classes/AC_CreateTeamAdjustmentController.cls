public with sharing class AC_CreateTeamAdjustmentController {
    @AuraEnabled
    public static List<sObject> fetchTeam(String teamId){
        return [SELECT Id,Name FROM agileComp__Commission_Team__c WHERE Id = :teamId];
    }

    @AuraEnabled
    public static void createAdj(String teamId, String objJSON,String periodId,String externalId){
        try {
            System.debug('periodId'+externalId);
            if(String.isNotBlank(externalId)){
                agileComp__commissionAdjustmentDetail__c adj = (agileComp__commissionAdjustmentDetail__c)JSON.deserialize(objJSON,agileComp__commissionAdjustmentDetail__c.class);
                List<agileComp__commissionAdjustmentDetail__c> listOfExistingTeamGp = [SELECT Id,agileComp__Adjustment_Amount__c 
                                                                                        FROM agileComp__commissionAdjustmentDetail__c 
                                                                                        WHERE agileComp__Team_Adjustment_Id__c =:externalId  
                                                                                        AND agileComp__Team_Adjustment__c = true];
               if(listOfExistingTeamGp.size() > 0){
                    for(agileComp__commissionAdjustmentDetail__c teamAdj : listOfExistingTeamGp){
                        teamAdj.agileComp__Adjustment_Amount__c = adj.agileComp__Adjustment_Amount__c;
                    }

                    update listOfExistingTeamGp;
               }
                                                                                        
            }else{
                String uniqueString = String.valueOf(System.now()) + String.valueOf(Math.random());
                List<agileComp__commissionEmployeeAttainedValue__c> eavList = [SELECt Id,agileComp__Commission_Sales_Rep__r.Name,
                                                                            agileComp__Commission_Period__r.Name,
                                                                            (SELECT Id,Name,agileComp__Team_Adjustment__c
                                                                            FROM agileComp__Commission_Adjustment_Details__r 
                                                                            WHERE agileComp__System_Generated__c = False
                                                                            ORDER BY createdDate DESC LIMIT 1) 
                                                                            FROM agileComp__commissionEmployeeAttainedValue__c 
                                                                            WHERE agileComp__Commission_Team__c = :teamId AND 
                                                                            agileComp__Commission_Period__c =:periodId];
                List<agileComp__commissionAdjustmentDetail__c> adjs = new List<agileComp__commissionAdjustmentDetail__c>();
                for( agileComp__commissionEmployeeAttainedValue__c eav : eavList ) {
                    agileComp__commissionAdjustmentDetail__c adj = (agileComp__commissionAdjustmentDetail__c)JSON.deserialize(objJSON,agileComp__commissionAdjustmentDetail__c.class);
                    adj.agileComp__Commission_Employee_Attained_Value_Recor__c = eav.Id;
                    adj.agileComp__Team_Adjustment_Id__c =uniqueString;
                    adj.agileComp__Team_Adjustment__c = true;
                    adjs.add(adj);
                }

                for(agileComp__commissionAdjustmentDetail__c adj : adjs){
                    System.debug('here is the adjustmentList'+adj);
                }
                insert adjs;
        }
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + Label.AC_Error_Separator + ex.getStackTraceString());
        }
    }
}