public with sharing class TemplateBatchScheduler implements Schedulable{
    String objAPI;
    List<String> JSONStrs;
    String templateId;
    String batchName;
    String userId;
    
    public TemplateBatchScheduler(List<String> JSONStrs, String objAPI, String templateId ,String batchName, String userId) {
        this.JSONStrs = JSONStrs;
        this.objAPI = objAPI;
        this.templateId = templateId;
        this.batchName = batchName;
        this.userId = userId;
    }
    public void execute(SchedulableContext sc)
    {
        String query = AC_SchedulerTemplateController.queryGenerator(JSONStrs[0], objAPI, 1, templateId);
        System.debug('query Schedule'+query);
        // We now call the batch class to be scheduled
        // Integer next = index - 1;
        // TemplateBatch b = new TemplateBatch(str, objAPI, query, index, templateId );
        // TemplateBatch b = new TemplateBatch(JSONStrs, objAPI, query, 1, templateId );
        Type customType = Type.forName(batchName);
        AC_BatchInterface instance = (AC_BatchInterface)customType.newInstance();
        instance.setVariables(JSONStrs, objAPI, query, 1, templateId, userId);
        
        database.executebatch(instance,200);
        
    }
}