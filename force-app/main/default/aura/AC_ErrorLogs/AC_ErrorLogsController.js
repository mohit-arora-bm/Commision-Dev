({
    doInit : function(component, event, helper) {
        helper.showSpinner(component);
        let templateId = component.get("v.templateId");
        if (templateId) {
            let action = component.get("c.getErrors");
            action.setParams({
                'templateId' : templateId,
                'filterDate' : component.get("v.filterDate")
            });
            let dataService = component.find('dataService');
            dataService.fetch(action).then($A.getCallback(function (response) {
                component.set("v.errorRecords",response);
                helper.hideSpinner(component);
            })).catch(function (error) {
                helper.hideSpinner(component);
                component.find('dataService').logException('AC_GenericControlList -> doInitHelper ' + error.name, error.message);
            });
        }
    }
})