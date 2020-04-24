@isTest
public with sharing class AC_CommissionPeriodTriggerTest {
    @isTest
    static void testTrigger() {
        
        agileComp__CommissionPeriod__c commisionPeriodN = new agileComp__CommissionPeriod__c(agileComp__isActive__c = false,agileComp__dateStart__c=system.today().addDays(-80), agileComp__dateEnd__c = System.today().addDays(-40)); 
        commisionPeriodN.agileComp__Commission_Year_End__c = System.today().addDays(123);
        commisionPeriodN.agileComp__Commission_Year_Start__c = System.today().addDays(-37);    
        try{
            insert commisionPeriodN;
        }catch(Exception e){
            
        }
         agileComp__CommissionPeriod__c commisionPeriodN2 = new agileComp__CommissionPeriod__c(agileComp__isActive__c = false, agileComp__dateStart__c=system.today().addDays(-39), agileComp__dateEnd__c = System.today()); 
        commisionPeriodN2.agileComp__Commission_Year_End__c = System.today().addDays(123);
        commisionPeriodN.agileComp__Commission_Year_Start__c = System.today().addDays(-37);    
        try{
            insert commisionPeriodN2;
        }catch(Exception e){
            
        }
        agileComp__CommissionPeriod__c commisionPeriodN4 = new agileComp__CommissionPeriod__c(agileComp__isActive__c = false, agileComp__dateEnd__c = System.today()); 
        commisionPeriodN4.agileComp__Commission_Year_End__c = System.today().addDays(123);
        commisionPeriodN4.agileComp__Commission_Year_Start__c = System.today().addDays(-37);    
        try{
            insert commisionPeriodN4;
        }catch(Exception e){
            
        }
                 agileComp__CommissionPeriod__c commisionPeriodN3 = new agileComp__CommissionPeriod__c(agileComp__isActive__c = true, agileComp__dateEnd__c = System.today()); 
        commisionPeriodN3.agileComp__Commission_Year_End__c = System.today().addDays(123);
        commisionPeriodN3.agileComp__Commission_Year_Start__c = System.today().addDays(-37);    
        try{
            insert commisionPeriodN2;
        }catch(Exception e){
            
        }
        List<agileComp__CommissionPeriod__c> commisionperiodList = new List<agileComp__CommissionPeriod__c>();
        agileComp__CommissionPeriod__c commisionPeriod = new agileComp__CommissionPeriod__c(agileComp__isActive__c = true, agileComp__dateEnd__c = System.today()); 
        commisionPeriod.agileComp__Commission_Year_End__c = System.today().addDays(123);
        commisionPeriod.agileComp__Commission_Year_Start__c = System.today().addDays(-37);
        commisionperiodList.add(commisionPeriod);
        agileComp__CommissionPeriod__c commisionPeriodS = new agileComp__CommissionPeriod__c(agileComp__isActive__c = true, agileComp__dateEnd__c = System.today().addDays(5)); 
        commisionPeriodS.agileComp__Commission_Year_End__c = System.today().addDays(183);
        commisionPeriodS.agileComp__Commission_Year_Start__c = System.today().addDays(-57);
        commisionperiodList.add(commisionPeriodS);
        try{   
            insert commisionperiodList;
        }catch(Exception e){
            
        }
        List<agileComp__CommissionPeriod__c> pListUpdate = new List<agileComp__CommissionPeriod__c>();
        List<agileComp__CommissionPeriod__c> soqlList = [SELECT ID, agileComp__isActive__c FROM agileComp__CommissionPeriod__c];
        System.debug('soqlListsoqlList'+soqlList);
        for(agileComp__CommissionPeriod__c cp :soqlList ){
            cp.agileComp__isActive__c = false;
            pListUpdate.add(cp);
        }
            
        try {
            System.debug('pListUpdate'+pListUpdate.size());
            update pListUpdate;
        } catch (Exception e) {
            
        }
       /* List<agileComp__CommissionPeriod__c> pList = new List<agileComp__CommissionPeriod__c>();
        pList.add(new agileComp__CommissionPeriod__c(agileComp__isActive__c = true, agileComp__dateEnd__c = System.today()));
        pList.add(new agileComp__CommissionPeriod__c(agileComp__isActive__c = true, agileComp__dateEnd__c = System.today()));
        try {
            insert pList;
        } catch (Exception e) {
            
        }*/
        
    }
}