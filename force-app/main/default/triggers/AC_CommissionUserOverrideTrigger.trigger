trigger AC_CommissionUserOverrideTrigger on agileComp__Commision_User_Override__c (before insert,before update) {
    List<agileComp__CommissionPeriod__c> periods = [SELECT agileComp__dateEnd__c,agileComp__dateStart__c,Name 
                                                    FROM agileComp__CommissionPeriod__c];
    
    Map<String,agileComp__Commision_User_Override__c> salesRepToUserOverride = new Map<String,agileComp__Commision_User_Override__c>();
    for (agileComp__Commision_User_Override__c uOver : Trigger.new) {
        if (Trigger.isInsert) {
            if(uOver.agileComp__Active__c) {
                if (uOver.agileComp__Commission_Sales_Rep__c != null && salesRepToUserOverride.containsKey(uOver.agileComp__Commission_Sales_Rep__c)) {
                    uOver.addError('There should be only one active Commision User Override with selected Commission Sales Rep.');
                    continue;
                }
                else {
                    salesRepToUserOverride.put(uOver.agileComp__Commission_Sales_Rep__c,uOver);
                }
            }
            
        }
        else {
            if ( (uOver.agileComp__Active__c && !Trigger.oldMap.get(uOver.Id).agileComp__Active__c) || (uOver.agileComp__Commission_Sales_Rep__c != null && uOver.agileComp__Commission_Sales_Rep__c != Trigger.oldMap.get(uOver.Id).agileComp__Commission_Sales_Rep__c) ) {
                if (salesRepToUserOverride.containsKey(uOver.agileComp__Commission_Sales_Rep__c)) {
                    uOver.addError('There should be only one active Commision User Override with selected Commission Sales Rep.');
                    continue;
                }
                else {
                    salesRepToUserOverride.put(uOver.agileComp__Commission_Sales_Rep__c,uOver);
                }
            }
        }
        
        for (agileComp__CommissionPeriod__c period : periods) {
            if (uOver.agileComp__Begin_Date__c > period.agileComp__dateStart__c && uOver.agileComp__Begin_Date__c < period.agileComp__dateEnd__c) {
                uOver.addError('The begin date is comming in betwwen the '+period.Name);
            }
            else if (uOver.agileComp__End_Date__c > period.agileComp__dateStart__c && uOver.agileComp__End_Date__c < period.agileComp__dateEnd__c) {
                uOver.addError('The end date is comming in betwwen the '+period.Name);
            }
        }
    }
    for (agileComp__Commision_User_Override__c uOver : [SELECT Id,agileComp__Commission_Sales_Rep__c FROM agileComp__Commision_User_Override__c
                                                        WHERE agileComp__Commission_Sales_Rep__c IN :salesRepToUserOverride.keySet()
                                                        AND agileComp__Active__c = true]) {
                                                            if (salesRepToUserOverride.containsKey(uOver.agileComp__Commission_Sales_Rep__c) ) {
                                                                salesRepToUserOverride.get(uOver.agileComp__Commission_Sales_Rep__c).addError('There should be only one active Commision User Override with selected Commission Sales Rep.');
                                                            }
                                                        }
}