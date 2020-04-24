public with sharing class AC_RunOverPeriodController {
    @AuraEnabled
    public static ResultWrapper runPeriod(String recordId){
        ResultWrapper result = new ResultWrapper();
        try {
            List<agileComp__CommissionPeriod__c> commPeriods = [SELECT Id, agileComp__dateEnd__c, agileComp__dateStart__c, agileComp__isActive__c
                                                                FROM  agileComp__CommissionPeriod__c 
                                                                WHERE Id = :recordId];
            if (!commPeriods.isEmpty()) {
                if (commPeriods[0].agileComp__isActive__c) {
                    String query = 'SELECT Id,agileComp__Pay_All_Team_Members__c,agileComp__Team_Payment_Method__c,agileComp__Team__c,agileComp__Commission_Attainment_Schedule__c,'+
                    '(SELECT Id,Name FROM agileComp__Commission_Sales_Reps__r WHERE agileComp__isActive__c = true),'+
                    '(SELECT Id FROM agileComp__Commission_Teams__r)'+
                    ' FROM agileComp__Commission_Team__c WHERE agileComp__Active__c = true';
                    System.debug('query>>>>>>>>. ' +query);
                    AC_RunOverPeriodBatch batch = new AC_RunOverPeriodBatch(query,recordId);
                    database.executebatch(batch,10);
                    result.state = 'Success';
                    result.message = 'Your records are suceessfully schedule over this period.';
                }
                else {
                    result.state = 'Error';
                    result.message = 'This period is not active right now.';
                }
            }    
            else {
                result.state = 'Error';
                result.message = 'There is some error.';
            }                                                
        } catch (Exception e) {
            result.state = 'Error';
            result.message = e.getMessage();
        }
        return result;
    }
    public static void createCommEmploye(List<agileComp__Commission_Team__c> records, String periodId) {

        List<agileComp__commissionEmployeeAttainedValue__c> newEAVList = new List<agileComp__commissionEmployeeAttainedValue__c>();
        Map<String,agileComp__Commission_Team__c> salesRepToOTeamMap = new Map<String,agileComp__Commission_Team__c>();
        Map<String,List<String>> teamToConsiderSalesRepsMap = new Map<String,List<String>>();
        Map<String,agileComp__commissionEmployeeAttainedValue__c> salesRepEAVMap = new Map<String,agileComp__commissionEmployeeAttainedValue__c>();
        Map<String,Decimal> salesRepYearGPMap = new Map<String,Decimal>();
        Set<String> subTeamIds = new Set<String>();
        List<String> allSalesRepInUse = new List<String>();
        List<String> allScheduleAttIds = new List<String>();
        agileComp__CommissionPeriod__c period = [SELECT Id,Name,agileComp__dateEnd__c, agileComp__dateStart__c,
                                                agileComp__Commission_Year_End__c,agileComp__Commission_Year_Start__c
                                                    FROM agileComp__CommissionPeriod__c 
                                                    WHERE Id = : periodId];
        for (agileComp__Commission_Team__c team : records) {
            teamToConsiderSalesRepsMap.put(team.Id,  new List<String>());
            allScheduleAttIds.add(team.agileComp__Commission_Attainment_Schedule__c);
            
            for (agileComp__Commission_Sales_Rep__c salesRep : team.agileComp__Commission_Sales_Reps__r) {
        
                salesRepToOTeamMap.put(salesRep.Id,team);
                teamToConsiderSalesRepsMap.get(team.Id).add(salesRep.Id);
                allSalesRepInUse.add(salesRep.Id);
                salesRepEAVMap.put(salesRep.Id, new agileComp__commissionEmployeeAttainedValue__c(
                    Name = salesRep.Name + '-' + period.Name, 
                    agileComp__Commission_Sales_Rep__c = salesRep.Id,
                    agileComp__Commission_Period__c = periodId,
                    agileComp__Commission_Team__c = team.Id,
                    agileComp__Original_Revenue__c = 0,
                    agileComp__Original_Total_Cost__c = 0,
                    agileComp__Original_Freight_Cost__c = 0,
                    agileComp__Team_Cost_Attained__c = 0,
                    agileComp__Team_Freight_Cost_Attained__c = 0,
                    agileComp__Team_GP_Adjustment__c = 0,
                    agileComp__Year_GP_Adjustments__c = 0,
                    agileComp__Year_Team_GP_Adjustment__c = 0,
                    agileComp__Year_Freight_Cost__c = 0,
                    agileComp__Year_Original_Revenue__c = 0,
                    agileComp__Year_Original_Total_Coast__c = 0,
                    agileComp__Team_Revenue_Attained__c = 0));
            }
            for (agileComp__Commission_Team__c subTeam : team.agileComp__Commission_Teams__r) {
                subTeamIds.add(subTeam.Id);
            }
        }

        for (agileComp__Commission_Sales_Rep__c salesRep : [SELECT Id,agileComp__Commission_Team__c, 
                                                                    agileComp__Commission_Team__r.agileComp__Commission_Team_Rollup__c
                                                                FROM agileComp__Commission_Sales_Rep__c
                                                                WHERE agileComp__Commission_Team__c IN : subTeamIds]) {

            teamToConsiderSalesRepsMap.get(salesRep.agileComp__Commission_Team__r.agileComp__Commission_Team_Rollup__c).add(salesRep.Id);
            allSalesRepInUse.add(salesRep.Id);
        }

        Decimal dec = 0.0;
        List<String> allCurrentEAVIds = new List<String>();
        for(agileComp__commissionEmployeeAttainedValue__c eav : [SELECT agileComp__Commission_Sales_Rep__c,name, 
                                                                    agileComp__Original_Revenue__c,
                                                                    agileComp__Original_Total_Cost__c,
                                                                    agileComp__Original_Freight_Cost__c,
                                                                    agileComp__GP_Adjustments__c,
                                                                    agileComp__Year_Team_GP_Adjustment__c,
                                                                    agileComp__Best_of__c,
                                                                    agileComp__Year_GP_Adjustments__c,
                                                                    agileComp__Year_Original_Revenue__c,
                                                                    agileComp__Commission_Period__c,
                                                                    agileComp__Year_Freight_Cost__c,
                                                                    agileComp__Year_Original_Total_Coast__c,
                                                                    agileComp__Commission_Period_Payout__c,
                                                                    agileComp__Overridden_Attainment_Percentage__c
                                                                    FROM agileComp__commissionEmployeeAttainedValue__c
                                                                    WHERE agileComp__Commission_Sales_Rep__c IN :salesRepToOTeamMap.keySet()
                                                                    AND agileComp__Commission_Period__c = :periodId]) {

            salesRepEAVMap.put(eav.agileComp__Commission_Sales_Rep__c,eav);
            allCurrentEAVIds.add(eav.Id);
        }
        DELETE [SELECT Id FROM agileComp__commissionEmployeeAttainedDetail__c WHERE agileComp__Commission_Employee_Attained_Value__c IN : allCurrentEAVIds];
        DELETE [SELECT Id FROM agileComp__commissionAdjustmentDetail__c WHERE agileComp__System_Generated__c = true 
                                    AND agileComp__Commission_Employee_Attained_Value_Recor__c IN : allCurrentEAVIds];
    

        Map<String,AggregateResult> salesRepIdsValueAll = new Map<String,AggregateResult>();
        Date startDate = period.agileComp__dateStart__c;
        Date endDate = period.agileComp__dateEnd__c;
        Date ystartDate = period.agileComp__Commission_Year_Start__c;
        Date yendDate = period.agileComp__Commission_Year_End__c;
        if (yendDate > endDate) {
            yendDate = endDate;
        }
        String query = 'SELECT agileComp__Commission_Sales_Rep__c,agileComp__Commission_Sales_Rep__r.Name, sum(agileComp__Split_Doc_Ext_Cost__c) cost, sum(agileComp__Split_Doc_Ext_Sales__c) sale, sum(agileComp__Split_Doc_Freight__c) freight FROM agileComp__commissionBaseInput__c WHERE agileComp__Document_Date__c >= :startDate';
        
        query += ' AND agileComp__Document_Date__c < = :endDate';
        query += ' AND agileComp__Commission_Sales_Rep__c IN : allSalesRepInUse';
        query += ' GROUP BY agileComp__Commission_Sales_Rep__c,agileComp__Commission_Sales_Rep__r.Name';
        String ytdquery = 'SELECT agileComp__Commission_Sales_Rep__c,agileComp__Commission_Sales_Rep__r.Name, sum(agileComp__Split_Doc_Ext_Cost__c) cost, sum(agileComp__Split_Doc_Ext_Sales__c) sale, sum(agileComp__Split_Doc_Freight__c) freight FROM agileComp__commissionBaseInput__c WHERE agileComp__Document_Date__c >= :ystartDate';
        
        ytdquery += ' AND agileComp__Document_Date__c < = :yendDate';
        ytdquery += ' AND agileComp__Commission_Sales_Rep__c IN : allSalesRepInUse'; 
        ytdquery += ' GROUP BY agileComp__Commission_Sales_Rep__c,agileComp__Commission_Sales_Rep__r.Name';

        Boolean hasRecord = false;
        for (AggregateResult aggRecord : Database.query(query)) {
            hasRecord = true;
            salesRepIdsValueAll.put(String.valueOf(aggRecord.get('agileComp__Commission_Sales_Rep__c')), aggRecord);
            if (salesRepToOTeamMap.containsKey(String.valueOf(aggRecord.get('agileComp__Commission_Sales_Rep__c')))) {
                if (salesRepEAVMap.containsKey(String.valueOf(aggRecord.get('agileComp__Commission_Sales_Rep__c')))) {
                    agileComp__commissionEmployeeAttainedValue__c eav = salesRepEAVMap.get(String.valueOf(aggRecord.get('agileComp__Commission_Sales_Rep__c')));
                    eav.agileComp__Original_Revenue__c = Decimal.valueOf(String.valueOf(aggRecord.get('sale')));
                    eav.agileComp__Original_Total_Cost__c = Decimal.valueOf(String.valueOf(aggRecord.get('cost')));
                    eav.agileComp__Original_Freight_Cost__c = Decimal.valueOf(String.valueOf(aggRecord.get('freight')));
                    salesRepEAVMap.put(String.valueOf(aggRecord.get('agileComp__Commission_Sales_Rep__c')),eav);
                }
            }
        }
        if (!hasRecord) {
            return;
        }
        for (AggregateResult aggRecord : [SELECT sum(agileComp__GP_Adjustments__c) gp ,agileComp__Commission_Sales_Rep__c
                                            FROM agileComp__commissionEmployeeAttainedValue__c
                                            WHERE agileComp__Commission_Period__r.agileComp__dateStart__c >= :ystartDate 
                                            AND agileComp__Commission_Period__r.agileComp__dateEnd__c <= :yendDate
                                            GROUP BY agileComp__Commission_Sales_Rep__c]) {
            
            salesRepYearGPMap.put(String.valueOf(aggRecord.get('agileComp__Commission_Sales_Rep__c')), Decimal.valueOf(String.valueOf(aggRecord.get('gp'))));
        }
        for (AggregateResult aggRecord : Database.query(ytdquery)) {
            if (salesRepToOTeamMap.containsKey(String.valueOf(aggRecord.get('agileComp__Commission_Sales_Rep__c')))) {
                if (salesRepEAVMap.containsKey(String.valueOf(aggRecord.get('agileComp__Commission_Sales_Rep__c')))) {
                    agileComp__commissionEmployeeAttainedValue__c eav = salesRepEAVMap.get(String.valueOf(aggRecord.get('agileComp__Commission_Sales_Rep__c')));
                    eav.agileComp__Year_Original_Revenue__c = Decimal.valueOf(String.valueOf(aggRecord.get('sale')));
                    eav.agileComp__Year_Original_Total_Coast__c = Decimal.valueOf(String.valueOf(aggRecord.get('cost')));
                    eav.agileComp__Year_Freight_Cost__c = Decimal.valueOf(String.valueOf(aggRecord.get('freight')));
                    salesRepEAVMap.put(String.valueOf(aggRecord.get('agileComp__Commission_Sales_Rep__c')),eav);
                }
            }
        }
        Map<String,List<Decimal>> teamToAttainValue = new Map<String,List<Decimal>>();
        for (String teamId : teamToConsiderSalesRepsMap.keySet()) {
            List<String> salesReps = teamToConsiderSalesRepsMap.get(teamId);
            Decimal attValue = 0;
            Decimal salesValue = 0;
            Decimal costValue = 0;
            Decimal freightValue = 0;
            Decimal teamGP = 0;
            Decimal yearTeamGP = 0;
            Decimal yearattValue = 0;
            Decimal yearsalesValue = 0;
            Decimal yearcostValue = 0;
            Decimal yearfreightValue = 0;
           
           
            for (String salesRepId : salesReps) {
                if (salesRepIdsValueAll.containsKey(salesRepId)) {

                    AggregateResult aggRecord = salesRepIdsValueAll.get(salesRepId);
                    salesValue += Decimal.valueOf(String.valueOf(aggRecord.get('sale')));
                    costValue += Decimal.valueOf(String.valueOf(aggRecord.get('cost')));
                    freightValue += Decimal.valueOf(String.valueOf(aggRecord.get('freight')));
                    if (salesRepEAVMap.get(salesRepId) != null && salesRepEAVMap.get(salesRepId).agileComp__GP_Adjustments__c != null) {
                        teamGP += salesRepEAVMap.get(salesRepId).agileComp__GP_Adjustments__c;
                    }
                    if (salesRepYearGPMap.containskey(salesRepId) && salesRepYearGPMap.get(salesRepId) != null) {
                        yearteamGP += salesRepYearGPMap.get(salesRepId);
                    }
                    if (salesRepEAVMap.containsKey(salesRepId)) {
                        yearsalesValue += salesRepEAVMap.get(salesRepId).agileComp__Year_Original_Revenue__c;
                        yearcostValue += salesRepEAVMap.get(salesRepId).agileComp__Year_Original_Total_Coast__c;
                        yearfreightValue += salesRepEAVMap.get(salesRepId).agileComp__Year_Freight_Cost__c;
                    }
                }else if(salesRepEAVMap.containskey(salesRepId)){
                    if (salesRepEAVMap.get(salesRepId) != null && salesRepEAVMap.get(salesRepId).agileComp__GP_Adjustments__c != null) {
                        teamGP += salesRepEAVMap.get(salesRepId).agileComp__GP_Adjustments__c;
                    }
                    if (salesRepEAVMap.get(salesRepId) != null && salesRepEAVMap.get(salesRepId).agileComp__Year_Team_GP_Adjustment__c != null) {
                        yearteamGP += salesRepEAVMap.get(salesRepId).agileComp__Year_Team_GP_Adjustment__c;
                    }
                    if (salesRepEAVMap.containsKey(salesRepId)) {
                        yearsalesValue += salesRepEAVMap.get(salesRepId).agileComp__Year_Original_Revenue__c;
                        yearcostValue += salesRepEAVMap.get(salesRepId).agileComp__Year_Original_Total_Coast__c;
                        yearfreightValue += salesRepEAVMap.get(salesRepId).agileComp__Year_Freight_Cost__c;
                    }
                }
            }

            System.debug('teamGP>>'+teamGP+'    team id : '+teamId+'     year gp'+yearteamGP);
            attValue = salesValue - costValue - freightValue;
            List<Decimal> vals = new List<Decimal>{salesValue,costValue,freightValue,attValue,teamGP,yearteamGP,yearsalesValue,yearcostValue,yearfreightValue};
            teamToAttainValue.put(teamId, vals);
        }
        Map<Id,agileComp__Commision_User_Override__c> userOverrideMap = new Map<Id,agileComp__Commision_User_Override__c>([SELECT Id,
                                                                    agileComp__Commission_Percent_Override__c,
                                                                    agileComp__Commission_Period_Payout__c,
                                                                    agileComp__Commission_Sales_Rep__c,
                                                                    agileComp__Commission_Sales_Rep__r.Name,
                                                                    agileComp__Best_Of__c,
                                                                    agileComp__Commission_Attainment_Schedule_Override__c,
                                                                    agileComp__Commission_Attainment_Schedule_Override__r.agileComp__Active__c,
                                                                    agileComp__Commission_Attainment_Schedule_Override__r.agileComp__Calculation_Type__c
                                                                    FROM agileComp__Commision_User_Override__c
                                                                    WHERE agileComp__Commission_Sales_Rep__c IN :salesRepToOTeamMap.keySet()
                                                                    AND agileComp__Begin_Date__c <= :period.agileComp__dateStart__c 
                                                                    AND agileComp__End_Date__c >= :period.agileComp__dateEnd__c
                                                                    AND agileComp__Active__c = true]);
        
        Map<String,agileComp__Commision_User_Override__c> salesRepToUover = new Map<String,agileComp__Commision_User_Override__c>();
        for (agileComp__Commision_User_Override__c uOverride : userOverrideMap.values()) {
            salesRepToUover.put(uOverride.agileComp__Commission_Sales_Rep__c,uOverride);
            if (uOverride.agileComp__Commission_Attainment_Schedule_Override__c != null && uOverride.agileComp__Commission_Attainment_Schedule_Override__r.agileComp__Active__c) {
                allScheduleAttIds.add(uOverride.agileComp__Commission_Attainment_Schedule_Override__c);
            }
        }
        Map<Id,agileComp__Commission_Attainment_Schedule__c> allScheduleAttMap = new Map<Id,agileComp__Commission_Attainment_Schedule__c>(
                                                                                        [SELECT Id,agileComp__Calculation_Type__c,
                                                                                        (SELECT Id,agileComp__Amount_From__c,agileComp__Amount_To__c,agileComp__Percent__c
                                                                                        FROM agileComp__Commission_Attainment_Schedule_Items__r
                                                                                        ORDER BY agileComp__Amount_From__c)
                                                                                        FROM agileComp__Commission_Attainment_Schedule__c
                                                                                        WHERE Id IN :allScheduleAttIds
                                                                                        AND agileComp__Active__c = true]);
        
        List<EAVWrapper> eavToDetailMap = new List<EAVWrapper>();
        
        for (String salesRepId : salesRepEAVMap.keySet()) {
            EAVWrapper eavWrap = new EAVWrapper();
            agileComp__commissionEmployeeAttainedValue__c eav = salesRepEAVMap.get(salesRepId);
            List<agileComp__commissionEmployeeAttainedDetail__c> eavDetails = new List<agileComp__commissionEmployeeAttainedDetail__c>();
            List<agileComp__commissionAdjustmentDetail__c> adjs = new List<agileComp__commissionAdjustmentDetail__c>();
            agileComp__Commission_Attainment_Schedule__c schedule;
            Decimal overridePayout = 0;
            agileComp__Commission_Team__c team = salesRepToOTeamMap.get(salesRepId);
            Decimal baseVal = 0;
            Decimal indVal = 0;
            Decimal teamVal = 0;
            Decimal eavAdjustmants = 0;
            if (salesRepToUover.containsKey(salesRepId)) {
                agileComp__Commision_User_Override__c userOverride = salesRepToUover.get(salesRepId);
                eav.agileComp__Best_of__c = userOverride.agileComp__Best_Of__c;
                eav.agileComp__Commission_Period_Payout__c = userOverride.agileComp__Commission_Period_Payout__c;
                eav.agileComp__Overridden_Attainment_Percentage__c = userOverride.agileComp__Commission_Percent_Override__c;
                if(allScheduleAttMap.containsKey(userOverride.agileComp__Commission_Attainment_Schedule_Override__c)) {
                    schedule = allScheduleAttMap.get(userOverride.agileComp__Commission_Attainment_Schedule_Override__c);
                }
                else {
                    schedule = allScheduleAttMap.get(team.agileComp__Commission_Attainment_Schedule__c);
                }
            }
            else {
                schedule = allScheduleAttMap.get(team.agileComp__Commission_Attainment_Schedule__c);
                eav.agileComp__Best_of__c = false;
                eav.agileComp__Commission_Period_Payout__c = null;
                eav.agileComp__Overridden_Attainment_Percentage__c = null;
            }
            eav.agileComp__Calculation_Type__c = schedule.agileComp__Calculation_Type__c;
            eav.agileComp__Team_Payout_Method__c = team.agileComp__Team_Payment_Method__c;
            eav.agileComp__Created_From_Team__c = team.agileComp__Team__c;
            eav.agileComp__Pay_All_Team_Members__c = team.agileComp__Pay_All_Team_Members__c;
            eav.agileComp__Commission_Attainment_Schedule__c = schedule.Id;
            eav.agileComp__Commission_Period__c = periodId;
            eav.agileComp__Commission_Sales_Rep__c = salesRepId;
            eav.agileComp__Created_From_Team__c = team.agileComp__Team__c;
            
            if (eav.agileComp__GP_Adjustments__c != null) {
                eavAdjustmants = eav.agileComp__GP_Adjustments__c;
            }
            if (salesRepIdsValueAll.containsKey(salesRepId)) {
                AggregateResult aggRecord = salesRepIdsValueAll.get(salesRepId);
                indVal = (Decimal.valueOf(String.valueOf(aggRecord.get('sale'))) - Decimal.valueOf(String.valueOf(aggRecord.get('cost'))) - Decimal.valueOf(String.valueOf(aggRecord.get('freight'))));
            }
            if (teamToAttainValue.containsKey(team.Id)) {
                List<Decimal> vals = teamToAttainValue.get(team.Id);
                eav.agileComp__Team_Revenue_Attained__c = vals[0];
                eav.agileComp__Team_Cost_Attained__c = vals[1];
                eav.agileComp__Team_Freight_Cost_Attained__c = vals[2];
                teamVal = vals[3];
                eav.agileComp__Team_GP_Adjustment__c = vals[4];
                eav.agileComp__Year_Team_GP_Adjustment__c = vals[5];
                eav.agileComp__Year_Team_Revenue_Attained__c = vals[6];
                eav.agileComp__Year_Team_Cost_Attained__c = vals[7];
                eav.agileComp__Year_Team_Freight_Cost_Attained__c = vals[8];
            }
            Boolean hasEnvolment = salesRepIdsValueAll.containsKey(salesRepId) || eavAdjustmants > 0;
            if (hasEnvolment) {
                if (team.agileComp__Team_Payment_Method__c == 'Total Team Contribution') {
                    baseVal = teamVal + eav.agileComp__Team_GP_Adjustment__c;
                }
                else {
                    baseVal = indVal + eavAdjustmants;
                }
            }
            else {
                if (team.agileComp__Pay_All_Team_Members__c && team.agileComp__Team_Payment_Method__c.contains('Team')) {
                    baseVal = teamVal + eav.agileComp__Team_GP_Adjustment__c;
                }
                else {
                    baseVal = 0;
                    teamVal = 0;
                }
            }
            if (team.agileComp__Team_Payment_Method__c == 'Total Team Contribution') {
                eavAdjustmants = eav.agileComp__Team_GP_Adjustment__c;
            }
            ScheduleReturn schReturn = new ScheduleReturn();
            Decimal yearVal = 0;
            if (team.agileComp__Team_Payment_Method__c == 'Commission Year Individual Period Payout Tier' ) {
                yearVal = eav.agileComp__Year_Original_Revenue__c - eav.agileComp__Year_Original_Total_Coast__c - eav.agileComp__Year_Freight_Cost__c - eav.agileComp__Year_GP_Adjustments__c;

                schReturn = getScheduleCalYearTier(schedule, yearVal, indVal, eavAdjustmants, eav.agileComp__Overridden_Attainment_Percentage__c);
            }
            else if (team.agileComp__Team_Payment_Method__c == 'Commission Year Total Team Period Payout Tier') {
                yearVal = eav.agileComp__Year_Team_Revenue_Attained__c - eav.agileComp__Year_Team_Cost_Attained__c - eav.agileComp__Year_Team_Freight_Cost_Attained__c
                - eav.agileComp__Year_Team_GP_Adjustment__c;
                schReturn = getScheduleCalYearTier(schedule, yearVal, teamVal, eav.agileComp__Team_GP_Adjustment__c, eav.agileComp__Overridden_Attainment_Percentage__c);
            }
            else if (team.agileComp__Team_Payment_Method__c == 'Commission Year Individual Period Payout Step') {
                yearVal = eav.agileComp__Year_Original_Revenue__c - eav.agileComp__Year_Original_Total_Coast__c - eav.agileComp__Year_Freight_Cost__c - eav.agileComp__Year_GP_Adjustments__c;
                
                if (eavAdjustmants >= 0) {
                    
                    schReturn = getScheduleCalYearStepPos(schedule, yearVal, indVal, eavAdjustmants, eav.agileComp__Overridden_Attainment_Percentage__c);
                }
                else {
                    schReturn = getScheduleCalYearStepNeg(schedule, yearVal, indVal, eavAdjustmants, eav.agileComp__Overridden_Attainment_Percentage__c);
                }
            }
            else if (team.agileComp__Team_Payment_Method__c == 'Commission Year Total Team Period Payout Step') {
                yearVal = eav.agileComp__Year_Team_Revenue_Attained__c - eav.agileComp__Year_Team_Cost_Attained__c - eav.agileComp__Year_Team_Freight_Cost_Attained__c
                - eav.agileComp__Year_Team_GP_Adjustment__c;
                System.debug('in year  '+yearVal+' eac adjustment  '+ eavAdjustmants);
                if (eav.agileComp__Team_GP_Adjustment__c >= 0) {
                    System.debug('in positive adjustment');
                    schReturn = getScheduleCalYearStepPos(schedule, yearVal, teamVal, eav.agileComp__Team_GP_Adjustment__c, eav.agileComp__Overridden_Attainment_Percentage__c);
                }
                else {
                    System.debug('in negative adjustment');
                    schReturn = getScheduleCalYearStepNeg(schedule, yearVal, teamVal, eav.agileComp__Team_GP_Adjustment__c, eav.agileComp__Overridden_Attainment_Percentage__c);
                }
                System.debug(schReturn);
            }
            else if (baseVal > 0) {
                if (team.agileComp__Team__c) {
                    schReturn = getScheduleCalculatedVal(schedule,baseVal,teamVal,eavAdjustmants,eav.agileComp__Overridden_Attainment_Percentage__c,eav.agileComp__Team_GP_Adjustment__c);
                }
                else {
                    System.debug(schReturn);
                    schReturn = getScheduleCalculatedVal(schedule,baseVal,indVal,eavAdjustmants,eav.agileComp__Overridden_Attainment_Percentage__c,eavAdjustmants);
                }
            }
            overridePayout = schReturn.scheduleVal;
            eavDetails = schReturn.eavDetails;
               
            if(!eav.agileComp__Best_of__c && eav.agileComp__Commission_Period_Payout__c != null) {
                if (overridePayout != eav.agileComp__Commission_Period_Payout__c) {
                    adjs.add(new agileComp__commissionAdjustmentDetail__c(
                        agileComp__System_Generated__c = true,
                        agileComp__Adjustment_Type__c = ' Overrides',
                        agileComp__Type__c = 'Commission Adjustment',
                        agileComp__Adjustment_Amount__c = eav.agileComp__Commission_Period_Payout__c - overridePayout
                    ));
                }
                else {
                    // eavToDetailMap.put(eav,eavDetails);
                }
            }
            else if (eav.agileComp__Best_of__c) {
                if (eav.agileComp__Overridden_Attainment_Percentage__c != null) {
                    ScheduleReturn schReturnO = new ScheduleReturn();
                    if (team.agileComp__Team_Payment_Method__c == 'Commission Year Individual Period Payout Tier' ) {
                        yearVal = eav.agileComp__Year_Original_Revenue__c - eav.agileComp__Year_Original_Total_Coast__c - eav.agileComp__Year_Freight_Cost__c - eav.agileComp__Year_GP_Adjustments__c;
        
                        schReturnO = getScheduleCalYearTier(schedule, yearVal, indVal, eavAdjustmants, null);
                    }
                    else if (team.agileComp__Team_Payment_Method__c == 'Commission Year Total Team Period Payout Tier') {
                        yearVal = eav.agileComp__Year_Team_Revenue_Attained__c - eav.agileComp__Year_Team_Cost_Attained__c - eav.agileComp__Year_Team_Freight_Cost_Attained__c
                        - eav.agileComp__Year_Team_GP_Adjustment__c;
                        schReturnO = getScheduleCalYearTier(schedule, yearVal, teamVal, eav.agileComp__Team_GP_Adjustment__c, null);
                    }
                    else if (team.agileComp__Team_Payment_Method__c == 'Commission Year Individual Period Payout Step') {
                        yearVal = eav.agileComp__Year_Original_Revenue__c - eav.agileComp__Year_Original_Total_Coast__c - eav.agileComp__Year_Freight_Cost__c - eav.agileComp__Year_GP_Adjustments__c;
                        if (eavAdjustmants >= 0) {
                            schReturnO = getScheduleCalYearStepPos(schedule, yearVal, indVal, eavAdjustmants, null);
                        }
                        else {
                            schReturnO = getScheduleCalYearStepNeg(schedule, yearVal, indVal, eavAdjustmants, null);
                        }
                    }
                    else if (team.agileComp__Team_Payment_Method__c == 'Commission Year Total Team Period Payout Step') {
                        yearVal = eav.agileComp__Year_Team_Revenue_Attained__c - eav.agileComp__Year_Team_Cost_Attained__c - eav.agileComp__Year_Team_Freight_Cost_Attained__c
                        - eav.agileComp__Year_Team_GP_Adjustment__c;
                        if (eav.agileComp__Team_GP_Adjustment__c >= 0) {
                            schReturn = getScheduleCalYearStepPos(schedule, yearVal, teamVal, eav.agileComp__Team_GP_Adjustment__c, null);
                        }
                        else {
                            schReturn = getScheduleCalYearStepNeg(schedule, yearVal, teamVal, eav.agileComp__Team_GP_Adjustment__c,null);
                        }
                    }
                    else if (team.agileComp__Team__c) {
                        schReturnO = getScheduleCalculatedVal(schedule,baseVal,teamVal,eavAdjustmants,null,eav.agileComp__Team_GP_Adjustment__c);
                    }
                    else {
                        schReturnO = getScheduleCalculatedVal(schedule,baseVal,indVal,eavAdjustmants,null,eavAdjustmants);
                    }
                    if (overridePayout < schReturnO.scheduleVal) {
                        eavDetails = schReturnO.eavDetails;
                        eav.agileComp__Overridden_Attainment_Percentage__c = null;
                    }
                    // eavToDetailMap.put(eav,eavDetails);
                }
                else if (eav.agileComp__Commission_Period_Payout__c != null) {
                    if (overridePayout < eav.agileComp__Commission_Period_Payout__c) {
                        adjs.add(new agileComp__commissionAdjustmentDetail__c(
                            agileComp__System_Generated__c = true,
                            agileComp__Type__c = 'Commission Adjustment',
                            agileComp__Adjustment_Type__c = 'Overrides',
                            agileComp__Adjustment_Amount__c = eav.agileComp__Commission_Period_Payout__c - overridePayout
                        ));
                    }
                    else {
                        eav.agileComp__Commission_Period_Payout__c = null;
                    }
                }
            }
            eavWrap.eav = eav;
            eavWrap.eavDetails = eavDetails;
            eavWrap.adjs = adjs;
            eavToDetailMap.add(eavWrap);
        }
        List<List<agileComp__commissionEmployeeAttainedDetail__c>> eavDetails = new List<List<agileComp__commissionEmployeeAttainedDetail__c>>();
        List<List<agileComp__commissionAdjustmentDetail__c>> eavAdjs = new List<List<agileComp__commissionAdjustmentDetail__c>>();
        List<agileComp__commissionAdjustmentDetail__c> eavAdjsToInsert = new List<agileComp__commissionAdjustmentDetail__c>();
        List<agileComp__commissionEmployeeAttainedDetail__c> eavDetailsToInsert = new List<agileComp__commissionEmployeeAttainedDetail__c>();
        for(EAVWrapper eavw : eavToDetailMap) {
            newEAVList.add(eavw.eav);
            eavDetails.add(eavw.eavDetails);
            eavAdjs.add(eavw.adjs);
        }
        upsert newEAVList;
        for(agileComp__commissionEmployeeAttainedValue__c eav : newEAVList){

        }
        System.debug(newEAVList);
        System.debug(eavDetails);
        for(Integer i = 0; i < eavDetails.size(); i++) {
            if(eavDetails[i] != null) {
                for (agileComp__commissionEmployeeAttainedDetail__c detail : eavDetails[i]) {
                    detail.agileComp__Commission_Employee_Attained_Value__c = newEAVList[i].Id;
                    eavDetailsToInsert.add(detail);
                }
            }
            if(eavAdjs[i] != null) {
                for (agileComp__commissionAdjustmentDetail__c adj : eavAdjs[i]) {
                    adj.agileComp__Commission_Employee_Attained_Value_Recor__c = newEAVList[i].Id;
                    eavAdjsToInsert.add(adj);
                }
            }
        }
        insert eavAdjsToInsert;
        System.debug(eavDetailsToInsert);
        insert eavDetailsToInsert;
    }

    private static ScheduleReturn getScheduleCalYearStepPos(agileComp__Commission_Attainment_Schedule__c scheduleOverride, 
                                                Decimal yearVal, 
                                                Decimal perVal, 
                                                Decimal gpAdjust,
                                                Decimal overridePercent) {
        Decimal scheduleVal = 0;
        ScheduleReturn schReturn = new ScheduleReturn();
        List<agileComp__commissionEmployeeAttainedDetail__c> eavDetails = new List<agileComp__commissionEmployeeAttainedDetail__c>();
        Decimal prvValue = yearVal - perVal - gpAdjust;
        if (prvValue < 0) {
            prvValue = 0;
        }                                
        Decimal prvValueToAdd = prvValue;
        for (agileComp__Commission_Attainment_Schedule_Item__c scheduleTeam : scheduleOverride.agileComp__Commission_Attainment_Schedule_Items__r) {
            System.debug('prvValue  '+prvValue);
            System.debug('prvValueToAdd  '+prvValueToAdd);
            System.debug(scheduleTeam);
            Decimal percentage = overridePercent;
            if (percentage == null) {
                percentage = scheduleTeam.agileComp__Percent__c;
            }
            if (perVal <= 0 && perVal <= 0) {
                break;
            }
            if (prvValue > scheduleTeam.agileComp__Amount_To__c) {
                System.debug('in continue');
                prvValueToAdd = prvValueToAdd - scheduleTeam.agileComp__Amount_To__c;
                continue;
            }
            if (perVal + prvValueToAdd + gpAdjust <= scheduleTeam.agileComp__Amount_To__c - scheduleTeam.agileComp__Amount_From__c) {
                System.debug('in less then if'+perVal+'  '+gpAdjust);
                eavDetails.add(new agileComp__commissionEmployeeAttainedDetail__c(
                        agileComp__To__c = scheduleTeam.agileComp__Amount_To__c,
                        agileComp__From__c = scheduleTeam.agileComp__Amount_From__c,
                        agileComp__GP_Earned__c = perVal,
                        agileComp__Commission_Attainment_Schedule_Item__c = scheduleTeam.Id,
                        agileComp__Original_Percent__c = scheduleTeam.agileComp__Percent__c,
                        agileComp__GP_Adjust__c = gpAdjust,
                        agileComp__Comm_Attained__c = (perVal + gpAdjust) * percentage * 0.01,
                        agileComp__Override_Percent__c = overridePercent));
                scheduleVal += (perVal + gpAdjust) * percentage * 0.01;
                break;
            } 
            else if (perVal + prvValueToAdd >= scheduleTeam.agileComp__Amount_To__c - scheduleTeam.agileComp__Amount_From__c && perVal > 0) {
                System.debug(scheduleTeam);
                System.debug(prvValueToAdd);
                System.debug(percentage);
                eavDetails.add(new agileComp__commissionEmployeeAttainedDetail__c(
                        agileComp__To__c = scheduleTeam.agileComp__Amount_To__c,
                        agileComp__From__c = scheduleTeam.agileComp__Amount_From__c,
                        agileComp__GP_Earned__c = (scheduleTeam.agileComp__Amount_To__c - scheduleTeam.agileComp__Amount_From__c - prvValueToAdd),
                        agileComp__Commission_Attainment_Schedule_Item__c = scheduleTeam.Id,
                        agileComp__Original_Percent__c = scheduleTeam.agileComp__Percent__c,
                        agileComp__GP_Adjust__c = 0,
                        agileComp__Comm_Attained__c = (scheduleTeam.agileComp__Amount_To__c - scheduleTeam.agileComp__Amount_From__c - prvValueToAdd) * percentage * 0.01,
                        agileComp__Override_Percent__c = overridePercent));
                perVal = perVal - (scheduleTeam.agileComp__Amount_To__c - scheduleTeam.agileComp__Amount_From__c - prvValueToAdd);
                prvValueToAdd = 0;
                scheduleVal += (scheduleTeam.agileComp__Amount_To__c - scheduleTeam.agileComp__Amount_From__c - prvValueToAdd) * percentage * 0.01;
            }
            else if (perVal + prvValueToAdd + gpAdjust >= scheduleTeam.agileComp__Amount_To__c - scheduleTeam.agileComp__Amount_From__c) {
                eavDetails.add(new agileComp__commissionEmployeeAttainedDetail__c(
                        agileComp__To__c = scheduleTeam.agileComp__Amount_To__c,
                        agileComp__From__c = scheduleTeam.agileComp__Amount_From__c,
                        agileComp__GP_Earned__c = perVal,
                        agileComp__Commission_Attainment_Schedule_Item__c = scheduleTeam.Id,
                        agileComp__Original_Percent__c = scheduleTeam.agileComp__Percent__c,
                        agileComp__GP_Adjust__c = (scheduleTeam.agileComp__Amount_To__c - scheduleTeam.agileComp__Amount_From__c - perVal - prvValueToAdd),
                        agileComp__Comm_Attained__c = (scheduleTeam.agileComp__Amount_To__c - scheduleTeam.agileComp__Amount_From__c - prvValueToAdd) * percentage * 0.01,
                        agileComp__Override_Percent__c = overridePercent));
                perVal = 0;
                gpAdjust = gpAdjust - (scheduleTeam.agileComp__Amount_To__c - scheduleTeam.agileComp__Amount_From__c - perVal - prvValueToAdd);
                prvValueToAdd = 0;
                scheduleVal += (scheduleTeam.agileComp__Amount_To__c - scheduleTeam.agileComp__Amount_From__c - prvValueToAdd) * percentage * 0.01;
            }
            
        }
        schReturn.eavDetails = eavDetails;
        schReturn.scheduleVal = scheduleVal;
        return schReturn;
    }
    private static ScheduleReturn getScheduleCalYearStepNeg(agileComp__Commission_Attainment_Schedule__c scheduleOverride, 
                                                Decimal yearVal, 
                                                Decimal perVal, 
                                                Decimal gpAdjust,
                                                Decimal overridePercent) {
        
                                                    System.debug('in negative'+perVal);
        ScheduleReturn schReturn = getScheduleCalYearStepPos(scheduleOverride, yearVal, perVal, 0, overridePercent);
        Decimal scheduleVal = schReturn.scheduleVal;
        for(Integer i = schReturn.eavDetails.size() - 1; i >= 0 && gpAdjust < 0 ; i--) {
            Decimal negAdjust = 0;
            if(schReturn.eavDetails[i].agileComp__GP_Earned__c > -gpAdjust) {
                negAdjust = gpAdjust;
                gpAdjust = 0;
            }
            else {
                negAdjust = -schReturn.eavDetails[i].agileComp__GP_Earned__c;
                gpAdjust -= negAdjust;
            }
            schReturn.eavDetails[i].agileComp__GP_Adjust__c = negAdjust;
            scheduleVal -=  schReturn.eavDetails[i].agileComp__Comm_Attained__c;
            if (schReturn.eavDetails[i].agileComp__Override_Percent__c == null || schReturn.eavDetails[i].agileComp__Override_Percent__c <= 0) {
                schReturn.eavDetails[i].agileComp__Comm_Attained__c = (schReturn.eavDetails[i].agileComp__GP_Earned__c + negAdjust) * schReturn.eavDetails[i].agileComp__Original_Percent__c * 0.01;
            }
            else {
                schReturn.eavDetails[i].agileComp__Comm_Attained__c = (schReturn.eavDetails[i].agileComp__GP_Earned__c + negAdjust) * schReturn.eavDetails[i].agileComp__Override_Percent__c * 0.01;
            }
            scheduleVal += schReturn.eavDetails[i].agileComp__Comm_Attained__c;
        }
        schReturn.scheduleVal = scheduleVal; 
        return schReturn;
    }
    private static ScheduleReturn getScheduleCalYearTier(agileComp__Commission_Attainment_Schedule__c scheduleOverride, 
                                                Decimal yearVal, 
                                                Decimal perVal, 
                                                Decimal gpAdjust,
                                                Decimal overridePercent) {
        ScheduleReturn schReturn = new ScheduleReturn();
        Decimal scheduleVal = 0;
        List<agileComp__commissionEmployeeAttainedDetail__c> eavDetails = new List<agileComp__commissionEmployeeAttainedDetail__c>();
        for (agileComp__Commission_Attainment_Schedule_Item__c scheduleTeam : scheduleOverride.agileComp__Commission_Attainment_Schedule_Items__r) {
            Decimal percentage = overridePercent;
            if (yearVal >= scheduleTeam.agileComp__Amount_From__c && yearVal <= scheduleTeam.agileComp__Amount_To__c) {
                if (percentage == null) {
                    percentage = scheduleTeam.agileComp__Percent__c;
                }
                eavDetails.add(new agileComp__commissionEmployeeAttainedDetail__c(agileComp__To__c = scheduleTeam.agileComp__Amount_To__c,
                                                                                agileComp__From__c = scheduleTeam.agileComp__Amount_From__c,
                                                                                agileComp__GP_Earned__c = perVal,
                                                                                agileComp__Commission_Attainment_Schedule_Item__c = scheduleTeam.Id,
                                                                                agileComp__GP_Adjust__c = gpAdjust,
                                                                                agileComp__Original_Percent__c = scheduleTeam.agileComp__Percent__c,
                                                                                agileComp__Override_Percent__c = overridePercent,
                                                                                agileComp__Comm_Attained__c = (perVal + gpAdjust)  * percentage * 0.01));
                scheduleVal = (perVal + gpAdjust)  * percentage * 0.01;
                break;
            }
        }
        schReturn.eavDetails = eavDetails;
        schReturn.scheduleVal = scheduleVal;
        return schReturn;
    }
    private static ScheduleReturn getScheduleCalculatedVal(agileComp__Commission_Attainment_Schedule__c scheduleOverride, 
                                                            Decimal baseVal, 
                                                            Decimal perVal, 
                                                            Decimal gpAdjust, 
                                                            Decimal overridePercent, 
                                                            Decimal teamGPAdjust) {
        ScheduleReturn schReturn = new ScheduleReturn();
        Decimal scheduleVal = 0;
        List<agileComp__commissionEmployeeAttainedDetail__c> eavDetails = new List<agileComp__commissionEmployeeAttainedDetail__c>();

        if (scheduleOverride.agileComp__Calculation_Type__c == 'Step') {
            for (agileComp__Commission_Attainment_Schedule_Item__c scheduleTeam : scheduleOverride.agileComp__Commission_Attainment_Schedule_Items__r) {
                Decimal percentage = overridePercent;
                if (perVal >= scheduleTeam.agileComp__Amount_From__c && perVal > scheduleTeam.agileComp__Amount_To__c) {
                    if (percentage == null) {
                        percentage = scheduleTeam.agileComp__Percent__c;
                    }
                    eavDetails.add(new agileComp__commissionEmployeeAttainedDetail__c(
                        agileComp__To__c = scheduleTeam.agileComp__Amount_To__c,
                        agileComp__From__c = scheduleTeam.agileComp__Amount_From__c,
                        agileComp__GP_Earned__c = (scheduleTeam.agileComp__Amount_To__c - scheduleTeam.agileComp__Amount_From__c),
                        agileComp__Commission_Attainment_Schedule_Item__c = scheduleTeam.Id,
                        agileComp__Original_Percent__c = scheduleTeam.agileComp__Percent__c,
                        agileComp__GP_Adjust__c = 0,
                        agileComp__Comm_Attained__c = (scheduleTeam.agileComp__Amount_To__c - scheduleTeam.agileComp__Amount_From__c) * percentage * 0.01,
                        agileComp__Override_Percent__c = overridePercent));
                    scheduleVal += (scheduleTeam.agileComp__Amount_To__c - scheduleTeam.agileComp__Amount_From__c) * percentage * 0.01;
                }
                else if (perVal >= scheduleTeam.agileComp__Amount_From__c && perVal <= scheduleTeam.agileComp__Amount_To__c) {
                    Decimal posgpAdjust = 0;
                    if(gpAdjust > 0) {
                        if((scheduleTeam.agileComp__Amount_To__c - perVal) > gpAdjust) {
                            posgpAdjust = gpAdjust;
                            gpAdjust = 0;
                        }
                        else {
                            posgpAdjust = (scheduleTeam.agileComp__Amount_To__c - perVal);
                            gpAdjust -= posgpAdjust;
                        }
                    }
                    if (percentage == null) {
                        percentage = scheduleTeam.agileComp__Percent__c;
                    }
                    eavDetails.add(new agileComp__commissionEmployeeAttainedDetail__c(
                                    agileComp__To__c = scheduleTeam.agileComp__Amount_To__c,
                                    agileComp__From__c = scheduleTeam.agileComp__Amount_From__c,
                                    agileComp__GP_Earned__c = (perVal-scheduleTeam.agileComp__Amount_From__c),
                                    agileComp__Commission_Attainment_Schedule_Item__c = scheduleTeam.Id,
                                    agileComp__GP_Adjust__c = posgpAdjust,
                                    agileComp__Original_Percent__c = scheduleTeam.agileComp__Percent__c,
                                    agileComp__Comm_Attained__c = (perVal-scheduleTeam.agileComp__Amount_From__c+posgpAdjust) * percentage * 0.01,
                                    agileComp__Override_Percent__c = overridePercent));
                    scheduleVal +=(perVal-scheduleTeam.agileComp__Amount_From__c+posgpAdjust) * percentage * 0.01;
                }
                else if (perVal < 0 && baseVal > 0) {
                    Decimal posgpAdjust = 0;
                    if(gpAdjust > 0) {
                        if((scheduleTeam.agileComp__Amount_To__c - perVal) > gpAdjust) {
                            posgpAdjust = gpAdjust;
                            gpAdjust = 0;
                        }
                        else {
                            posgpAdjust = (scheduleTeam.agileComp__Amount_To__c - perVal);
                            gpAdjust -= posgpAdjust;
                        }
                    }
                    if (percentage == null) {
                        percentage = scheduleTeam.agileComp__Percent__c;
                    }
                    eavDetails.add(new agileComp__commissionEmployeeAttainedDetail__c(
                                    agileComp__To__c = scheduleTeam.agileComp__Amount_To__c,
                                    agileComp__From__c = scheduleTeam.agileComp__Amount_From__c,
                                    agileComp__GP_Earned__c = perVal,
                                    agileComp__Commission_Attainment_Schedule_Item__c = scheduleTeam.Id,
                                    agileComp__GP_Adjust__c = posgpAdjust,
                                    agileComp__Original_Percent__c = scheduleTeam.agileComp__Percent__c,
                                    agileComp__Comm_Attained__c = (perVal-scheduleTeam.agileComp__Amount_From__c+posgpAdjust) * percentage * 0.01,
                                    agileComp__Override_Percent__c = overridePercent));
                    scheduleVal +=(perVal-scheduleTeam.agileComp__Amount_From__c+posgpAdjust) * percentage * 0.01;
                    perVal = 0;
                }
                else if(gpAdjust > 0 && baseVal > 0) {
                    Decimal posgpAdjust = 0;
                    if((scheduleTeam.agileComp__Amount_To__c - scheduleTeam.agileComp__Amount_From__c) > gpAdjust) {
                        posgpAdjust = gpAdjust;
                        gpAdjust = 0;
                    }
                    else {
                            posgpAdjust = (scheduleTeam.agileComp__Amount_To__c - scheduleTeam.agileComp__Amount_From__c);
                            gpAdjust -= posgpAdjust;
                        }
                    if (percentage == null) {
                        percentage = scheduleTeam.agileComp__Percent__c;
                    }
                    eavDetails.add(new agileComp__commissionEmployeeAttainedDetail__c(
                                                                                    agileComp__To__c = scheduleTeam.agileComp__Amount_To__c,
                                                                                    agileComp__From__c = scheduleTeam.agileComp__Amount_From__c,
                                                                                    agileComp__GP_Earned__c = 0,
                                                                                    agileComp__Commission_Attainment_Schedule_Item__c = scheduleTeam.Id,
                                                                                    agileComp__GP_Adjust__c = posgpAdjust,
                                                                                    agileComp__Original_Percent__c = scheduleTeam.agileComp__Percent__c,
                                                                                    agileComp__Comm_Attained__c = posgpAdjust * percentage * 0.01,
                                                                                    agileComp__Override_Percent__c = overridePercent));
                    scheduleVal += posgpAdjust * percentage * 0.01;
                }
            }
            if(gpAdjust < 0) {
                for(Integer i = eavDetails.size() - 1; i >= 0 && gpAdjust < 0 ; i--) {
                    Decimal negAdjust = 0;
                    System.debug('gpAdjust >>>>.'+ gpAdjust);
                    System.debug(eavDetails[i]);
                    if(eavDetails[i].agileComp__GP_Earned__c > -gpAdjust) {
                        negAdjust = gpAdjust;
                        gpAdjust = 0;
                    }
                    else {
                        negAdjust = -eavDetails[i].agileComp__GP_Earned__c;
                        gpAdjust -= negAdjust;
                    }
                    eavDetails[i].agileComp__GP_Adjust__c = negAdjust;
                    scheduleVal -=  eavDetails[i].agileComp__Comm_Attained__c;
                    if (eavDetails[i].agileComp__Override_Percent__c == null || eavDetails[i].agileComp__Override_Percent__c <= 0) {
                        eavDetails[i].agileComp__Comm_Attained__c = (eavDetails[i].agileComp__GP_Earned__c + negAdjust) * eavDetails[i].agileComp__Original_Percent__c * 0.01;
                    }
                    else {
                        eavDetails[i].agileComp__Comm_Attained__c = (eavDetails[i].agileComp__GP_Earned__c + negAdjust) * eavDetails[i].agileComp__Override_Percent__c * 0.01;
                    }
                    scheduleVal += eavDetails[i].agileComp__Comm_Attained__c;
                }
            }
        }
        else if (scheduleOverride.agileComp__Calculation_Type__c == 'Tier Attained') {
            for (agileComp__Commission_Attainment_Schedule_Item__c scheduleTeam : scheduleOverride.agileComp__Commission_Attainment_Schedule_Items__r) {
                Decimal percentage = overridePercent;
                if (perVal+teamGPAdjust >= scheduleTeam.agileComp__Amount_From__c && perVal+teamGPAdjust <= scheduleTeam.agileComp__Amount_To__c) {
                    if (percentage == null) {
                        percentage = scheduleTeam.agileComp__Percent__c;
                    }
                    eavDetails.add(new agileComp__commissionEmployeeAttainedDetail__c(agileComp__To__c = scheduleTeam.agileComp__Amount_To__c,
                                                                                    agileComp__From__c = scheduleTeam.agileComp__Amount_From__c,
                                                                                    agileComp__GP_Earned__c = baseVal - gpAdjust,
                                                                                    agileComp__Commission_Attainment_Schedule_Item__c = scheduleTeam.Id,
                                                                                    agileComp__GP_Adjust__c = gpAdjust,
                                                                                    agileComp__Original_Percent__c = scheduleTeam.agileComp__Percent__c,
                                                                                    agileComp__Override_Percent__c = overridePercent,
                                                                                    agileComp__Comm_Attained__c = baseVal * percentage * 0.01));
                    scheduleVal = baseVal * percentage * 0.01;
                    break;
                }
            }
        }
        schReturn.scheduleVal = scheduleVal;
        // schReturn.percentage = percentage;
        schReturn.eavDetails = eavDetails;
        return schReturn;
    }
    public class ResultWrapper {
        @AuraEnabled public String state;
        @AuraEnabled public String message;
    }
    public class ScheduleReturn {
        @AuraEnabled public Decimal scheduleVal;
        // @AuraEnabled public Decimal percentage;
        @AuraEnabled public List<agileComp__commissionEmployeeAttainedDetail__c> eavDetails;
    }
    public class EAVWrapper {
        public agileComp__commissionEmployeeAttainedValue__c eav;
        public List<agileComp__commissionEmployeeAttainedDetail__c> eavDetails;
        public List<agileComp__commissionAdjustmentDetail__c> adjs;
        public EAVWrapper() {
            eavDetails = new List<agileComp__commissionEmployeeAttainedDetail__c>();
            adjs = new List<agileComp__commissionAdjustmentDetail__c>();
        }
    }
}