trigger AC_CommissionAttainScheduleTrigger on agileComp__Commission_Attainment_Schedule__c (before update) {
    List<String> schIds = new List<String>();
    for (agileComp__Commission_Attainment_Schedule__c schedule : Trigger.new) {
        if (schedule.agileComp__Calculation_Type__c == 'Step' && Trigger.oldMap.get(schedule.Id).agileComp__Calculation_Type__c != 'Step') {
            schIds.add(schedule.Id);
        }
    }

    if (!schIds.isEmpty()) {
        List<agileComp__Commission_Team__c> teams = [SELECT Id,agileComp__Commission_Attainment_Schedule__c,Name
                                                        FROM agileComp__Commission_Team__c
                                                        WHERE agileComp__Commission_Attainment_Schedule__c IN : schIds
                                                        AND agileComp__Active__c = true 
                                                        AND (
                                                        (agileComp__Team__c = true
                                                        AND agileComp__Team_Payment_Method__c = 'Individual Contribution')
                                                        OR agileComp__Team_Payment_Method__c LIKE '%Commission Year%')];
        if (!teams.isEmpty()) {
            for (agileComp__Commission_Team__c team : teams) {
                String message = 'The ' + team.Name + ' is associated with your schedule which has Team = TRUE and Team payment Method = Individual Contribution which is not compatible in current sysytem when you set Calculation Type = Step.';
                Trigger.newMap.get(team.agileComp__Commission_Attainment_Schedule__c).addError(message);
            }
        }
        List<agileComp__Commision_User_Override__c> userOverides = [SELECT Id,agileComp__Commission_Attainment_Schedule_Override__c,Name
                                                                    FROM agileComp__Commision_User_Override__c
                                                                    WHERE agileComp__Commission_Attainment_Schedule_Override__c IN : schIds
                                                                    AND agileComp__Commission_Sales_Rep__r.agileComp__Commission_Team__r.agileComp__Active__c = true
                                                                    AND ((agileComp__Commission_Sales_Rep__r.agileComp__Commission_Team__r.agileComp__Team__c = true
                                                                    AND agileComp__Commission_Sales_Rep__r.agileComp__Commission_Team__r.agileComp__Team_Payment_Method__c = 'Individual Contribution')
                                                                    OR agileComp__Commission_Sales_Rep__r.agileComp__Commission_Team__r.agileComp__Team_Payment_Method__c LIKE '%Commission Year%')];
        if (!userOverides.isEmpty()) {
            for (agileComp__Commision_User_Override__c uOver : userOverides) {
                String message = 'The ' + uOver.Name + ' is associated with your schedule which has Team = TRUE and Team payment Method = Individual Contribution which is not compatible in current system when you set Calculation Type = Step.';
                Trigger.newMap.get(uOver.agileComp__Commission_Attainment_Schedule_Override__c).addError(message);
            }
        }
    }
}