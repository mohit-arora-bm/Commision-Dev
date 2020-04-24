global class Acc1581672300814 extends agileComp.AC_BatchInterface  implements Database.Batchable<AggregateResult> , Database.Stateful {
 String objAPI;
String query;
Integer index;
String templateId;
List<String> JSONStrs;
String userId;

global Acc1581672300814(){}
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
Integer currentIndex = index - 1;
System.debug(JSONStrs);
agileComp.AC_SchedulerTemplateController.createCommisionInput(JSONStrs[currentIndex], objAPI, (List<AggregateResult>)scope, templateId);
}
global override void finish(Database.BatchableContext bc){
agileComp.AC_SchedulerTemplateController.batchFinal(bc, templateId, index, JSONStrs, objAPI, userId);
}
}