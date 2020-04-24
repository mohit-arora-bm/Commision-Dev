trigger AC_CommissionTeamTrigger on agileComp__Commission_Team__c (before update) {
    List<String> teamIds = new List<String>();
    for (agileComp__Commission_Team__c team : Trigger.new) {
        if ((team.agileComp__Active__c && team.agileComp__Team__c && team.agileComp__Team_Payment_Method__c == 'Individual Contribution' && 
        (team.agileComp__Active__c != Trigger.oldMap.get(team.Id).agileComp__Active__c || 
        team.agileComp__Team__c != Trigger.oldMap.get(team.Id).agileComp__Team__c || 
        team.agileComp__Team_Payment_Method__c != Trigger.oldMap.get(team.Id).agileComp__Team_Payment_Method__c
        )) ||
        (team.agileComp__Team_Payment_Method__c != Trigger.oldMap.get(team.Id).agileComp__Team_Payment_Method__c && 
        team.agileComp__Team_Payment_Method__c.contains('Commission Year')
        )
        ) {
            teamIds.add(team.Id);
        }
    }
    if (!teamIds.isEmpty()) {
        List<agileComp__Commision_User_Override__c> userOverides = [SELECT Id,Name,agileComp__Commission_Sales_Rep__r.agileComp__Commission_Team__c
                                                            FROM agileComp__Commision_User_Override__c
                                                            WHERE agileComp__Commission_Sales_Rep__r.agileComp__Commission_Team__c IN : teamIds
                                                            AND agileComp__Commission_Attainment_Schedule_Override__r.agileComp__Active__c = true
                                                            AND agileComp__Commission_Attainment_Schedule_Override__r.agileComp__Calculation_Type__c = 'Step'];
        if (!userOverides.isEmpty()) {
            for (agileComp__Commision_User_Override__c uOver : userOverides) {
                String message = 'The ' + uOver.Name + ' is associated with your Team which has Calculation Type = Step, on its schedule which is not compatible with current system when you set Team = TRUE and Team Payment Method = Individual Contribution.';
                Trigger.newMap.get(uOver.agileComp__Commission_Sales_Rep__r.agileComp__Commission_Team__c).addError(message);
            }
        }
    }
}