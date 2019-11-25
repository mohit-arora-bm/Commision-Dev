/* eslint-disable no-unused-vars */
/* eslint-disable vars-on-top */
/* eslint-disable no-unused-expressions */
({
	changeInputType : function(component, event, helper) {
        var value = event.getSource().get("v.value");
        if (value === 'Multilple') {
            helper.cronBuilder();
        }
        else {
            component.find("cron").getElement().innerHTML = '';
        }
    },
    scheduleIt : function(component, event, helper) {
        let selectedUser = component.get("v.selectedUser");
        if ( !selectedUser || !selectedUser.Id) {
            helper.showToast(component, 'ERROR', 'error', 'Please select the User.');
            return;
        }
        var inputType = component.get("v.inputType");
        var expression;
        var scheduleOn;
        if (inputType === 'Multilple') {
            expression=$('#cron').data('cronBuilder').getExpression();
        }
        else {
            scheduleOn = component.get("v.scheduleOn");
            if (!scheduleOn) {
                helper.showToast(component, 'ERROR', 'error', 'Please select the Date.');
                return;
            }
        }

        var action = component.get("c.scheduleTemplate");
        action.setParams({
            'templateId' : component.get("v.templateId"),
            'cronExp' : expression,
            'scheduleOn' : scheduleOn,
            'expiresOn' : component.get("v.expiresOn"),
            'userId' : selectedUser.Id
        });
        var dataService = component.find('dataService');
        dataService.fetch(action).then($A.getCallback(function (response) {
            var eventParamsObj = {
            	type: 'refresh',
            	recordId: component.get("v.templateId")
            };
            $A.get('e.c:AC_GenericControlRecordSelectEvt').setParams({
            	eventParamsObj: eventParamsObj
            }).fire();
        })).catch(function (error) {
            helper.hideSpinner(component);
            helper.logError(component, 'scheduleIt', error.name, error.message);
        });
    },
    loadJquery : function(component, event, helper) {
        helper.cronBuilder();
    },
    
	
})