public with sharing class AC_EmployeeAttainmentTriggerHelper {
    public static List<String> eavIdsList = new List<String>();
    public static Map<String, Decimal> oldMapAdjustment = new Map<String, Decimal>();
    public static void updateSystemGeneratedCommission(List<String> eavIds,Map<Id,agileComp__commissionEmployeeAttainedValue__c> newMap) {
        List<agileComp__commissionAdjustmentDetail__c> adjsToUpdate = new List<agileComp__commissionAdjustmentDetail__c>();
        List<agileComp__commissionAdjustmentDetail__c> adjs = [SELECT Id, agileComp__Adjustment_Amount__c,agileComp__Commission_Employee_Attained_Value_Recor__c
                                                                FROM agileComp__commissionAdjustmentDetail__c
                                                                WHERE agileComp__Commission_Employee_Attained_Value_Recor__c IN : eavIds
                                                                AND agileComp__System_Generated__c = true];
        for (agileComp__commissionAdjustmentDetail__c adj : adjs) {
            agileComp__commissionEmployeeAttainedValue__c eav = newMap.get(adj.agileComp__Commission_Employee_Attained_Value_Recor__c);
            adj.agileComp__Adjustment_Amount__c = eav.agileComp__Commission_Period_Payout__c - eav.agileComp__Original_Commission_Attained__c;
            adjsToUpdate.add(adj);
        }
        update adjsToUpdate;
        adjs = [SELECT Id, agileComp__Adjustment_Amount__c,agileComp__Commission_Employee_Attained_Value_Recor__c
                                                                FROM agileComp__commissionAdjustmentDetail__c
                                                                WHERE agileComp__Commission_Employee_Attained_Value_Recor__c IN : eavIds
                                                                AND agileComp__System_Generated__c = true];
                                                                
    }

    public static void updateEAVDetails(List<String> eavIds, Map<Id,agileComp__commissionEmployeeAttainedValue__c> newMap, Map<Id,agileComp__commissionEmployeeAttainedValue__c> oldMap) {
        List<String> scheduleIds = new List<String>();
        List<String> teamPayoutMethodsList = new List<String>{'Commission Year Individual Period Payout Tier', 'Commission Year Total Team Period Payout Tier', 'Commission Year Individual Period Payout Step', 'Commission Year Total Team Period Payout Step'};
        List<EADRemainWrapper> EADRemainList = new List<EADRemainWrapper>();
        List<agileComp__commissionEmployeeAttainedDetail__c> commissionYearList = new List<agileComp__commissionEmployeeAttainedDetail__c>();
        List<EADRemainWrapper> EADTierRemainList = new List<EADRemainWrapper>();
        List<EADRemainWrapper> EADStepRemainList = new List<EADRemainWrapper>();
        List<agileComp__commissionEmployeeAttainedDetail__c> eadRecordsToUpdate = new List<agileComp__commissionEmployeeAttainedDetail__c>();
        List<agileComp__commissionEmployeeAttainedDetail__c> eadRecordsToDelete = new List<agileComp__commissionEmployeeAttainedDetail__c>();
        for(agileComp__commissionEmployeeAttainedValue__c eav : [SELECT Id,agileComp__Commission_Team__c,agileComp__Commission_Period__c,agileComp__Created_From_Team__c,
                                                                    agileComp__Overridden_Attainment_Percentage__c,agileComp__Commission_Attainment_Schedule__c,
                                                                    agileComp__Calculation_Type__c,agileComp__Team_GP_Adjustment__c,
                                                                (SELECT Id,agileComp__Comm_Attained__c,agileComp__GP_Adjust__c,agileComp__Original_Percent__c,
                                                                agileComp__GP_Earned__c,agileComp__From__c,agileComp__To__c,agileComp__Override_Percent__c
                                                                FROM agileComp__Commission_Employee_Attained_Detail__r
                                                                ORDER BY agileComp__From__c DESC)
                                                                FROM agileComp__commissionEmployeeAttainedValue__c 
                                                                WHERE Id IN :eavIds]) {


            agileComp__commissionEmployeeAttainedValue__c newEAV = newMap.get(eav.Id);
            List<agileComp__commissionEmployeeAttainedDetail__c> eadList = eav.agileComp__Commission_Employee_Attained_Detail__r;
            Decimal changeAdj = 0.0;

            if(newEAV.agileComp__Created_From_Team__c){
                changeAdj = newMap.get(eav.Id).agileComp__Team_GP_Adjustment__c - oldMap.get(eav.Id).agileComp__Team_GP_Adjustment__c;
            }else{
                if(oldMapAdjustment.containsKey(eav.Id)){
                    changeAdj = newMap.get(eav.Id).agileComp__GP_Adjustments__c - oldMapAdjustment.get(eav.Id);
                }else{
                    changeAdj = newMap.get(eav.Id).agileComp__GP_Adjustments__c - oldMap.get(eav.Id).agileComp__GP_Adjustments__c;
                }
            }
            
            if(eadList == null || eadList.isEmpty()) {
                if (changeAdj > 0) {
                    Decimal perVal = 0;
                    Decimal calVal = 0;
                    if (newEAV.agileComp__Created_From_Team__c) {
                        perVal = newEAV.agileComp__Team_Revenue_Attained__c - newEAV.agileComp__Team_Cost_Attained__c - newEAV.agileComp__Team_Freight_Cost_Attained__c;
                    }
                    else {
                        perVal = newEAV.agileComp__Original_Revenue__c - newEAV.agileComp__Original_Total_Cost__c - newEAV.agileComp__Original_Freight_Cost__c;
                    }
                    if (newEAV.agileComp__Team_Payout_Method__c == 'Total Team Contribution') {
                        calVal = newEAV.agileComp__Team_Revenue_Attained__c - newEAV.agileComp__Team_Cost_Attained__c - newEAV.agileComp__Team_Freight_Cost_Attained__c;
                    }else if(newEAV.agileComp__Team_Payout_Method__c == 'Commission Year Individual Period Payout Tier'){
                        perVal = newEAV.agileComp__Year_Original_Revenue__c - newEAV.agileComp__Year_Original_Total_Coast__c - newEAV.agileComp__Year_Freight_Cost__c;

                    }else if(newEAV.agileComp__Team_Payout_Method__c == 'Commission Year Total Team Period Payout Tier'){
                        perVal = newEAV.agileComp__Year_Team_Revenue_Attained__c - newEAV.agileComp__Year_Team_Cost_Attained__c - newEAV.agileComp__Year_Team_Freight_Cost_Attained__c;
                        
                    }else if(newEAV.agileComp__Team_Payout_Method__c == 'Commission Year Individual Period Payout Step'){
                        perVal = newEAV.agileComp__Year_Original_Revenue__c - newEAV.agileComp__Year_Original_Total_Coast__c - newEAV.agileComp__Year_Freight_Cost__c;
                        
                    }else if(newEAV.agileComp__Team_Payout_Method__c == 'Commission Year Total Team Period Payout Step'){
                        perVal = newEAV.agileComp__Year_Team_Revenue_Attained__c - newEAV.agileComp__Year_Team_Cost_Attained__c - newEAV.agileComp__Year_Team_Freight_Cost_Attained__c;
                        
                    }
                    else {
                        calVal = newEAV.agileComp__Original_Revenue__c - newEAV.agileComp__Original_Total_Cost__c - newEAV.agileComp__Original_Freight_Cost__c;
                    }
                    if(calVal + newEAV.agileComp__GP_Adjustments__c > 0 && perVal + newEAV.agileComp__GP_Adjustments__c > 0) {
                        if (newEAV.agileComp__Calculation_Type__c == 'Step'){
                            EADRemainWrapper remainInfo = new EADRemainWrapper();
                            remainInfo.changeAdj = newEAV.agileComp__GP_Adjustments__c;
                            remainInfo.eavId = eav.Id;
                            remainInfo.teamGp = eav.agileComp__Team_GP_Adjustment__c;
                            remainInfo.perVal = perVal;
                            remainInfo.scheduleId = eav.agileComp__Commission_Attainment_Schedule__c;
                            remainInfo.overridePercent = eav.agileComp__Overridden_Attainment_Percentage__c; 
                            EADStepRemainList.add(remainInfo);
                            scheduleIds.add(eav.agileComp__Commission_Attainment_Schedule__c);
                        }
                        else {
                            EADRemainWrapper remainInfo = new EADRemainWrapper();
                            remainInfo.changeAdj = newEAV.agileComp__GP_Adjustments__c;
                            remainInfo.eavId = eav.Id;
                            remainInfo.teamTrue = eav.agileComp__Created_From_Team__c;
                            remainInfo.teamGp = eav.agileComp__Team_GP_Adjustment__c;
                            remainInfo.scheduleId = eav.agileComp__Commission_Attainment_Schedule__c;
                            remainInfo.overridePercent = eav.agileComp__Overridden_Attainment_Percentage__c; 
                            remainInfo.perVal = perVal;
                            remainInfo.ead = new agileComp__commissionEmployeeAttainedDetail__c(agileComp__GP_Adjust__c = newEAV.agileComp__GP_Adjustments__c, agileComp__GP_Earned__c = calVal,agileComp__Commission_Employee_Attained_Value__c = eav.Id); 
                            EADTierRemainList.add(remainInfo);
                            scheduleIds.add(eav.agileComp__Commission_Attainment_Schedule__c);
                        }
                    }
                }
                continue;
            }
            if (eav.agileComp__Calculation_Type__c == 'Tier Attained' && !teamPayoutMethodsList.contains(newEAV.agileComp__Team_Payout_Method__c)) {

                agileComp__commissionEmployeeAttainedDetail__c ead = eadList[0];
                Decimal perVal = ead.agileComp__GP_Earned__c;
                Decimal gpAdjustment = 0.0;
                if(newEAV.agileComp__Created_From_Team__c){
                    gpAdjustment = newEAV.agileComp__Team_GP_Adjustment__c;
                }else{
                    gpAdjustment = newEAV.agileComp__GP_Adjustments__c;
                }
                if (newEAV.agileComp__Created_From_Team__c && newEAV.agileComp__Team_Payout_Method__c == 'Individual Contribution') {
                    perVal = newEAV.agileComp__Team_Revenue_Attained__c - newEAV.agileComp__Team_Cost_Attained__c - newEAV.agileComp__Team_Freight_Cost_Attained__c;
                }
                if (newEAV.agileComp__GP_Adjustments__c + perVal <= 0) {
                    eadRecordsToDelete.add(ead);
                    continue;
                }
                if(ead.agileComp__From__c <= gpAdjustment + perVal &&  ead.agileComp__To__c  >= gpAdjustment + perVal) {
                    ead.agileComp__GP_Adjust__c = gpAdjustment;
                    if (eav.agileComp__Overridden_Attainment_Percentage__c != null && eav.agileComp__Overridden_Attainment_Percentage__c > 0) {
                        ead.agileComp__Comm_Attained__c = (ead.agileComp__GP_Adjust__c + ead.agileComp__GP_Earned__c) * eav.agileComp__Overridden_Attainment_Percentage__c * 0.01;
                    }
                    else {
                        ead.agileComp__Comm_Attained__c = (ead.agileComp__GP_Adjust__c + ead.agileComp__GP_Earned__c) * ead.agileComp__Original_Percent__c * 0.01;
                    }
                    if (ead.agileComp__GP_Earned__c + ead.agileComp__GP_Adjust__c <= 0) {
                        eadRecordsToDelete.add(ead);
                    }
                    else {
                        eadRecordsToUpdate.add(ead);
                    }
                }
                else {
                    EADRemainWrapper remainInfo = new EADRemainWrapper();
                    remainInfo.changeAdj = newEAV.agileComp__GP_Adjustments__c;
                    remainInfo.eavId = eav.Id;
                    remainInfo.teamTrue = eav.agileComp__Created_From_Team__c;
                    remainInfo.teamGp = eav.agileComp__Team_GP_Adjustment__c;
                    remainInfo.scheduleId = eav.agileComp__Commission_Attainment_Schedule__c;
                    remainInfo.overridePercent = eav.agileComp__Overridden_Attainment_Percentage__c;
                    remainInfo.ead = ead; 
                    remainInfo.perVal = perVal;
                    EADTierRemainList.add(remainInfo);
                    scheduleIds.add(eav.agileComp__Commission_Attainment_Schedule__c);
                }
                continue;
            }
            Boolean isBreak = false;
               /*for (Integer i = eadList.size()-1 ; i >= 0 ; i--) {
                        if((-eadList[i].agileComp__GP_Adjust__c) == eadList[i].agileComp__GP_Earned__c){
                            continue;
                        }else if( eadList[i].agileComp__To__c - eadList[i].agileComp__From__c - eadList[i].agileComp__GP_Earned__c - eadList[i].agileComp__GP_Adjust__c >= changeAdj ){
                            eadList[i].agileComp__GP_Adjust__c += changeAdj; 
                            eadList[i].agileComp__Comm_Attained__c = (eadList[i].agileComp__GP_Earned__c+eadList[i].agileComp__GP_Adjust__c)*eadList[i].agileComp__Original_Percent__c*.01;
                            commissionYearList.add(eadlist[i]);
                        }else {
                            changeAdj = changeAdj - (eadList[i].agileComp__To__c - eadList[i].agileComp__From__c - eadList[i].agileComp__GP_Adjust__c - eadList[i].agileComp__GP_Earned__c);
                            eadList[i].agileComp__GP_Adjust__c = eadList[i].agileComp__To__c - eadList[i].agileComp__From__c - eadList[i].agileComp__GP_Earned__c;
                            eadList[i].agileComp__Comm_Attained__c = (eadList[i].agileComp__GP_Earned__c+eadList[i].agileComp__GP_Adjust__c)*eadList[i].agileComp__Original_Percent__c*.01;
                            commissionYearList.add(eadlist[i]);
                            Decimal perVal = 0.0;
                            if(eav.agileComp__Team_Payout_Method__c == 'Commission Year Individual Period Payout Tier'){
                                perVal = eav.agileComp__Year_Original_Revenue__c - eav.agileComp__Year_Original_Total_Coast__c - eav.agileComp__Year_Freight_Cost__c;
        
                            }else if(eav.agileComp__Team_Payout_Method__c == 'Commission Year Total Team Period Payout Tier'){
                                perVal = eav.agileComp__Year_Team_Revenue_Attained__c - eav.agileComp__Year_Team_Cost_Attained__c - eav.agileComp__Year_Team_Freight_Cost_Attained__c;
                                
                            }else if(eav.agileComp__Team_Payout_Method__c == 'Commission Year Individual Period Payout Step'){
                                perVal = eav.agileComp__Year_Original_Revenue__c - eav.agileComp__Year_Original_Total_Coast__c - eav.agileComp__Year_Freight_Cost__c;
                                
                            }else if(newEAV.agileComp__Team_Payout_Method__c == 'Commission Year Total Team Period Payout Step'){
                                perVal = eav.agileComp__Year_Team_Revenue_Attained__c - eav.agileComp__Year_Team_Cost_Attained__c - eav.agileComp__Year_Team_Freight_Cost_Attained__c;
                            }
                            EADRemainWrapper remainInfo = new EADRemainWrapper();
                            remainInfo.changeAdj = changeAdj;
                            remainInfo.eavId = eav.Id;
                            remainInfo.lastTo = eadList[i].agileComp__To__c;
                            remainInfo.teamTrue = eav.agileComp__Created_From_Team__c;
                            remainInfo.teamGp = eav.agileComp__Team_GP_Adjustment__c;
                            remainInfo.scheduleId = eav.agileComp__Commission_Attainment_Schedule__c;
                            remainInfo.overridePercent = eav.agileComp__Overridden_Attainment_Percentage__c; 
                            EADRemainList.add(remainInfo);
                            scheduleIds.add(eav.agileComp__Commission_Attainment_Schedule__c);
                            isBreak = true;
                        }

                        if(commissionYearList.size() > 0){
                            upsert commissionYearList;
                        }
                }
            }else{*/
                
                for (agileComp__commissionEmployeeAttainedDetail__c ead : eadList) {
                    if (ead.agileComp__GP_Adjust__c >= 0) {
                        if (changeAdj > 0) {
                            if (ead.agileComp__To__c - ead.agileComp__From__c - ead.agileComp__GP_Earned__c - ead.agileComp__GP_Adjust__c >= changeAdj) {
                                ead.agileComp__GP_Adjust__c = ead.agileComp__GP_Adjust__c + changeAdj;
                                // eadRecordsToUpdate.add(ead);
                                // break;
                                isBreak = true; 
                            }
                            else {
                                changeAdj = changeAdj - (ead.agileComp__To__c - ead.agileComp__From__c - ead.agileComp__GP_Adjust__c - ead.agileComp__GP_Earned__c);
                                ead.agileComp__GP_Adjust__c = ead.agileComp__To__c - ead.agileComp__From__c - ead.agileComp__GP_Earned__c;
                                // eadRecordsToUpdate.add(ead);
                                EADRemainWrapper remainInfo = new EADRemainWrapper();
                                remainInfo.changeAdj = changeAdj;
                                remainInfo.eavId = eav.Id;
                                remainInfo.lastTo = ead.agileComp__To__c;
                                remainInfo.teamTrue = eav.agileComp__Created_From_Team__c;
                                remainInfo.teamGp = eav.agileComp__Team_GP_Adjustment__c;
                                remainInfo.scheduleId = eav.agileComp__Commission_Attainment_Schedule__c;
                                remainInfo.overridePercent = eav.agileComp__Overridden_Attainment_Percentage__c; 
                                EADRemainList.add(remainInfo);
                                scheduleIds.add(eav.agileComp__Commission_Attainment_Schedule__c);
                                // eadRecordsToUpdate.addAll(addEADRecords(eav.Id,));
                                // create new detail records
                                isBreak = true;
                            }
                        }
                        else if (changeAdj < 0) {
                            if (ead.agileComp__GP_Adjust__c + ead.agileComp__GP_Earned__c >= -changeAdj) {
                                ead.agileComp__GP_Adjust__c += changeAdj;
                                isBreak = true;
                            }
                            else {
                                changeAdj = changeAdj + ead.agileComp__GP_Adjust__c + ead.agileComp__GP_Earned__c;
                                ead.agileComp__GP_Adjust__c = -ead.agileComp__GP_Earned__c;
                                // eadRecordsToUpdate.add(ead); 
                            }
                        }
                    }
                    else {
                        if (changeAdj > 0) {
                            if (ead.agileComp__GP_Earned__c > -ead.agileComp__GP_Adjust__c) {
                                if (changeAdj <= ead.agileComp__To__c - ead.agileComp__From__c - ead.agileComp__GP_Earned__c - ead.agileComp__GP_Adjust__c) {
                                    ead.agileComp__GP_Adjust__c = changeAdj + ead.agileComp__GP_Adjust__c;
                                    isBreak = true;
                                }
                                else {
                                    changeAdj = changeAdj - (ead.agileComp__To__c - ead.agileComp__From__c - ead.agileComp__GP_Earned__c - ead.agileComp__GP_Adjust__c);
                                    ead.agileComp__GP_Adjust__c = ead.agileComp__To__c - ead.agileComp__From__c - ead.agileComp__GP_Earned__c;
                                }
                            }
                            else {
                                //need to check from top
                                List<agileComp__commissionEmployeeAttainedDetail__c> tempList = eav.agileComp__Commission_Employee_Attained_Detail__r;
                                for(Integer i = tempList.size() - 1; i >= 0; i--) {
                                    if (tempList[i].agileComp__GP_Adjust__c < 0) {
                                        if (-tempList[i].agileComp__GP_Adjust__c > changeAdj) {
                                            tempList[i].agileComp__GP_Adjust__c += changeAdj;
                                            if (tempList[i].agileComp__Override_Percent__c != null && tempList[i].agileComp__Override_Percent__c > 0) {
                                                tempList[i].agileComp__Comm_Attained__c = (tempList[i].agileComp__GP_Earned__c + tempList[i].agileComp__GP_Adjust__c) * tempList[i].agileComp__Override_Percent__c * 0.01;
                                            }
                                            else {
                                                tempList[i].agileComp__Comm_Attained__c = (tempList[i].agileComp__GP_Earned__c + tempList[i].agileComp__GP_Adjust__c) * tempList[i].agileComp__Original_Percent__c * 0.01;    
                                            }
                                            if (tempList[i].agileComp__GP_Earned__c <= 0 && tempList[i].agileComp__GP_Adjust__c <= 0) {
                                                eadRecordsToDelete.add(tempList[i]);
                                            }
                                            else {
                                                eadRecordsToUpdate.add(tempList[i]);
                                            }
                                            
                                            break;
                                        }
                                        else {
                                            changeAdj = changeAdj + tempList[i].agileComp__GP_Adjust__c;
                                            tempList[i].agileComp__GP_Adjust__c = 0;
                                            if (tempList[i].agileComp__Override_Percent__c != null && tempList[i].agileComp__Override_Percent__c > 0) {
                                                tempList[i].agileComp__Comm_Attained__c = (tempList[i].agileComp__GP_Earned__c + tempList[i].agileComp__GP_Adjust__c) * tempList[i].agileComp__Override_Percent__c * 0.01;
                                            }
                                            else {
                                                tempList[i].agileComp__Comm_Attained__c = (tempList[i].agileComp__GP_Earned__c + tempList[i].agileComp__GP_Adjust__c) * tempList[i].agileComp__Original_Percent__c * 0.01;    
                                            }
                                            if (tempList[i].agileComp__GP_Earned__c <= 0 && tempList[i].agileComp__GP_Adjust__c <= 0) {
                                                eadRecordsToDelete.add(tempList[i]);
                                            }
                                            else {
                                                eadRecordsToUpdate.add(tempList[i]);
                                            }
                                        }
                                    }
                                    if (i == 0 && changeAdj > 0) {
                                        // add more detail records
                                        EADRemainWrapper remainInfo = new EADRemainWrapper();
                                        remainInfo.changeAdj = changeAdj;
                                        remainInfo.eavId = eav.Id;
                                        remainInfo.lastTo = ead.agileComp__To__c;
                                        remainInfo.teamTrue = eav.agileComp__Created_From_Team__c;
                                        remainInfo.teamGp = eav.agileComp__Team_GP_Adjustment__c;
                                        remainInfo.scheduleId = eav.agileComp__Commission_Attainment_Schedule__c;
                                        remainInfo.overridePercent = eav.agileComp__Overridden_Attainment_Percentage__c;
                                        EADRemainList.add(remainInfo);
                                        scheduleIds.add(eav.agileComp__Commission_Attainment_Schedule__c);
                                    }
                                }
                                break;
                            }
                        }
                        else if (changeAdj < 0) {
                            if (ead.agileComp__GP_Earned__c + ead.agileComp__GP_Adjust__c > 0) {
                                if (ead.agileComp__GP_Earned__c + ead.agileComp__GP_Adjust__c >= -changeAdj) {
                                    ead.agileComp__GP_Adjust__c += changeAdj;
                                    isBreak = true;
                                }
                                else {
                                    changeAdj = changeAdj + ead.agileComp__GP_Earned__c + ead.agileComp__GP_Adjust__c;
                                    ead.agileComp__GP_Adjust__c = -ead.agileComp__GP_Earned__c;
                                    // eadRecordsToUpdate.add(ead);
                                }
                            }
                        }
                    }
                    if (ead.agileComp__Override_Percent__c != null && ead.agileComp__Override_Percent__c > 0) {
                        ead.agileComp__Comm_Attained__c = (ead.agileComp__GP_Earned__c + ead.agileComp__GP_Adjust__c) * ead.agileComp__Override_Percent__c * 0.01;
                    }
                    else {
                        ead.agileComp__Comm_Attained__c = (ead.agileComp__GP_Earned__c + ead.agileComp__GP_Adjust__c) * ead.agileComp__Original_Percent__c * 0.01;    
                    }
                    if (ead.agileComp__GP_Earned__c <=0 && ead.agileComp__GP_Adjust__c <= 0) {
                        eadRecordsToDelete.add(ead);
                    }
                    else {
                        eadRecordsToUpdate.add(ead);
                    }
                    if (isBreak) {
                        break;
                    }
                }
            }
        //}
        Map<Id,agileComp__Commission_Attainment_Schedule__c> allScheduleAttMap = new Map<Id,agileComp__Commission_Attainment_Schedule__c>(
                                                                                        [SELECT Id,agileComp__Calculation_Type__c,
                                                                                        (SELECT Id,agileComp__Amount_From__c,agileComp__Amount_To__c,
                                                                                                agileComp__Percent__c
                                                                                        FROM agileComp__Commission_Attainment_Schedule_Items__r
                                                                                        ORDER BY agileComp__Amount_From__c)
                                                                                        FROM agileComp__Commission_Attainment_Schedule__c
                                                                                        WHERE Id IN :scheduleIds
                                                                                        AND agileComp__Active__c = true]);
        
        for (EADRemainWrapper EADRemain : EADRemainList) {
            EADRemain.schedule = allScheduleAttMap.get(EADRemain.scheduleId);
            eadRecordsToUpdate.addAll(addMoreEmployementDetailRecords(EADRemain));
        }
        System.debug(EADTierRemainList.size() > 0);
        for (EADRemainWrapper EADRemain : EADTierRemainList) {
            EADRemain.schedule = allScheduleAttMap.get(EADRemain.scheduleId);
            eadRecordsToUpdate.add(addMoreEmployementDetailRecordsOFTier(EADRemain));
        }
        for (EADRemainWrapper EADRemain : EADStepRemainList) {
            EADRemain.schedule = allScheduleAttMap.get(EADRemain.scheduleId);
            eadRecordsToUpdate.addAll(addMoreEmployementDetailRecordsOFStep(EADRemain));
        }
        upsert eadRecordsToUpdate;
        delete eadRecordsToDelete;
    }

    private static agileComp__commissionEmployeeAttainedDetail__c addMoreEmployementDetailRecordsOFTier(EADRemainWrapper EADRemain) {
        
        agileComp__commissionEmployeeAttainedDetail__c ead = EADRemain.ead;
        Decimal totalCal = 0.0;
        Decimal changeAdj = 0.0;
        if(EADRemain.teamTrue){
            totalCal = EADRemain.perVal + EADRemain.teamGp;
            changeAdj = EADRemain.teamGp;
        }else{
            totalCal =  EADRemain.perVal + ead.agileComp__GP_Adjust__c;
            changeAdj = EADRemain.changeAdj;
        }
        ead.agileComp__GP_Adjust__c = changeAdj;
        for (agileComp__Commission_Attainment_Schedule_Item__c item : EADRemain.schedule.agileComp__Commission_Attainment_Schedule_Items__r) {
         
            if (totalCal <= item.agileComp__Amount_To__c && totalCal >= item.agileComp__Amount_From__c) {
                ead.agileComp__To__c = item.agileComp__Amount_To__c;
                ead.agileComp__From__c = item.agileComp__Amount_From__c;
                ead.agileComp__Commission_Attainment_Schedule_Item__c = item.Id;
                ead.agileComp__GP_Adjust__c = changeAdj;
                ead.agileComp__Original_Percent__c = item.agileComp__Percent__c;
                if (ead.agileComp__Override_Percent__c != null && ead.agileComp__Override_Percent__c > 0) {
                    ead.agileComp__Comm_Attained__c = (changeAdj + ead.agileComp__GP_Earned__c) * ead.agileComp__Override_Percent__c * 0.01;
                }
                else {
                    ead.agileComp__Comm_Attained__c = (changeAdj + ead.agileComp__GP_Earned__c) * item.agileComp__Percent__c * 0.01;
                }
                break;
            }
        }
        return ead;
    }

    private static List<agileComp__commissionEmployeeAttainedDetail__c> addMoreEmployementDetailRecordsOFStep(EADRemainWrapper EADRemain) {
        
        Decimal changeAdj = EADRemain.changeAdj;
        Decimal perVal = EADRemain.perVal;
        Decimal totalCal = EADRemain.perVal + changeAdj;
        List<agileComp__commissionEmployeeAttainedDetail__c> eads = new List<agileComp__commissionEmployeeAttainedDetail__c>();
        for (agileComp__Commission_Attainment_Schedule_Item__c item : EADRemain.schedule.agileComp__Commission_Attainment_Schedule_Items__r) {
            if (changeAdj + perVal > 0) {
                Decimal percent = EADRemain.overridePercent;
                Decimal posgpAdjust = 0;
                Decimal posVal = 0;
                if (percent == null || percent <= 0 ) {
                    percent = item.agileComp__Percent__c;
                }
                if (changeAdj + perVal <= item.agileComp__Amount_To__c - item.agileComp__Amount_From__c) {
                    posgpAdjust = changeAdj + perVal;
                    changeAdj = 0;
                    changeAdj = perVal;
                }
                else {
                    if (perVal > 0) {
                        if (perVal <= item.agileComp__Amount_To__c - item.agileComp__Amount_From__c) {
                            posVal = perVal;
                            perVal = 0;
                        }
                        else {
                            posVal = item.agileComp__Amount_To__c - item.agileComp__Amount_From__c - perVal;
                            perVal = perVal - item.agileComp__Amount_To__c - item.agileComp__Amount_From__c;
                        }
                    }
                    else {
                        posVal = perVal;
                        perVal = 0;
                    }
                    posgpAdjust = item.agileComp__Amount_To__c - item.agileComp__Amount_From__c - perVal; 
                    changeAdj = changeAdj - posgpAdjust;
                }
                eads.add(new agileComp__commissionEmployeeAttainedDetail__c(
                    agileComp__To__c = item.agileComp__Amount_To__c,
                    agileComp__From__c = item.agileComp__Amount_From__c,
                    agileComp__GP_Earned__c = perVal,
                    agileComp__Commission_Attainment_Schedule_Item__c = item.Id,
                    agileComp__GP_Adjust__c = posgpAdjust,
                    agileComp__Original_Percent__c = item.agileComp__Percent__c,
                    agileComp__Comm_Attained__c = posgpAdjust * percent * 0.01,
                    agileComp__Override_Percent__c = EADRemain.overridePercent,
                    agileComp__Commission_Employee_Attained_Value__c = EADRemain.eavId
                ));
            }
        }
        return eads;
    }
    private static List<agileComp__commissionEmployeeAttainedDetail__c> addMoreEmployementDetailRecords(EADRemainWrapper EADRemain) {
        Decimal changeAdj = EADRemain.changeAdj;
        List<agileComp__commissionEmployeeAttainedDetail__c> eads = new List<agileComp__commissionEmployeeAttainedDetail__c>();
        for (agileComp__Commission_Attainment_Schedule_Item__c item : EADRemain.schedule.agileComp__Commission_Attainment_Schedule_Items__r) {
            if (item.agileComp__Amount_To__c > EADRemain.lastTo && changeAdj > 0) {
                Decimal percent = EADRemain.overridePercent;
                Decimal posgpAdjust = 0;
                if (percent == null || percent <= 0 ) {
                    percent = item.agileComp__Percent__c;
                }
                if (changeAdj < item.agileComp__Amount_To__c - item.agileComp__Amount_From__c) {
                    posgpAdjust = changeAdj;
                    changeAdj = 0;
                }
                else {
                    posgpAdjust = item.agileComp__Amount_To__c - item.agileComp__Amount_From__c;
                    changeAdj = changeAdj - posgpAdjust;
                }
                eads.add(new agileComp__commissionEmployeeAttainedDetail__c(
                    agileComp__To__c = item.agileComp__Amount_To__c,
                    agileComp__From__c = item.agileComp__Amount_From__c,
                    agileComp__GP_Earned__c = 0,
                    agileComp__Commission_Attainment_Schedule_Item__c = item.Id,
                    agileComp__GP_Adjust__c = posgpAdjust,
                    agileComp__Original_Percent__c = item.agileComp__Percent__c,
                    agileComp__Comm_Attained__c = posgpAdjust * percent * 0.01,
                    agileComp__Override_Percent__c = EADRemain.overridePercent,
                    agileComp__Commission_Employee_Attained_Value__c = EADRemain.eavId
                ));
            }
        }
        return eads;
    }
    public static void updateTeamAdjustment(Map<Id, agileComp__commissionEmployeeAttainedValue__c > newEavMap, Map<Id, agileComp__commissionEmployeeAttainedValue__c > oldMap) {
        if(newEavMap.values().size() > 0){
            Set<Id> teamId = new Set<Id>();
            Set<Id> aggregateteamIdSet = new Set<Id>();
            Set<Id> setOfCommisionPeriod = new Set<Id>();
            Map<String, List<String>> mapWithSubTeam = new Map<String, List<String>>();
            Map<String, Decimal> mapWithYearGpTeam = new Map<String, Decimal>();
            List<agileComp__commissionEmployeeAttainedValue__c> eavListWithComTeam = [SELECT Id, agileComp__GP_Adjustments__c, agileComp__Commission_Period__c, agileComp__Commission_Team__c,agileComp__Commission_Team__r.agileComp__Commission_Team_Rollup__c FROM agileComp__commissionEmployeeAttainedValue__c WHERE Id In:newEavMap.keySet()];
            
            for(agileComp__commissionEmployeeAttainedValue__c eav : eavListWithComTeam ){
                if(String.isnotBlank(eav.agileComp__Commission_Team__r.agileComp__Commission_Team_Rollup__c)){
                    String parentTeam = eav.agileComp__Commission_Team__r.agileComp__Commission_Team_Rollup__c;
                    if(mapWithYearGpTeam.containsKey(parentTeam)){

                        Decimal temp =  mapWithYearGpTeam.get(parentTeam);
                        temp = temp+(newEavMap.get(eav.id).agileComp__GP_Adjustments__c - oldMap.get(eav.id).agileComp__GP_Adjustments__c);
                        mapWithYearGpTeam.put(parentTeam,temp);
                        mapWithYearGpTeam.put(eav.agileComp__Commission_Team__c,temp);
                    }else{
                        mapWithYearGpTeam.put(parentTeam, newEavMap.get(eav.id).agileComp__GP_Adjustments__c - oldMap.get(eav.id).agileComp__GP_Adjustments__c);
                        mapWithYearGpTeam.put(eav.agileComp__Commission_Team__c ,newEavMap.get(eav.id).agileComp__GP_Adjustments__c - oldMap.get(eav.id).agileComp__GP_Adjustments__c);
                    }
                    teamId.add(parentTeam);
                    teamId.add(eav.agileComp__Commission_Team__c);
                    setOfCommisionPeriod.add(eav.agileComp__Commission_Period__c);
                }else{
                    if(mapWithYearGpTeam.containsKey(eav.agileComp__Commission_Team__c)){
                        Decimal temp =  mapWithYearGpTeam.get(eav.agileComp__Commission_Team__c);
                        temp = temp+(newEavMap.get(eav.id).agileComp__GP_Adjustments__c - oldMap.get(eav.id).agileComp__GP_Adjustments__c);
                        mapWithYearGpTeam.put(eav.agileComp__Commission_Team__c,temp);
                    }else{
                        mapWithYearGpTeam.put(eav.agileComp__Commission_Team__c,newEavMap.get(eav.id).agileComp__GP_Adjustments__c - oldMap.get(eav.id).agileComp__GP_Adjustments__c);
                    }
                    teamId.add(eav.agileComp__Commission_Team__c);
                    setOfCommisionPeriod.add(eav.agileComp__Commission_Period__c);
                }
            }
            List<agileComp__Commission_Team__c> commissionTeamList = [SELECt Id, (SELECT Id FROM Commission_Teams__r ) FROM agileComp__Commission_Team__c WHERE Id In : teamId];
            for(agileComp__Commission_Team__c comTeam : commissionTeamList){

                List<String> tempIdList = new List<String>();
                if(comTeam.Commission_Teams__r.size() > 0){
                    for(agileComp__Commission_Team__c team : comTeam.Commission_Teams__r){
                        tempIdList.add(team.id);
                        aggregateteamIdSet.add(team.Id);
                    }
                    aggregateteamIdSet.add(comTeam.Id);
                    mapWithSubTeam.put(comTeam.id, tempIdList);
                   
                }else{
                    mapWithSubTeam.put(comTeam.id, tempIdList);
                    aggregateteamIdSet.add(comTeam.Id);
                }
               
            }
            List<AggregateResult> allEavAgreegateList = [SELECT sum(agileComp__GP_Adjustments__c)adjust, agileComp__Commission_Team__c FROM agileComp__commissionEmployeeAttainedValue__c WHERE agileComp__Commission_Team__c In : aggregateteamIdSet AND agileComp__Commission_Period__c in : setOfCommisionPeriod group by agileComp__Commission_Team__c ];
            
            if(allEavAgreegateList.size() > 0){
                List<agileComp__commissionEmployeeAttainedValue__c> eavListToUpdate = new List<agileComp__commissionEmployeeAttainedValue__c>();
                Map<Id,Decimal> mapOfTeamAdjustment = new Map<Id,Decimal>();
                
                for(AggregateResult aggRecord  : allEavAgreegateList ){
                    mapOfTeamAdjustment.put(String.valueOf(aggRecord.get('agileComp__Commission_Team__c')), (Decimal)aggRecord.get('adjust') != null ? (Decimal)aggRecord.get('adjust') :0.0);
                }
                eavListToUpdate = [SELECT Id, agileComp__Year_Team_GP_Adjustment__c, agileComp__Team_GP_Adjustment__c,agileComp__Commission_Team__c FROM agileComp__commissionEmployeeAttainedValue__c WHERE agileComp__Commission_Team__c In : teamId AND agileComp__Commission_Period__c in : setOfCommisionPeriod];

                for(agileComp__commissionEmployeeAttainedValue__c eavRec : eavListToUpdate){
                    if(oldMap.containsKey(eavRec.id)){
                        oldMapAdjustment.put(eavRec.id,(Decimal)oldMap.get(eavRec.id).agileComp__GP_Adjustments__c);
                    }
                    if(mapWithSubTeam.containsKey(eavRec.agileComp__Commission_Team__c)){
                        AC_EmployeeAttainmentTriggerHelper.eavIdsList.add(eavRec.Id);
                        Decimal totalAdjustment =   mapOfTeamAdjustment.get(eavRec.agileComp__Commission_Team__c);
                        for(String comTeamId : mapWithSubTeam.get(eavRec.agileComp__Commission_Team__c)){
                            totalAdjustment = totalAdjustment+mapOfTeamAdjustment.get(comTeamId);
                        }
                        eavRec.agileComp__Team_GP_Adjustment__c = totalAdjustment;
                        eavRec.agileComp__Year_Team_GP_Adjustment__c = (eavRec.agileComp__Year_Team_GP_Adjustment__c >=0 ? eavRec.agileComp__Year_Team_GP_Adjustment__c : 0.0) +mapWithYearGpTeam.get(eavRec.agileComp__Commission_Team__c);
                    }else{
                        eavRec.agileComp__Year_Team_GP_Adjustment__c = (eavRec.agileComp__Year_Team_GP_Adjustment__c >=0 ? eavRec.agileComp__Year_Team_GP_Adjustment__c : 0.0) + mapWithYearGpTeam.get(eavRec.agileComp__Commission_Team__c);
                        eavRec.agileComp__Team_GP_Adjustment__c = mapOfTeamAdjustment.get(eavRec.agileComp__Commission_Team__c);
                    }
                }
                if(eavListToUpdate.size() > 0){
                    update eavListToUpdate;
                }
            }
        }
    }
    class EADRemainWrapper {
        Decimal changeAdj;
        Decimal overridePercent;
        Decimal perVal;
        Decimal teamGp;
        Boolean teamTrue;
        String eavId;
        Decimal lastTo;
        String scheduleId;
        agileComp__Commission_Attainment_Schedule__c schedule;
        agileComp__commissionEmployeeAttainedDetail__c ead;
    }
}