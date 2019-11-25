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
                    helper.createTemplateConfig(component, event, helper, 'c:AC_TemplateConfig', '');
                }
            }

            if(eventParamsObj.type === 'templateNames' && (!$A.util.isEmpty(eventParamsObj.templates) )) {
                component.set('v.templateNames', eventParamsObj.templates);
            }
            
		}catch(e){
		}
    },
    
})