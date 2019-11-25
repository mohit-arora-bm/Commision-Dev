({
	logError: function(component, errorMessage, stackTrace) {
        var self = this;
        self.showToast(component, 'Error', 'error', errorMessage);
		var action = component.get('c.logException');
        action.setBackground();
        action.setParams({
            errorMessage: errorMessage,
            stackTrace: stackTrace
        });
        action.setCallback(this, function(response) {
            if(response.getState() !== 'SUCCESS') {
                console.log('Error while logging exception');
            }
        });
        $A.enqueueAction(action);
    },
    showToast : function(component, title, type, message) {
		$A.get('e.force:showToast').setParams({
			title: title,
			message: message,
			type: type
		}).fire();
	}
})