({
    doInitHelper : function(component) {
        let self = this;
        let action = component.get("c.calculateGoal");
        action.setParams({
            "recId" : component.get("v.recordId")
        });
        let dataService = component.find('dataService');
        dataService.fetch(action)
        .then($A.getCallback(function (result) {
            self.showToast(component, 'Success', 'success', 'The goals are successfully updated');
            $A.get('e.force:refreshView').fire();
            $A.get("e.force:closeQuickAction").fire();
        })).catch(function (error) {
            self.logError(component, 'doInitHelper', error.name, error.message);
            $A.get("e.force:closeQuickAction").fire();
        });
    },
	showToast : function(component, title, type, message) {
		$A.get('e.force:showToast').setParams({
			title: title,
			message: message,
			type: type
		}).fire();
	},
	logError : function(component, methodName, errorName, errorMessage) {
		console.error(methodName,errorName,errorMessage);
		component.find('dataService').logException('AC_CalculateGoal -> ' + methodName + errorName, errorMessage);
	}
})