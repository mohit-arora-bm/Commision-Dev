({
	init : function(component, event, helper) {
        helper.createTemplateConfig(component, event, helper, 'c:AC_TemplateConfig', '');
	},
    handleApplicationEventFired : function(component, event, helper) {
        try{
            var eventParamsObj = event.getParam('eventParamsObj');
            console.log(JSON.stringify(eventParamsObj));
            if(eventParamsObj.type === 'recordSelect') {
                var recordId = eventParamsObj.recordId;
                component.set('v.recordId', recordId);
                if(!$A.util.isEmpty(recordId)) {
                    helper.createTemplateConfig(component, event, helper, 'c:AC_TemplateConfig', recordId);
                } else {
                    component.set("v.isScheduled",false);
                    helper.createTemplateConfig(component, event, helper, 'c:AC_TemplateConfig', '');
                }
            }
            if(eventParamsObj.type === 'templateNames' && (!$A.util.isEmpty(eventParamsObj.templates) )) {
                component.set('v.templateNames', eventParamsObj.templates);
            }
            
		}catch(e){
		}
    },
    generalConfig : function(component, event, helper) {
        helper.showSpinner(component);
        var dataService = component.find('dataService');
        var action = component.get("c.setGeneralConfig"); 
        dataService.fetch(action).then($A.getCallback(function (response) {
            helper.createTemplateConfig(component, event, helper, 'c:AC_TemplateConfig', '');
        })).catch(function (error) {
            helper.hideSpinner(component);
            helper.logError(component, 'generalConfig', error.name, error.message);
        });
    }
})