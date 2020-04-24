public with sharing class AC_EmployeeAdjustmentItems {
    @AuraEnabled
    public static IntialWrapper getData(){
        try {
            AC_SecurityUtils.checkRead( agileComp__Commission_Sales_Rep__c.SObjectType,new List<String> {
                'Name'
            });
            AC_SecurityUtils.checkRead( agileComp__CommissionPeriod__c.SObjectType,new List<String> {
                'Name'
            });
            List<agileComp__CommissionPeriod__c> periodList = new List<agileComp__CommissionPeriod__c>();
            for(agileComp__CommissionPeriod__c period : [SELECT Id,Name,(Select Id FROM agileComp__Commission_Employee_Attained_Values__r
                                                            ) FROM agileComp__CommissionPeriod__c order by agileComp__dateStart__c ASC]){
                    
                    if(period.agileComp__Commission_Employee_Attained_Values__r.size() > 0){
                        periodList.add(period);
                    }
            }
            IntialWrapper iWrapper = new IntialWrapper();
            iWrapper.salesReps = [SELECT Id,Name FROM agileComp__Commission_Sales_Rep__c Order by name];
            iWrapper.periods = periodList;
            // List<FieldWrapper> fieldSet = new List<FieldWrapper>();
            // for (Schema.FieldSetMember f : SObjectType.agileComp__commissionEmployeeAttainedValue__c.FieldSets.agileComp__EAV_Attainment_Form.getFields()) {
            //     FieldWrapper field = new FieldWrapper();
            //     field.api = f.getFieldPath();
            //     field.label = f.getLabel();
            //     field.dataType = String.valueOf(f.getType());
            //     fieldSet.add(field);
            // }
            // iWrapper.fieldSet = fieldSet; 
            return iWrapper;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + Label.AC_Error_Separator + ex.getStackTraceString());
        }
        
    }

    @AuraEnabled
    public static EAVWrapper getEmployeeAttains(String periodId, String salesRepId){
        try {
            AC_SecurityUtils.checkRead( agileComp__commissionEmployeeAttainedValue__c.SObjectType,new List<String> {
                'Name',
                'agileComp__Original_Total_Cost__c',
                'agileComp__GP_Adjustments__c',
                'agileComp__Commission_Adjustments__c',
                'agileComp__Overridden_Attainment_Percentage__c',
                'agileComp__Commission_Team__c',
                'agileComp__Original_Commission_Attained__c'
            });
            EAVWrapper eavWrapper = new EAVWrapper();
            List<FieldWrapper> eavFieldSet = new List<FieldWrapper>();
            List<FieldWrapper> eavExtraFieldSet = new List<FieldWrapper>();
            List<FieldWrapper> eadFieldSet = new List<FieldWrapper>();
            eavWrapper.isActive = [SELECT agileComp__isActive__c FROM agileComp__CommissionPeriod__c WHERE Id = :periodId].agileComp__isActive__c;
            String query = 'SELECT Name,';
            for(Schema.FieldSetMember f : SObjectType.agileComp__commissionEmployeeAttainedValue__c.FieldSets.agileComp__EAV_Attainment_Form.getFields()) {
                if (f.getFieldPath() == 'Name') {
                    continue;
                }
                
                query += f.getFieldPath() + ', ';
                FieldWrapper field = new FieldWrapper();
                field.api = f.getFieldPath();
                field.label = f.getLabel();
                field.dataType = String.valueOf(f.getType());
                eavFieldSet.add(field);
            }
            for(Schema.FieldSetMember f : SObjectType.agileComp__commissionEmployeeAttainedValue__c.FieldSets.agileComp__EAV_Attainment_Form_Extra_Fields.getFields()) {
                if (f.getFieldPath() == 'Name') {
                    continue;
                }
                query += f.getFieldPath() + ', ';
                FieldWrapper field = new FieldWrapper();
                field.api = f.getFieldPath();
                field.label = f.getLabel();
                field.dataType = String.valueOf(f.getType());
                eavExtraFieldSet.add(field);
            }
            if (!query.contains('agileComp__Commission_Team__c')) {
                query += 'agileComp__Commission_Team__c,';
            }
            eavWrapper.eavExtraFieldSet = eavExtraFieldSet;
            
            eavWrapper.eavFieldSet = eavFieldSet;
            query += '(SELECT ';
            for(Schema.FieldSetMember f : SObjectType.agileComp__commissionEmployeeAttainedDetail__c.FieldSets.agileComp__EAD_Attainment_Form.getFields()) {
                query += f.getFieldPath() + ', ';
                FieldWrapper field = new FieldWrapper();
                field.api = f.getFieldPath();
                field.label = f.getLabel();
                field.dataType = String.valueOf(f.getType());
                eadFieldSet.add(field);
            }
            eavWrapper.eadFieldSet = eadFieldSet;
            query = query.substringBeforeLast(',');
            query += ' FROM agileComp__Commission_Employee_Attained_Detail__r ORDER BY agileComp__From__c),';
            query += '(SELECT Id,Name,agileComp__Type__c,agileComp__Commission_Employee_Attained_Value_Recor__c,agileComp__Commission_Employee_Attained_Value_Recor__r.Name,agileComp__Team_Adjustment_Id__c, agileComp__Team_Adjustment__c, agileComp__Adjustment_Type__c,agileComp__Adjustment_Amount__c,agileComp__Adjustment_Description__c,agileComp__System_Generated__c,CreatedDate  FROM agileComp__Commission_Adjustment_Details__r ORDER BY CreatedDate) FROM agileComp__commissionEmployeeAttainedValue__c WHERE agileComp__Commission_Sales_Rep__c = :salesRepId AND agileComp__Commission_Period__c = :periodId';
            List<agileComp__commissionEmployeeAttainedValue__c> eavList = Database.query(query);
            if (eavList.isEmpty()) {
                return null;
            }
            eavWrapper.eavRecords = eavList;
            List<agileComp__commissionEmployeeAttainedValue__c> eavAttainList = [SELECT Id,agileComp__Commission_Team__c FROM agileComp__commissionEmployeeAttainedValue__c WHERE agileComp__Commission_Sales_Rep__c = :salesRepId AND agileComp__Commission_Period__c = :periodId limit 1];
            if(eavAttainList.size() > 0){
                List<agileComp__Commission_Team__c> commissionTeamList = [SELECT Id, (SELECT id FROM agileComp__Commission_Teams__r) FROM agileComp__Commission_Team__c WHERE id =: eavAttainList[0].agileComp__Commission_Team__c];
               Set<Id> teamIdSet = new Set<Id>();
                for(agileComp__Commission_Team__c team : commissionTeamList){
                    teamIdSet.add(team.id);
                    if(team.agileComp__Commission_Teams__r.size() > 0){
                        for(agileComp__Commission_Team__c childTeam : team.agileComp__Commission_Teams__r){
                            teamIdSet.add(childTeam.id);
                        }
                    }
                }
                List<agileComp__commissionEmployeeAttainedValue__c> newEavAttainList = [SELECT Id FROM agileComp__commissionEmployeeAttainedValue__c WHERE agileComp__Commission_Team__c IN : teamIdSet AND Id !=: eavAttainList[0].id];
                List<agileComp__commissionAdjustmentDetail__c> adjustmentExtraList = [SELECT Id,createdDate, agileComp__Commission_Employee_Attained_Value_Recor__c,agileComp__Commission_Employee_Attained_Value_Recor__r.name, agileComp__Adjustment_Description__c, 
                                                                                        agileComp__Adjustment_Amount__c, agileComp__Adjustment_Type__c, Name FROM agileComp__commissionAdjustmentDetail__c WHERE agileComp__Commission_Employee_Attained_Value_Recor__c In : newEavAttainList ];
                                                                                        
                                                                                        eavWrapper.extraAdjustmentDetails = adjustmentExtraList ;
             }
            
            return eavWrapper;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + Label.AC_Error_Separator + ex.getStackTraceString());
        }
        
    }

    @AuraEnabled
    public static void saveRecords(List<agileComp__commissionEmployeeAttainedDetail__c> eadDraftValues,  
                                    List<agileComp__commissionAdjustmentDetail__c> adjDraftValues,
                                    List<String> deleteAdjList,String teamId, String periodId){
        try {
            AC_SecurityUtils.checkUpdate( agileComp__commissionEmployeeAttainedDetail__c.SObjectType,new List<String> {
            'agileComp__Override_Percent__c'
            });
            AC_SecurityUtils.checkUpdate( agileComp__commissionAdjustmentDetail__c.SObjectType,new List<String> {
            'agileComp__Adjustment_Type__c',
            'agileComp__Adjustment_Amount__c',
            'agileComp__Adjustment_Description__c'
            });
            AC_SecurityUtils.checkInsert( agileComp__commissionAdjustmentDetail__c.SObjectType,new List<String> {
            'agileComp__Adjustment_Type__c',
            'agileComp__Adjustment_Amount__c',
            'agileComp__Adjustment_Description__c'
            });
            if (!deleteAdjList.isEmpty()) {
                AC_SecurityUtils.checkObjectIsDeletable(agileComp__commissionAdjustmentDetail__c.SObjectType);
                DELETE [SELECT Id FROM agileComp__commissionAdjustmentDetail__c WHERE Id IN : deleteAdjList];
            }
            if (!eadDraftValues.isEmpty()) {
                update eadDraftValues;
            }
            List<agileComp__commissionAdjustmentDetail__c> adjToUpdate = new List<agileComp__commissionAdjustmentDetail__c>();
            for(agileComp__commissionAdjustmentDetail__c adjDraftValue : adjDraftValues) {
                if (adjDraftValue.get('Id') != null && String.valueof(adjDraftValue.get('Id')).length() < 15) {
                    adjDraftValue.Id = null;
                }
                if (!adjDraftValue.agileComp__System_Generated__c) {
                    adjToUpdate.add(adjDraftValue);
                }
            }
            upsert adjToUpdate;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + Label.AC_Error_Separator + ex.getStackTraceString());
        }
        
    }
    @AuraEnabled
    public static void deleteTeamAdjustmentRecords(String teamAdjJsonString){
        agileComp__commissionAdjustmentDetail__c adj = (agileComp__commissionAdjustmentDetail__c)JSON.deserialize(teamAdjJsonString,agileComp__commissionAdjustmentDetail__c.class);
                List<agileComp__commissionAdjustmentDetail__c> listOfExistingTeamGp = [SELECT Id,agileComp__Adjustment_Amount__c 
                                                                                        FROM agileComp__commissionAdjustmentDetail__c 
                                                                                        WHERE agileComp__Team_Adjustment_Id__c =:adj.agileComp__Team_Adjustment_Id__c  
                                                                                        AND agileComp__Team_Adjustment__c = true];
                if(listOfExistingTeamGp.size() > 0){
                    delete listOfExistingTeamGp;
                }
    }
    public class IntialWrapper {
        @AuraEnabled public List<agileComp__Commission_Sales_Rep__c> salesReps;
        @AuraEnabled public List<agileComp__CommissionPeriod__c> periods;
        // @AuraEnabled public List<FieldWrapper> fieldSet;
    }

    public class EAVWrapper {
        @AuraEnabled public List<FieldWrapper> eavFieldSet;
        @AuraEnabled public List<FieldWrapper> eavExtraFieldSet;
        @AuraEnabled public List<FieldWrapper> eadFieldSet;
        @AuraEnabled public List<agileComp__commissionEmployeeAttainedValue__c> eavRecords;
        @AuraEnabled public List<agileComp__commissionAdjustmentDetail__c> extraAdjustmentDetails;
        @AuraEnabled public Boolean isActive;
    }
    public class FieldWrapper {
        @AuraEnabled public String api; 
        @AuraEnabled public String label; 
        @AuraEnabled public String dataType; 
    }
}