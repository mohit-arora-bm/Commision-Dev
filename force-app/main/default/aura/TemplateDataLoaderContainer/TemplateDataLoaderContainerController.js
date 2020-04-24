({
	handleRecordChange : function(component, event, helper) {
		var eventParamsObj = event.getParam('eventParamsObj');

		if( eventParamsObj.type == 'recordSelect') {
			helper.createTemplateConfigHelper(component,event, eventParamsObj.templateId, eventParamsObj.templateName);
		}
		
	},
})