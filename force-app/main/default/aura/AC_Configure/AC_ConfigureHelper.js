({
    postAction : function(component, hepler, AsyncResultId) {
        let action = component.get("c.checkStatus");
        action.setParams({
            "AsyncResultId" : AsyncResultId
        });
        let dataService = component.find('dataService');
        dataService.fetch(action)
        .then($A.getCallback(function (response) {
            if(response) {
                hepler.hideSpinner(component);
                component.set('v.message','You can uninstall this package there is no dependency');
                component.set('v.needDeConfigure',false);
            }
            else {
                hepler.postAction(component, hepler, AsyncResultId);
            }
        })).catch(function (error) {
            helper.logError(component, 'postAction', error.name, error.message);
        });
    },
    logError : function(component, methodName, errorName, errorMessage) {
		this.hideSpinner(component);
		component.find('dataService').logException('AC_Configure -> ' + methodName + errorName, errorMessage);
	},
	showToast : function(component, title, type, message) {
		$A.get('e.force:showToast').setParams({
			title: title,
			message: message,
			type: type
		}).fire();
    },
    hideSpinner : function( component ) {
        $A.util.addClass(component.find("Spinner"), "slds-hide");
    },
    showSpinner : function( component ) {
        $A.util.removeClass(component.find("Spinner"), "slds-hide");
	},
})