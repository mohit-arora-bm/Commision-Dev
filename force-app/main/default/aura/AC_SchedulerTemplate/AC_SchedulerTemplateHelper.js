({
    cronBuilder : function() {
        // Initialize DOM with cron builder
        $('#cron').cronBuilder();

        // // Add event handler to button
        // $('button#generate').click(function(){

        //     // Get current cron expression
        //     var expression=$('#cron').data('cronBuilder').getExpression();

        //     // Dispaly cron expression
        //     $('#result').text(expression);
        // })
    },
	hideSpinner : function( component ) {
        $A.util.addClass(component.find("Spinner"), "slds-hide");
    },
    showSpinner : function( component ) {
        $A.util.removeClass(component.find("Spinner"), "slds-hide");
    },
    logError : function(component, methodName, errorName, errorMessage) {
		this.hideSpinner(component);
		console.error(methodName,errorName,errorMessage);
		component.find('dataService').logException('AC_SchedulerTemplate -> ' + methodName + errorName, errorMessage);
    },
    showToast : function(component, title, type, message) {
		$A.get('e.force:showToast').setParams({
			title: title,
			message: message,
			type: type
		}).fire();
    },
})