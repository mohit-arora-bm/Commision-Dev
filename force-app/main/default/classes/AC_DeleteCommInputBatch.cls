public with sharing class AC_DeleteCommInputBatch implements Database.Batchable<sObject>  {
	 public final String Query;

	public AC_DeleteCommInputBatch(String q){
			Query=q; 
	}

	public Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext BC, List<sObject> scope){
		delete scope;
	}

	public void finish(Database.BatchableContext BC){

	}
}