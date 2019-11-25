public virtual class AC_BatchInterface implements Database.Batchable<AggregateResult> , Database.Stateful{
    public AC_BatchInterface() {
        
    }
    public virtual void setVariables(List<String> JSONStrs, String objAPI, String query,Integer index, String templateId, String userId ) {}
    public virtual Iterable<AggregateResult> start(Database.BatchableContext bc){
        return new AggregateResultIterable('select id from account'); 
    }
    public virtual void execute(Database.BatchableContext bc, List<AggregateResult> scope){}
    public virtual void finish(Database.BatchableContext bc){}
}