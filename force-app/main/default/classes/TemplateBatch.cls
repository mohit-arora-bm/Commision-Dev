public class TemplateBatch extends AC_BatchInterface implements Database.Batchable<AggregateResult> , Database.Stateful {
    
    String objAPI;
    String query;
    Integer index;
	String templateId;
    List<String> JSONStrs;
    String userId;
    
    public TemplateBatch (){}
    public override void setVariables(List<String> JSONStrs, String objAPI, String query,Integer index, String templateId, String userId ) {
        this.objAPI = objAPI;
        this.query = query;
        this.index = index;
		this.templateId = templateId;
        this.JSONStrs = JSONStrs;
        this.userId = userId;
    }
    // The batch job starts
    public override  Iterable<AggregateResult> start(Database.BatchableContext bc){
        //String query = 'SELECT Id, Name FROM Account';
        System.debug('>>>> start ' + query);
        return new AggregateResultIterable(query); 
    } 
    
    // The batch job executes and operates on one batch of records
    public override  void execute(Database.BatchableContext bc, List<AggregateResult> scope){
        Integer currentIndex = index - 1;
        System.debug(JSONStrs);
        AC_SchedulerTemplateController.createCommisionInput(JSONStrs[currentIndex], objAPI, (List<AggregateResult>)scope, templateId);
    }
    
    // The batch job finishes
    public override void finish(Database.BatchableContext bc){
        AC_SchedulerTemplateController.batchFinal(bc, templateId, index, JSONStrs, objAPI, userId);
    }
}