trigger AC_CommissionSalesRepTrigger on agileComp__Commission_Sales_Rep__c (after insert,before update) {
    Set<Id> userIdSet = new Set<Id>();
    for(agileComp__Commission_Sales_Rep__c salesRep : Trigger.new){
        if(salesRep.agileComp__isActive__c){
            userIdSet.add(salesRep.agileComp__Sales_Rep__c);
        }
    }   
    Map<Id,agileComp__Commission_Sales_Rep__c>  oldActiveSalesRepMap = new Map<Id,agileComp__Commission_Sales_Rep__c>([SELECT Id,agileComp__Sales_Rep__c  FROM agileComp__Commission_Sales_Rep__c WHERE agileComp__isActive__c =true AND agileComp__Sales_Rep__c In : userIdSet ]);
    for(agileComp__Commission_Sales_Rep__c salesRep : Trigger.new){
        for(agileComp__Commission_Sales_Rep__c oldSalesRep : oldActiveSalesRepMap.values()){

            if(salesRep.agileComp__Sales_Rep__c == oldSalesRep.agileComp__Sales_Rep__c && salesRep.id != oldSalesRep.id){

                salesRep.addError('There should be only one active sales rep of same user at a time!');
            }
        }
    }
}