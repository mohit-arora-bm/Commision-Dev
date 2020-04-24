({
    createTemplateConfig: function(component, event, helper, componentName, recordId) { 
       helper.showSpinner(component);
        var dataService = component.find('dataService');
        var action = component.get("c.getComponentDisability"); 
        action.setParams({ objectAPIName : 'agileComp__AC_Templates_Config__c' });
        dataService.fetch(action).then($A.getCallback(function (response) {
            component.set("v.isComponentDisabled", response.isComponentDisabled);
            component.set("v.generalConfig", response.generalConfig);
            component.set("v.hasCofigPermission", response.hasCofigPermission);
            if (response.generalConfig) {
                helper.createTemplateConfigHelper(component, event, helper, componentName, recordId);
            }
            helper.hideSpinner(component);

        })).catch(function (error) {
            helper.hideSpinner(component);
            helper.logError(component, 'createTemplateConfig', error.name, error.message);
        });
       
    },
    
    createTemplateConfigHelper : function(component, event, helper, componentName, recordId) {
        
        $A.createComponent(componentName,{
            'recordId' : recordId,
            'templateNames' : component.get('v.templateNames'),
            "isScheduled" : component.getReference('v.isScheduled'),
            "hasBatch" : component.getReference('v.hasBatch')
                },
            function(compBody, status, errorMessage) {
                console.log(status);
                console.log(errorMessage);
                if (status === "SUCCESS" && component.find('templateConfigComp')) { 
                    console.log(component.find('templateConfigComp'));
                    component.find('templateConfigComp').set("v.body", compBody);
                } else if (status === "INCOMPLETE") {
                    //
                } else if (status === "ERROR") {
                    //
                }
            }
        );
    },
    logError : function(component, methodName, errorName, errorMessage) {
        console.log('AC_TemplateContainer -> ' + methodName + errorName, errorMessage);
		component.find('dataService').logException('AC_TemplateContainer -> ' + methodName + errorName, errorMessage);
	},
	hideSpinner : function( component ) {
        $A.util.addClass(component.find("Spinner"), "slds-hide");
    },
    showSpinner : function( component ) {
        $A.util.removeClass(component.find("Spinner"), "slds-hide");
	},
})