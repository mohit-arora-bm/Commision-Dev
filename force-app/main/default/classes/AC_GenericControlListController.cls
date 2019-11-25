public class AC_GenericControlListController { 

	
    @AuraEnabled
    public static void unScheduleJob(String templateId){
		try {
       		List<agileComp__AC_Templates_Config__c> configs = [Select Id, agileComp__AC_Name__c FROM agileComp__AC_Templates_Config__c where id = :templateId];
			String jobName = configs[0].agileComp__AC_Name__c;
            List<CronTrigger> jobs = [SELECT Id , CronJobDetail.Id  FROM CronTrigger WHERE CronJobDetail.Name = : jobName];
            // List<CronJobDetail> jobs = [SELECT Id FROM CronJobDetail WHERE Name = : jobName];
			for (CronTrigger job : jobs) {
				System.abortJob(job.Id);
			}
			
		} catch(Exception ex) {
			throw new AuraHandledException(ex.getMessage() + Label.AC_Error_Separator + ex.getStackTraceString());
		}
    }

	@AuraEnabled
	public static List<RecordWrapper> fetchRecords(String objectAPIName, String fieldsListJSON) {
		try {
			String queryBefore = 'SELECT ';
			String fieldsString = '';
			List<RecordWrapper> recordsList = new List<RecordWrapper>();
			List<FieldsWrapper> fieldsList = (List<FieldsWrapper>) JSON.deserialize(fieldsListJSON, List<FieldsWrapper>.class);

			Boolean isSortByName = false;
			for(FieldsWrapper fieldWrapper : fieldsList) {
				fieldsString += fieldWrapper.fieldAPIName + ',';
				if( fieldWrapper.fieldAPIName == 'agileComp__AC_Name__c') {
					isSortByName = true; 
				}
			}
			fieldsString += 'Id ';
			String queryAfter = '';
			if( isSortByName == true ) {
				queryAfter = ' FROM ' + objectAPIName + ' ORDER BY agileComp__AC_Name__c ASC';
			}
			else {
				queryAfter = ' FROM ' + objectAPIName;
			}
			 
			// check Read FLS
			AC_SecurityUtils.checkRead( Schema.getGlobalDescribe().get(objectAPIName).getDescribe().getSobjectType(), fieldsString.split(',') );
			List<sObject> sobjectList = Database.query(queryBefore + fieldsString + queryAfter);
			List<FieldsWrapper> fieldsWrapperList = new List<FieldsWrapper>();
			List<String> templateNames = new List<String>();
			for(sObject sobj : sobjectList) {
				templateNames.add((String)sobj.get('agileComp__AC_Name__c'));
			}
			Map<String,Datetime> nextTimeMap = getNextScheduleDate(templateNames);
			for(sObject sobj : sobjectList) {
				fieldsWrapperList = new List<FieldsWrapper>();
				for(FieldsWrapper fieldWrapper : fieldsList) {
					fieldsWrapperList.add(new FieldsWrapper(fieldWrapper.fieldAPIName, fieldWrapper.fieldLabel, (String)sobj.get(fieldWrapper.fieldAPIName)));
					
				}
				if (nextTimeMap.containsKey((String)sobj.get('agileComp__AC_Name__c'))) {
					recordsList.add(new RecordWrapper((String)sobj.get('Id'), fieldsWrapperList,nextTimeMap.get((String)sobj.get('agileComp__AC_Name__c'))));
				}
				else {
					recordsList.add(new RecordWrapper((String)sobj.get('Id'), fieldsWrapperList,null));
				}
			}
			return recordsList;
		} catch(Exception ex) {
			throw new AuraHandledException(ex.getMessage() + Label.AC_Error_Separator + ex.getStackTraceString());
		}
	}
	private static Map<String,Datetime> getNextScheduleDate(List<String> templateNames) {
		Map<String,Datetime> nextTimeMap = new Map<String,Datetime>();
		for (CronTrigger ct : [SELECT Id, CronJobDetail.Name, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name IN : templateNames ORDER BY CreatedDate DESC]) {
			nextTimeMap.put(ct.CronJobDetail.Name, ct.NextFireTime);
		}
		return nextTimeMap;
	}
	@AuraEnabled
	public static void deleteRowApex(String recordId) {
		try {
            //Security Check if object is deletable
            AC_SecurityUtils.checkObjectIsDeletable(Id.valueOf(recordId).getSobjectType());
            
			SObject sobj = Id.valueOf(recordId).getSobjectType().newSobject(recordId);
			delete new List<SObject> { sobj };
		} catch(Exception ex) {
            system.debug('error - ' + ex.getMessage());
			throw new AuraHandledException(ex.getMessage() + Label.AC_Error_Separator + ex.getStackTraceString());
		}
	}


	@AuraEnabled
	public static Boolean getComponentDisability( String objectAPIName) {
		Boolean isComponentDisabled = false;
		DescribeSobjectResult desSobj = Schema.getGlobalDescribe().get(objectAPIName).getDescribe();
			if(!( desSobj.isCreateable() && desSobj.isUpdateable() && desSobj.isDeletable() )  ) {
				isComponentDisabled = true;
			}
		return isComponentDisabled;	
			
	}

	public class RecordWrapper {
		@AuraEnabled public String recordId;
		@AuraEnabled public Datetime next;
		@AuraEnabled public List<FieldsWrapper> fieldsList;

		public RecordWrapper(String recordId, List<FieldsWrapper> fieldsList, Datetime next) {
			this.recordId = recordId;
			this.fieldsList = fieldsList;
			this.next = next;
		}
	}

	public class FieldsWrapper {
		@AuraEnabled public String fieldAPIName;
		@AuraEnabled public String fieldLabel;
		@AuraEnabled public String fieldValue;

		public FieldsWrapper(String fieldAPIName, String fieldLabel, String fieldValue) {
			this.fieldAPIName = fieldAPIName;
			this.fieldLabel = fieldLabel;
			this.fieldValue = fieldValue;
		}
	}
}