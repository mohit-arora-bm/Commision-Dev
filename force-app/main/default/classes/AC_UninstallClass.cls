global with sharing class AC_UninstallClass implements UninstallHandler {
    global void onUninstall(UninstallContext ctx) {
        String exp = 'AC_ScheduleBatchCreationJob%';
        List<CronTrigger> schedJobs = [SELECT Id, CronJobDetail.Name, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name LIKE : exp];
        for (CronTrigger sjob : schedJobs) {
                System.abortJob(sjob.Id);
        }
    }
}