global class test1587542700724 extends agileComp.AC_BatchInterface  implements Database.Batchable<AggregateResult> , Database.Stateful {
 String objAPI;
String query;
Integer index;
String templateId;
List<String> JSONStrs;
String userId;
global test1587542700724(){}
global override void setVariables(List<String> JSONStrs, String objAPI, String query,Integer index, String templateId, String userId ) {
this.objAPI = objAPI;
this.query = query;
this.index = index;
this.templateId = templateId;
this.JSONStrs = JSONStrs;
this.userId = userId;

}
global override Iterable<AggregateResult> start(Database.BatchableContext bc){
return new agileComp.AggregateResultIterable(query);
}
global override void execute(Database.BatchableContext bc, List<AggregateResult> scope){
try { 
Integer currentIndex = index - 1;
agileComp.AC_SchedulerTemplateController.createCommisionInput(JSONStrs[currentIndex], objAPI, (List<AggregateResult>)scope, templateId);
}
catch(Exception ex) {agileComp.AC_DataService.logException(ex.getMessage(), ex.getStackTraceString());}}
global override void finish(Database.BatchableContext bc){
try { 
agileComp.AC_SchedulerTemplateController.batchFinal(bc, templateId, index, JSONStrs, objAPI, userId);
}
catch(Exception ex) {agileComp.AC_DataService.logException(ex.getMessage(), ex.getStackTraceString());}}
}