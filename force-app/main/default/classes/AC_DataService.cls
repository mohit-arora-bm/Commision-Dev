public without sharing class AC_DataService {

	@AuraEnabled
	public static void logException(String errorMessage, String stackTrace) {
		agileComp__AC_ErrorLog__c errorLog = new agileComp__AC_ErrorLog__c();
		String errorString = 'Error: ' + '\n' + errorMessage + '\n'
							+ '***************************\n'
							+ 'Stack Trace:\n' + stackTrace;
		errorLog.agileComp__AC_ErrorMessage__c = errorString;
		errorLog.agileComp__AC_UserInfo__c = 'Username: ' + UserInfo.getUserName() + '\n'
										+ 'UserId: ' + UserInfo.getUserId();
		// errorLog.agileComp__AC_Template_Object__c = objAPI;
		AC_SecurityUtils.checkInsert( agileComp__AC_ErrorLog__c.SObjectType,new List<String> {
			'agileComp__AC_ErrorMessage__c',
			'agileComp__AC_UserInfo__c',
			'agileComp__AC_Template_Object__c'
		});		
		insert new List<agileComp__AC_ErrorLog__c> {errorLog};
	}
}