global virtual class AC_BatchInterface implements Database.Batchable<AggregateResult> , Database.Stateful{
    global AC_BatchInterface() {
        
    }
    global virtual void setVariables(List<String> JSONStrs, String objAPI, String query,Integer index, String templateId, String userId) {
        System.debug('Called this');
    }
    global virtual void setUniqueString(String uniqueString) {
        System.debug('Called this');
    }
    global virtual Iterable<AggregateResult> start(Database.BatchableContext bc){
        try{
            System.debug('Here called AC_BatchInterface');
            return new AggregateResultIterable('select Name from account group by Name limit 50000'); 
        }catch(Exception ex){
            AC_DataService.logException(ex.getMessage(), ex.getStackTraceString());
            return null;
        }
    }
    global virtual void execute(Database.BatchableContext bc, List<AggregateResult> scope){
        System.debug('Here called AC_BatchInterface execute>>> ');
        if(scope.size() > 0){
            System.debug(scope[0]);
        }
    }
    global virtual void finish(Database.BatchableContext bc){} 
}