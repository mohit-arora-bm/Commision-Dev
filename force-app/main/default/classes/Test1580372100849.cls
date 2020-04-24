public class Test1580372100849 extends AC_BatchInterface  implements Database.Batchable<AggregateResult> , Database.Stateful {
 String objAPI;
String query;
Integer index;
String templateId;
List<String> JSONStrs;
String userId;

public Test1580372100849(){}
public override void setVariables(List<String> JSONStrs, String objAPI, String query,Integer index, String templateId, String userId ) {
this.objAPI = objAPI;
this.query = query;
this.index = index;
this.templateId = templateId;
this.JSONStrs = JSONStrs;
this.userId = userId;

}
public override Iterable<AggregateResult> start(Database.BatchableContext bc){
return new AggregateResultIterable(query);
}
public override void execute(Database.BatchableContext bc, List<AggregateResult> scope){
Integer currentIndex = index - 1;
System.debug(JSONStrs);
AC_SchedulerTemplateController.createCommisionInput(JSONStrs[currentIndex], objAPI, (List<AggregateResult>)scope, templateId);
}
public override void finish(Database.BatchableContext bc){
AC_SchedulerTemplateController.batchFinal(bc, templateId, index, JSONStrs, objAPI, userId);
}
}