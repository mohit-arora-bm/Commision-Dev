trigger AC_CommissionPeriodTrigger on agileComp__CommissionPeriod__c (before insert, before update) {
    List<agileComp__CommissionPeriod__c> activePeriods = new List<agileComp__CommissionPeriod__c>();
    List<String> activePeriodIds = new List<String>();
    List<agileComp__CommissionPeriod__c> deactivatingRecords = new List<agileComp__CommissionPeriod__c>();
    List<agileComp__CommissionPeriod__c> activeDateChange = new List<agileComp__CommissionPeriod__c>();
    System.debug('before soql '+Trigger.new);
    
    List<agileComp__CommissionPeriod__c> allOldPeriods = [SELECT Id, agileComp__dateStart__c, agileComp__dateEnd__c,(Select Id FROM agileComp__Commission_Employee_Attained_Values__r
    														) FROM agileComp__CommissionPeriod__c WHERE Id NOT IN : Trigger.new];
    System.debug('allOldPeriodsallOldPeriods '+allOldPeriods);
    for (agileComp__CommissionPeriod__c commPeriod : Trigger.new) {
        if (commPeriod.agileComp__isActive__c) {
            activePeriods.add(commPeriod);
            activePeriodIds.add(commPeriod.Id);
        }
        for (agileComp__CommissionPeriod__c othPeriod : Trigger.new) {
            if (othPeriod != commPeriod) {
                if ((commPeriod.agileComp__dateStart__c >= othPeriod.agileComp__dateStart__c && commPeriod.agileComp__dateStart__c <= othPeriod.agileComp__dateEnd__c)
                || (commPeriod.agileComp__dateEnd__c >= othPeriod.agileComp__dateStart__c && commPeriod.agileComp__dateEnd__c <= othPeriod.agileComp__dateEnd__c)) {
                    commPeriod.addError('The periods should not override each other');
                    System.debug(commPeriod);
                    break;
                }
            }
        }
    }
    if (activePeriods.size() > 1) {
        for (agileComp__CommissionPeriod__c period : activePeriods) {
            period.addError('There should be only one active period at a time!');
        }
    }
    else {
        Integer oldActivePeriods = [SELECT COUNT() FROM agileComp__CommissionPeriod__c 
                                                                    WHERE ID NOT IN : activePeriodIds AND agileComp__isActive__c = true];
        if (oldActivePeriods > 0) {
            for (agileComp__CommissionPeriod__c period : activePeriods) {
                period.addError('There should be only one active period at a time!');
            }
        }else{
            for(agileComp__CommissionPeriod__c period : Trigger.new){
                for(agileComp__CommissionPeriod__c othPeriod : allOldPeriods){
                    if(othPeriod.agileComp__dateStart__c >= period.agileComp__dateEnd__c && othPeriod.agileComp__Commission_Employee_Attained_Values__r.size() > 0){
                        Period.addError('This period cannot be activated. There are periods in future to this that have Employee Attained Value records created.');
                    }
                }
            } 
        }
    }

    if (Trigger.new.size() == 1) {
        Integer oldActivePeriods = [SELECT COUNT() FROM agileComp__CommissionPeriod__c 
                                    WHERE 
                                    ((agileComp__dateStart__c >= :Trigger.new[0].agileComp__dateStart__c AND agileComp__dateStart__c <= :Trigger.new[0].agileComp__dateEnd__c) OR 
                                    (agileComp__dateEnd__c <= :Trigger.new[0].agileComp__dateEnd__c AND agileComp__dateEnd__c >= :Trigger.new[0].agileComp__dateStart__c))
                                    AND Id != :Trigger.new[0].Id];
        if (oldActivePeriods > 0) {
            Trigger.new[0].addError('The periods should not override each other');   
            return;
        }
        Integer userOverrides = [SELECT COUNT() FROM agileComp__Commision_User_Override__c WHERE 
                                    ((agileComp__Begin_Date__c > :Trigger.new[0].agileComp__dateStart__c AND agileComp__Begin_Date__c < :Trigger.new[0].agileComp__dateEnd__c) OR 
                                    (agileComp__End_Date__c < :Trigger.new[0].agileComp__dateEnd__c AND agileComp__End_Date__c > :Trigger.new[0].agileComp__dateStart__c))];

        if (userOverrides > 0) {
            Trigger.new[0].addError('There are some user override which are conflicting with the current period');   
            return;
        }
    }
    else if (Trigger.isInsert) {
        List<agileComp__CommissionPeriod__c> periods = [ SELECT Id, agileComp__dateStart__c, agileComp__dateEnd__c FROM agileComp__CommissionPeriod__c ];
        for (agileComp__CommissionPeriod__c newPeriod : Trigger.new) {
            for (agileComp__CommissionPeriod__c oldPeriod : periods) {
                if ((newPeriod.agileComp__dateStart__c >= oldPeriod.agileComp__dateStart__c && newPeriod.agileComp__dateStart__c <= oldPeriod.agileComp__dateEnd__c)
                || (newPeriod.agileComp__dateEnd__c >= oldPeriod.agileComp__dateStart__c && newPeriod.agileComp__dateEnd__c <= oldPeriod.agileComp__dateEnd__c)) {
                    
                    newPeriod.addError('The periods should not override each other');
                    break;
                }
            }
        }
    }
    else if (Trigger.isUpdate) {
        for (agileComp__CommissionPeriod__c commPeriod : Trigger.new) {
            for (agileComp__CommissionPeriod__c othPeriod : allOldPeriods) {
                if ((commPeriod.agileComp__dateStart__c >= othPeriod.agileComp__dateStart__c && commPeriod.agileComp__dateStart__c <= othPeriod.agileComp__dateEnd__c)
                || (commPeriod.agileComp__dateEnd__c >= othPeriod.agileComp__dateStart__c && commPeriod.agileComp__dateEnd__c <= othPeriod.agileComp__dateEnd__c)) {
                    System.debug(commPeriod);
                    commPeriod.addError('The periods should not override each other');
                    break;
                }
            }
        }
    }
}