trigger AC_TemplateConfigTrigger on agileComp__AC_Templates_Config__c (after delete) {
    List<String> apexClasses = new List<String>();

    for (agileComp__AC_Templates_Config__c temp : Trigger.old) {
        if (!String.isEmpty(temp.agileComp__AC_BatchClassName__c)) {
            apexClasses.add(temp.agileComp__AC_BatchClassName__c);
            String testClassName = temp.agileComp__AC_BatchClassName__c;
            if (testClassName.length() > 34) {
                testClassName = testClassName.substring(0,34);
            }
            testClassName += '_Test';
            apexClasses.add(testClassName);
        }   
        if (!Test.isRunningTest()) {
            AC_TemplatebatchDeletion.deleteClass(apexClasses);
        }
    }

}