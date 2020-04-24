global with sharing class AC_ScheduleBatchCreation implements Schedulable{
    global void execute(SchedulableContext sc) {
        AC_TemplatebatchCreation instance = new AC_TemplatebatchCreation();
        database.executebatch(instance,1);
    }
}