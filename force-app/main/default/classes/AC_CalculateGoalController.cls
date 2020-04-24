public with sharing class AC_CalculateGoalController {
    
    @AuraEnabled
    public static void calculateGoal(String recId){
        try {
            AC_SecurityUtils.checkUpdate( agileComp__Goal_Detail__c.SObjectType,new List<String> {
                'agileComp__Split_Ext_GP__c',
                'agileComp__Split_Ext_Sales__c'
            });
            AC_SecurityUtils.checkUpdate( agileComp__Goal_Period__c.SObjectType,new List<String> {
                'agileComp__Last_Run_Date__c'
            });
            List<agileComp__Goal_Detail__c> goalDetails = [SELECT Id,agileComp__Commission_Sales_Rep__c,
                                                            agileComp__Split_Ext_GP__c,
                                                            agileComp__Split_Ext_Sales__c
                                                            FROM agileComp__Goal_Detail__c
                                                            WHERE agileComp__Goal_Period__c = : recId];
        
            Map<Id,agileComp__Goal_Detail__c> salesRepGoal = new Map<Id,agileComp__Goal_Detail__c>();
            agileComp__Goal_Period__c period = [SELECT Id,agileComp__To__c,agileComp__From__c,agileComp__Last_Run_Date__c 
                                                FROM agileComp__Goal_Period__c
                                                WHERE Id = : recId];
            period.agileComp__Last_Run_Date__c = Datetime.now();
            update period;
            for (agileComp__Goal_Detail__c goal : goalDetails) {
                salesRepGoal.put(goal.agileComp__Commission_Sales_Rep__c,goal);
            }

            List<agileComp__Goal_Detail__c> goalToUpdate = new List<agileComp__Goal_Detail__c>();

            for(AggregateResult input :  [SELECT agileComp__Commission_Sales_Rep__c,
                                                sum(agileComp__SplitDocumentGp__c) agileComp__SplitDocumentGp__c, 
                                                sum(agileComp__Split_Doc_Ext_Sales__c) agileComp__Split_Doc_Ext_Sales__c,
                                                max(agileComp__Document_Date__c) agileComp__Document_Date__c
                                                FROM agileComp__commissionBaseInput__c
                                                WHERE agileComp__Document_Date__c >= : period.agileComp__From__c
                                                AND agileComp__Document_Date__c <= : period.agileComp__To__c
                                                AND agileComp__Commission_Sales_Rep__c IN : salesRepGoal.keySet()
                                                GROUP BY agileComp__Commission_Sales_Rep__c]) {
                            
                agileComp__Goal_Detail__c goal =  salesRepGoal.get(String.valueOf(input.get('agileComp__Commission_Sales_Rep__c')));
                // goal.agileComp__Last_Date_Calculated__c = Datetime.now();
                goal.agileComp__Split_Ext_GP__c = (Decimal)input.get('agileComp__SplitDocumentGp__c');
                goal.agileComp__Split_Ext_Sales__c = (Decimal)input.get('agileComp__Split_Doc_Ext_Sales__c');
                goal.agileComp__Most_Recent_Doc_Date__c = (Date)input.get('agileComp__Document_Date__c');
                goalToUpdate.add(goal);
            }
            update goalToUpdate;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + Label.AC_Error_Separator + ex.getStackTraceString());
        }
        
    }
}