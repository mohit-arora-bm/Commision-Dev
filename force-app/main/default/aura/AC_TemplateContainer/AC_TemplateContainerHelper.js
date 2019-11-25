({
    createTemplateConfig: function(component, event, helper, componentName, recordId) { 
        var self = this;
        var action = component.get("c.getComponentDisability");
        action.setParams({ objectAPIName : 'agileComp__AC_Templates_Config__c' });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isComponentDisabled", response.getReturnValue());
                //component.set("v.isComponentDisabled", true);
                self.createTemplateConfigHelper(component, event, helper, componentName, recordId);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                    }
                } else {
                }
            }
        });
        $A.enqueueAction(action);
       
    },
    
    createTemplateConfigHelper : function(component, event, helper, componentName, recordId) {
        
        $A.createComponent(componentName,{
            'recordId' : recordId,
            'templateNames' : component.get('v.templateNames'),
            "isScheduled" : component.getReference('v.isScheduled')
                },
            function(compBody, status, errorMessage) {
                console.log(status);
                console.log(errorMessage);
                if (status === "SUCCESS") {
                    component.find('templateConfigComp').set("v.body", compBody);
                } else if (status === "INCOMPLETE") {
                    //
                } else if (status === "ERROR") {
                    //
                }
            }
        );
    }
    })